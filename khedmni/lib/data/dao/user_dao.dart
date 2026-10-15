import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../models/user.dart';

class UserDao {
  final dbHelper = DatabaseHelper.instance;

  // Insert a new user
  Future<int> insertUser(User user) async {
    final db = await dbHelper.database;
    return await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get user by ID
  Future<User?> getUserById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  // Get user by email and password (for login)
  Future<User?> getUserByEmailAndPassword(String email, String password) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    final db = await dbHelper.database;
    final maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromJson(maps[i]));
  }

  // Update user
  Future<int> updateUser(User user) async {
    final db = await dbHelper.database;
    return await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete user
  Future<int> deleteUser(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Update user CV
  Future<int> updateUserCv(String userId, String cvUrl) async {
    final db = await dbHelper.database;
    return await db.update(
      'users',
      {'cvUrl': cvUrl},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
