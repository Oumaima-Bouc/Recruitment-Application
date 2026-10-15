import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:khedmni/data/local/database_helper.dart';
import 'package:khedmni/data/dao/job_post_dao.dart';

void main() {
  setUpAll(() async {
    // Initialize FFI for tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Ensure test DB directory exists
    final dbPath = await databaseFactory.getDatabasesPath();
    Directory(dbPath).createSync(recursive: true);
  });

  test('seedFromJobs is idempotent and does not duplicate job_posts', () async {
    final dbPath = await databaseFactory.getDatabasesPath();
    final file = p.join(dbPath, 'khedmni.db');

    // Clean up any previous DB
    if (File(file).existsSync()) File(file).deleteSync();

    // 1) Create a legacy v8 DB with jobs table
    final legacyDb = await databaseFactory.openDatabase(
      file,
      options: OpenDatabaseOptions(version: 8, onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE jobs (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            company TEXT NOT NULL,
            location TEXT NOT NULL,
            salary TEXT NOT NULL,
            description TEXT NOT NULL,
            requirements TEXT NOT NULL,
            postedDate TEXT NOT NULL,
            jobType TEXT NOT NULL,
            deadline TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE saved_jobs (
            userId TEXT NOT NULL,
            jobId TEXT NOT NULL,
            PRIMARY KEY (userId, jobId)
          )
        ''');
      }),
    );

    // Insert a legacy job
    await legacyDb.insert('jobs', {
      'id': 'job_legacy_1',
      'title': 'Legacy Role',
      'company': 'Legacy Co',
      'location': 'Nowhere',
      'salary': '0',
      'description': 'Old job',
      'requirements': '[]',
      'postedDate': DateTime.now().toIso8601String(),
      'jobType': 'Full-time',
      'deadline': DateTime.now().toIso8601String(),
    });

    await legacyDb.close();

    // 2) Open using DatabaseHelper (migration runs)
    final db = await DatabaseHelper.instance.database;

    // 3) Call seedFromJobs twice to assert idempotency
    final postDao = JobPostDao();
    await postDao.seedFromJobs();
    await postDao.seedFromJobs();

    final posts = await db.query('job_posts', where: 'id = ?', whereArgs: ['job_legacy_1']);
    expect(posts.length, 1, reason: 'seedFromJobs should not duplicate job_posts when run multiple times');

    await db.close();
    if (File(file).existsSync()) File(file).deleteSync();
  });
}
