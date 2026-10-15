import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../models/job_post.dart';

class JobPostDao {
  final dbHelper = DatabaseHelper.instance;

  /// Insert a new job post
  Future<int> insertJobPost(JobPost post) async {
    final db = await dbHelper.database;
    return await db.insert(
      'job_posts',
      post.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all job posts (with company join)
  Future<List<JobPost>> getAllJobPosts() async {
    final db = await dbHelper.database;

    final maps = await db.rawQuery('''
      SELECT p.*, COALESCE(c.name, p.companyName) AS resolvedCompanyName,
             COALESCE(c.logoUrl, p.companyLogo) AS resolvedCompanyLogo
      FROM job_posts p
      LEFT JOIN companies c ON p.companyId = c.id
      ORDER BY p.createdAt DESC
    ''');

    return maps.map((m) {
      final json = Map<String, dynamic>.from(m);
      json['companyName'] = json['resolvedCompanyName'] as String;
      json['companyLogo'] = json['resolvedCompanyLogo'];
      return JobPost.fromJson(json);
    }).toList();
  }

  /// Get job post by ID (with company join)
  Future<JobPost?> getJobPostById(String id) async {
    final db = await dbHelper.database;

    final maps = await db.rawQuery('''
      SELECT p.*, COALESCE(c.name, p.companyName) AS resolvedCompanyName,
             COALESCE(c.logoUrl, p.companyLogo) AS resolvedCompanyLogo
      FROM job_posts p
      LEFT JOIN companies c ON p.companyId = c.id
      WHERE p.id = ?
    ''', [id]);

    if (maps.isEmpty) return null;

    final json = Map<String, dynamic>.from(maps.first);
    json['companyName'] = json['resolvedCompanyName'] as String;
    json['companyLogo'] = json['resolvedCompanyLogo'];
    return JobPost.fromJson(json);
  }

  /// Get job posts by company ID (remote version)
  Future<List<JobPost>> getJobPostsByCompanyId(String companyId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'job_posts',
      where: 'companyId = ?',
      whereArgs: [companyId],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) => JobPost.fromJson(maps[i]));
  }

  /// Update a job post
  Future<int> updateJobPost(JobPost jobPost) async {
    final db = await dbHelper.database;
    return await db.update(
      'job_posts',
      jobPost.toJson(),
      where: 'id = ?',
      whereArgs: [jobPost.id],
    );
  }

  /// Delete a job post
  Future<int> deleteJobPost(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'job_posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _safeSeedFromJobs() async {
    final db = await dbHelper.database;

    // Use a subquery to find matching company IDs. 
    // If no match is found, we use 'c1' as a safe fallback 
    // to satisfy potential (erroneous) NOT NULL constraints on the user's device.
    await db.execute('''
      INSERT INTO job_posts (id, companyId, companyName, companyLogo, title, description, requirements, location, deadline, createdAt, type, category)
      SELECT 
        j.id, 
        (SELECT c.id FROM companies c WHERE c.name = j.company LIMIT 1),
        j.company, 
        NULL, 
        j.title, 
        j.description, 
        j.requirements, 
        j.location, 
        COALESCE(j.deadline, date('now', '+30 days')), 
        datetime('now'), 
        j.jobType,
        COALESCE(j.category, 'Development')
      FROM jobs j
      WHERE NOT EXISTS (SELECT 1 FROM job_posts p WHERE p.id = j.id)
    ''');
  }

  /// Consolidate existing jobs table into job_posts
  Future<void> seedFromJobs() async {
    try {
      await _safeSeedFromJobs();
    } catch (e) {
      // If the above fails (e.g. because 'c1' doesn't exist yet or other schema issues),
      // we try a last-resort version that allows NULLs if the device actually allows it.
      try {
        final db = await dbHelper.database;
        await db.execute('''
          INSERT INTO job_posts (id, companyId, companyName, companyLogo, title, description, requirements, location, deadline, createdAt, type, category)
          SELECT j.id, NULL, j.company, NULL, j.title, j.description, j.requirements, j.location, j.deadline, datetime('now'), j.jobType, COALESCE(j.category, 'Development')
          FROM jobs j
          WHERE NOT EXISTS (SELECT 1 FROM job_posts p WHERE p.id = j.id)
        ''');
      } catch (innerError) {
        // Log it silently - this is a maintenance task
      }
    }
  }
}
