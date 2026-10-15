import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../models/company.dart';

class CompanyDao {
  final dbHelper = DatabaseHelper.instance;

  /// Insert a new company
  Future<int> insertCompany(Company company) async {
    final db = await dbHelper.database;
    return await db.insert(
      'companies',
      company.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get company by ID
  Future<Company?> getCompanyById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Company.fromJson(maps.first);
    }
    return null;
  }

  /// Get company by email
  Future<Company?> getCompanyByEmail(String email) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'companies',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return Company.fromJson(maps.first);
    }
    return null;
  }

  /// Get company by name
  Future<Company?> getCompanyByName(String name) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'companies',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return Company.fromJson(maps.first);
    }
    return null;
  }

  /// Get all companies
  Future<List<Company>> getAllCompanies() async {
    final db = await dbHelper.database;
    final maps = await db.query('companies');
    return List.generate(maps.length, (i) => Company.fromJson(maps[i]));
  }

  // ⭐ NEW: Get all verified companies
  Future<List<Company>> getVerifiedCompanies() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'companies',
      where: 'isVerified = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      return Company.fromJson(maps[i]);
    });
  }

  // ⭐ NEW: Get all unverified companies (pending verification)
  Future<List<Company>> getUnverifiedCompanies() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'companies',
      where: 'isVerified = ? AND verificationDocs != ?',
      whereArgs: [0, ''],
    );

    return List.generate(maps.length, (i) {
      return Company.fromJson(maps[i]);
    });
  }

  /// Update company
  Future<int> updateCompany(Company company) async {
    final db = await dbHelper.database;
    return await db.update(
      'companies',
      company.toJson(),
      where: 'id = ?',
      whereArgs: [company.id],
    );
  }

  // ⭐ NEW: Update company verification status
  Future<int> updateVerificationStatus(String companyId, bool isVerified) async {
    final db = await dbHelper.database;
    return await db.update(
      'companies',
      {'isVerified': isVerified ? 1 : 0},
      where: 'id = ?',
      whereArgs: [companyId],
    );
  }

  /// Delete company
  Future<int> deleteCompany(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Seed companies (insert multiple companies at once)
  Future<void> seedCompanies(List<Company> companies) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    
    for (var company in companies) {
      batch.insert('companies', company.toJson(), 
        conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit(noResult: true);
  }

  // ⭐ NEW: Check if company exists
  Future<bool> companyExists(String email) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'companies',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }
}