import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../models/user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkLoginStatus() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          // Logged in flag is true but user not found in DB? Logout or Error.
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> signup(String name, String email, String password, {String userType = 'student', String? bio, String? photoPath}) async {
    emit(AuthLoading());
    try {
      final code = await _authRepository.startSignup(email);
      emit(AuthPendingVerification(
        name: name,
        email: email,
        password: password,
        userType: userType,
        code: code,
        bio: bio,
        photoPath: photoPath,
      ));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> finalizeSignup(String name, String email, String password, String userType) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.completeSignup(
        name: name,
        email: email,
        password: password,
        userType: userType,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Emit a fresh authenticated state after verification occurs externally
  void emitAuthUpdateAfterVerification(User user) {
    emit(AuthAuthenticated(user));
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? title,
    String? skills,
    String? bio,
    String? photoUrl,
    String? cvUrl,
    String? location,
    String? phone,
  }) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      print("DEBUG: AuthCubit.updateProfile starting for user ${currentState.user.id}");
      try {
        final currentUser = currentState.user;
        print("DEBUG: Current CV: ${currentUser.cvUrl}, New CV: $cvUrl");
        final updatedUser = currentUser.copyWith(
          name: name ?? currentUser.name,
          email: email ?? currentUser.email,
          skills: skills ?? currentUser.skills,
          bio: bio ?? currentUser.bio,
          title: title ?? currentUser.title,
          photoUrl: photoUrl ?? currentUser.photoUrl,
          cvUrl: cvUrl ?? currentUser.cvUrl,
          cvLastUpdated: cvUrl != null ? DateTime.now() : currentUser.cvLastUpdated,
          location: location ?? currentUser.location,
          phone: phone ?? currentUser.phone,
        );
        
        print("DEBUG: Updating profile in DB...");
        await _authRepository.updateUserProfile(updatedUser);
        // fetch fresh user from DB
        print("DEBUG: Fetching fresh user from DB...");
        final fresh = await _authRepository.getCurrentUserById(updatedUser.id);
        if (fresh != null) {
          print("DEBUG: fresh user found, CV is: ${fresh.cvUrl}");
          emit(AuthAuthenticated(fresh));
        } else {
          print("DEBUG: fresh user NULL, emitting updatedUser directly");
          emit(AuthAuthenticated(updatedUser));
        }
      } catch (e) {
        print("DEBUG: AuthCubit error: $e");
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(AuthLoading());
      final success = await _authRepository.changePassword(currentState.user.id, currentPassword, newPassword);
      if (success) {
        // get fresh user and emit
        final fresh = await _authRepository.getCurrentUserById(currentState.user.id);
        if (fresh != null) emit(AuthAuthenticated(fresh));
        return true;
      } else {
        emit(AuthError('Incorrect current password'));
        return false;
      }
    }
    return false;
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
