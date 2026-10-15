import '../local/database_helper.dart';

class SavedJobDao {
  final dbHelper = DatabaseHelper.instance;

  /// New generic method to save any resource type (e.g., 'job', 'job_post')
  Future<void> saveResource(String userId, String resourceType, String resourceId) async {
    final db = await dbHelper.database;
    await db.insert('saved_jobs', {
      'userId': userId,
      'resourceType': resourceType,
      'resourceId': resourceId,
    });
  }

  /// Backwards-compatible helper for saving legacy jobs
  Future<void> saveJob(String userId, String jobId) async {
    await saveResource(userId, 'job', jobId);
  }

  Future<void> unsaveResource(String userId, String resourceType, String resourceId) async {
    final db = await dbHelper.database;
    await db.delete(
      'saved_jobs',
      where: 'userId = ? AND resourceType = ? AND resourceId = ?',
      whereArgs: [userId, resourceType, resourceId],
    );
  }

  Future<void> unsaveJob(String userId, String jobId) async {
    await unsaveResource(userId, 'job', jobId);
  }

  Future<bool> isResourceSaved(String userId, String resourceType, String resourceId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'saved_jobs',
      where: 'userId = ? AND resourceType = ? AND resourceId = ?',
      whereArgs: [userId, resourceType, resourceId],
    );
    return result.isNotEmpty;
  }

  Future<bool> isJobSaved(String userId, String jobId) async {
    return await isResourceSaved(userId, 'job', jobId);
  }

  /// Returns saved resourceIds for resourceType='job' to keep compatibility with existing UI
  Future<List<String>> getSavedJobIds(String userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'saved_jobs',
      columns: ['resourceId'],
      where: 'userId = ? AND resourceType = ?',
      whereArgs: [userId, 'job'],
    );
    return result.map((row) => row['resourceId'] as String).toList();
  }

  /// Returns all saved resources with their type for a user
  Future<List<Map<String, dynamic>>> getSavedResources(String userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'saved_jobs',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'resourceType',
    );
    return result;
  }
}
