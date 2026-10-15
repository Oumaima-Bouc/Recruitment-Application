import 'dart:math';
import 'dart:developer' as developer;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:bcrypt/bcrypt.dart';

import 'package:khedmni/core/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dao/user_dao.dart';
import '../../models/user.dart';

class AuthRepository {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userIdKey = 'userId';
  static const String _userEmailKey = 'userEmail';
  static const String _userTypeKey = 'userType';

  final UserDao _userDao = UserDao();
  final Random _random = Random();
  final http.Client _httpClient;

  AuthRepository({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  /// Send a verification email (simulated): generates a 4-digit token and stores it with the user
  Future<void> sendVerificationEmail(String email) async {
    var user = await _userDao.getUserByEmail(email);

    // Rate-limit resends per email (e.g., 60s cooldown)
    final prefs = await SharedPreferences.getInstance();
    final key = 'verification_last_sent_$email';
    final lastMs = prefs.getInt(key);
    if (lastMs != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
      if (DateTime.now().difference(last) < const Duration(seconds: 60)) {
        throw Exception('Please wait before resending verification email');
      }
    }

    // Generate a 4-digit numeric code
    final token = (_random.nextInt(9000) + 1000).toString();

    // Persist last sent timestamp
    await prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);

    if (user == null) {
      // Create a temporary unverified user so tokens can be stored and later claimed
      final tempUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        email: email,
        password: '',
        userType: 'student',
        isEmailVerified: false,
        emailVerificationToken: token,
        createdAt: DateTime.now(),
      );
      await _userDao.insertUser(tempUser);
      user = tempUser;
    } else {
      final updated = user.copyWith(isEmailVerified: false, emailVerificationToken: token);
      await _userDao.updateUser(updated);
    }

    // Simulate sending email in dev — log the code to console (use an email service in production).
    developer.log('Verification code for $email: $token', name: 'auth_repository.sendVerificationEmail');

    // Try to POST the verification code to the email-sender microservice so an email
    // can be delivered. The service URL can be overridden with --dart-define=EMAIL_SERVICE_URL.
    try {
      final resp = await _httpClient.post(
        Uri.parse('$kEmailServiceUrl/send-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': token}),
      );

      if (resp.statusCode == 200) {
        developer.log('Verification email queued by email service', name: 'auth_repository.sendVerificationEmail');
      } else {
        developer.log('Email service responded ${resp.statusCode}: ${resp.body}', name: 'auth_repository.sendVerificationEmail');
      }
    } catch (e, st) {
      developer.log('Failed to POST verification to email service: $e', name: 'auth_repository.sendVerificationEmail', error: e, stackTrace: st);
    }
  }

  /// Check email verification status by user id
  Future<bool> checkEmailVerificationStatus(String userId) async {
    final user = await _userDao.getUserById(userId);
    if (user == null) return false;
    return user.isEmailVerified;
  }

  /// Verify code — returns true if code matched and marks user verified
  Future<bool> verifyEmailToken(String userId, String token) async {
    final user = await _userDao.getUserById(userId);
    if (user == null) return false;
    if (user.emailVerificationToken != null && user.emailVerificationToken == token) {
      final updated = user.copyWith(isEmailVerified: true, emailVerificationToken: null);
      await _userDao.updateUser(updated);
      return true;
    }
    return false;
  }

  /// Change user's password (local auth). Returns true on success.
  Future<bool> changePassword(String userId, String currentPassword, String newPassword) async {
    final user = await _userDao.getUserById(userId);
    if (user == null) return false;

    // Verify current password. Support legacy plaintext passwords and malformed hashes.
    final stored = user.password;
    bool verified = false;

    if (stored.isNotEmpty && RegExp(r'^\$2[aby]\$').hasMatch(stored)) {
      try {
        verified = BCrypt.checkpw(currentPassword, stored);
      } catch (e) {
        // Malformed or truncated hash; fall back to plaintext compare
        verified = stored == currentPassword;
      }
    } else {
      // Legacy plaintext password
      verified = stored == currentPassword;
    }

    if (!verified) return false;

    // Hash and save new password
    final hashed = BCrypt.hashpw(newPassword, BCrypt.gensalt());
    final updated = user.copyWith(password: hashed);
    await _userDao.updateUser(updated);
    return true;
  }

  /// Update user profile. If email changed, mark as unverified and send verification code to the new email.
  Future<void> updateUserProfile(User user) async {
    // Check existing user
    final existing = await _userDao.getUserById(user.id);
    if (existing == null) throw Exception('User not found');

    final emailChanged = existing.email != user.email;
    User toSave = user;

    print("DEBUG: AuthRepository.updateUserProfile for ${user.id}");
    if (emailChanged) {
      print("DEBUG: Email changed, sending verification...");
      // Mark unverified and clear token; send new verification code
      toSave = toSave.copyWith(isEmailVerified: false, emailVerificationToken: null);
      await _userDao.updateUser(toSave);
      await sendVerificationEmail(toSave.email);
    } else {
      print("DEBUG: Email did not change. Updating user in DAO with CV: ${toSave.cvUrl}");
      final rows = await _userDao.updateUser(toSave);
      print("DEBUG: DAO.updateUser returned $rows rows affected");
    }

    // Update SharedPreferences if needed
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_userIdKey) == user.id) {
      await prefs.setString(_userEmailKey, user.email);
      await prefs.setString(_userTypeKey, user.userType);
    }
  }

  /// Utility: get user by id
  Future<User?> getCurrentUserById(String userId) async => await _userDao.getUserById(userId);

  /// Login with email and password
  Future<User> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check database for user
    // Find user by email
    final user = await _userDao.getUserByEmail(email);
    if (user == null) throw Exception('Invalid email or password');

    // Verify password against stored hash, supporting legacy plaintext passwords and malformed hashes.
    final stored = user.password;
    bool verified = false;

    if (stored.isNotEmpty && RegExp(r'^\$2[aby]\$').hasMatch(stored)) {
      try {
        verified = BCrypt.checkpw(password, stored);
      } catch (e) {
        // Malformed or truncated hash; fall back to plaintext compare
        verified = stored == password;
      }
    } else {
      // Legacy plaintext password
      verified = stored == password;
    }

    if (!verified) throw Exception('Invalid email or password');

    // If we matched a legacy plaintext password, migrate it to bcrypt
    if (!(stored.isNotEmpty && RegExp(r'^\$2[aby]\$').hasMatch(stored))) {
      final hashed = BCrypt.hashpw(password, BCrypt.gensalt());
      final updated = user.copyWith(password: hashed);
      await _userDao.updateUser(updated);
    }

    // Save session to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, user.id);
    await prefs.setString(_userEmailKey, user.email);
    await prefs.setString(_userTypeKey, user.userType);

    return user;
  }

  /// Start signup process: checks if email is available and returns a verification code
  Future<String> startSignup(String email) async {
    // Check if email already exists AND is verified
    final user = await _userDao.getUserByEmail(email);
    if (user != null && user.isEmailVerified) {
      throw Exception('Email already registered');
    }

    // Rate-limit resends per email (e.g., 60s cooldown)
    final prefs = await SharedPreferences.getInstance();
    final key = 'verification_last_sent_$email';
    final lastMs = prefs.getInt(key);
    if (lastMs != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
      if (DateTime.now().difference(last) < const Duration(seconds: 60)) {
        throw Exception('Please wait before resending verification email');
      }
    }

    // Generate a 4-digit numeric code
    final token = (_random.nextInt(9000) + 1000).toString();

    // Persist last sent timestamp
    await prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);

    // Persist an unverified user record (or update existing unverified user) so
    // verification tokens can be stored and resend works reliably.
    if (user != null) {
      final updated = user.copyWith(isEmailVerified: false, emailVerificationToken: token);
      await _userDao.updateUser(updated);
    } else {
      final tempUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        email: email,
        password: '',
        userType: 'student',
        isEmailVerified: false,
        emailVerificationToken: token,
        createdAt: DateTime.now(),
      );
      await _userDao.insertUser(tempUser);
    }

    // Simulate sending email (logging)
    developer.log('Verification code for $email: $token', name: 'auth_repository.startSignup');

    // Attempt to use email service (best-effort)
    try {
      final resp = await _httpClient.post(
        Uri.parse('$kEmailServiceUrl/send-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': token}),
      );
      if (resp.statusCode == 200) {
        developer.log('Verification email queued by email service', name: 'auth_repository.startSignup');
      } else {
        developer.log('Email service responded ${resp.statusCode}: ${resp.body}', name: 'auth_repository.startSignup');
      }
    } catch (e) {
      developer.log('Failed to POST verification to email service: $e', name: 'auth_repository.startSignup');
    }

    return token;
  }

  /// Finalize signup: Actually inserts the user into the database after verification
  Future<User> completeSignup({
    required String name,
    required String email,
    required String password,
    required String userType,
  }) async {
    // Double check email isn't verified by someone else meanwhile
    final existing = await _userDao.getUserByEmail(email);
    if (existing != null && existing.isEmailVerified) {
      throw Exception('Email was just registered by another user');
    }

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: BCrypt.hashpw(password, BCrypt.gensalt()),
      userType: userType,
      isEmailVerified: true, // They are verified now!
      emailVerificationToken: null,
      createdAt: DateTime.now(),
    );

    // Insert into database (will replace any unverified user with same email/id if exists)
    await _userDao.insertUser(user);

    // Save session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, user.id);
    await prefs.setString(_userEmailKey, user.email);
    await prefs.setString(_userTypeKey, user.userType);

    return user;
  }

  /// Sign up a new user (Deprecated/Original - will be redirected to startSignup in Cubit)
  Future<User> signup(
    String name,
    String email,
    String password, {
    String userType = 'student',
  }) async {
     // For compatibility, we'll just use completeSignup directly if called, 
     // but we should use the 2-step flow.
     return await completeSignup(name: name, email: email, password: password, userType: userType);
  }

  /// Logout current user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userTypeKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Get current user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Get current user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Get current user type
  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  /// Get current logged-in user
  Future<User?> getCurrentUser() async {
    final userId = await getUserId();
    if (userId != null) {
      return await _userDao.getUserById(userId);
    }
    return null;
  }


}
