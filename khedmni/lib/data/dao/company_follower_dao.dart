import '../local/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class CompanyFollowerDao {
  final dbHelper = DatabaseHelper.instance;

  Future<void> followCompany(String userId, String companyId) async {
    final db = await dbHelper.database;
    await db.insert('company_followers', {
      'userId': userId,
      'companyId': companyId,
      'followedAt': DateTime.now().toIso8601String(),
    });
    
    // Update company follower count
    await db.rawUpdate('UPDATE companies SET followers = followers + 1 WHERE id = ?', [companyId]);
  }

  Future<void> unfollowCompany(String userId, String companyId) async {
    final db = await dbHelper.database;
    await db.delete('company_followers', 
      where: 'userId = ? AND companyId = ?', 
      whereArgs: [userId, companyId]
    );
    
    // Update company follower count
    await db.rawUpdate('UPDATE companies SET followers = MAX(0, followers - 1) WHERE id = ?', [companyId]);
  }

  Future<bool> isFollowing(String userId, String companyId) async {
    final db = await dbHelper.database;
    final result = await db.query('company_followers', 
      where: 'userId = ? AND companyId = ?', 
      whereArgs: [userId, companyId]
    );
    return result.isNotEmpty;
  }

  Future<List<String>> getFollowedCompanyIds(String userId) async {
    final db = await dbHelper.database;
    final result = await db.query('company_followers', 
      columns: ['companyId'],
      where: 'userId = ?', 
      whereArgs: [userId]
    );
    return result.map((row) => row['companyId'] as String).toList();
  }
  
  Future<int> getFollowerCount(String companyId) async {
     final db = await dbHelper.database;
     final result = await db.rawQuery('SELECT COUNT(*) FROM company_followers WHERE companyId = ?', [companyId]);
     return Sqflite.firstIntValue(result) ?? 0;
  }
}
