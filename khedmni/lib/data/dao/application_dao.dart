import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../models/application.dart';

class ApplicationDao {
  final dbHelper = DatabaseHelper.instance;

  /// Insert a new application
  Future<int> insertApplication(Application application) async {
    final db = await dbHelper.database;
    return await db.insert(
      'applications',
      application.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get applications for a specific job post (company view)
  Future<List<Application>> getApplicationsByJobPostId(String jobPostId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'applications',
      where: 'job_post_id = ?',
      whereArgs: [jobPostId],
      orderBy: 'applied_at DESC',
    );
    return List.generate(maps.length, (i) => Application.fromJson(maps[i]));
  }

  /// Get applications for a specific job (company view)
  Future<List<Application>> getApplicationsByJobId(String jobId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'applications',
      where: 'job_id = ?',
      whereArgs: [jobId],
      orderBy: 'applied_at DESC',
    );
    return List.generate(maps.length, (i) => Application.fromJson(maps[i]));
  }

  /// Get all applications (e.g., for a student)
  Future<List<Application>> getApplicationsByStudentId(String studentId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'applications',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'applied_at DESC',
    );
    return List.generate(maps.length, (i) => Application.fromJson(maps[i]));
  }

  /// Update application status
  Future<int> updateApplicationStatus(String id, String status) async {
    final db = await dbHelper.database;
    return await db.update(
      'applications',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete an application
  Future<int> deleteApplication(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'applications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  /// Search applications by student name or status
  Future<List<Application>> searchApplications(String query) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'applications',
      where: 'student_name LIKE ? OR status LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'applied_at DESC',
    );
    return List.generate(maps.length, (i) => Application.fromJson(maps[i]));
  }
}

