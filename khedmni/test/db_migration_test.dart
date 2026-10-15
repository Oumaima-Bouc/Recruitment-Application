import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:khedmni/data/local/database_helper.dart';

void main() {
  setUpAll(() async {
    // Initialize FFI for tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Ensure test DB directory exists
    final dbPath = await databaseFactory.getDatabasesPath();
    Directory(dbPath).createSync(recursive: true);
  });

  test('migration v8 -> v9 migrates saved_jobs and consolidates jobs into job_posts', () async {
    final dbPath = await databaseFactory.getDatabasesPath();
    final file = p.join(dbPath, 'khedmni.db');

    // If a preexisting DB exists from other tests, delete it
    if (File(file).existsSync()) {
      File(file).deleteSync();
    }

    // 1) Create a legacy v8 DB with old saved_jobs (userId, jobId) and jobs table
    final legacyDb = await databaseFactory.openDatabase(
      file,
      options: OpenDatabaseOptions(version: 8, onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            userType TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');

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

    // Insert a user, a job and a saved job
    await legacyDb.insert('users', {'id': 'u_test', 'name': 'Tester', 'email': 't@test.com', 'password': 'p', 'userType': 'student', 'createdAt': DateTime.now().toIso8601String()});
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
    await legacyDb.insert('saved_jobs', {'userId': 'u_test', 'jobId': 'job_legacy_1'});

    await legacyDb.close();

    // 2) Now open using DatabaseHelper which uses version 9 and should run the migration
    final db = await DatabaseHelper.instance.database;

    // 3) Check saved_jobs schema and data migrated
    final saved = await db.query('saved_jobs', where: 'userId = ?', whereArgs: ['u_test']);
    expect(saved.length, 1);
    expect(saved.first['resourceType'], 'job');
    expect(saved.first['resourceId'], 'job_legacy_1');

    // 4) Check job_posts contains the legacy job (consolidated)
    final posts = await db.query('job_posts', where: 'id = ?', whereArgs: ['job_legacy_1']);
    expect(posts.length, 1);
    expect(posts.first['title'], 'Legacy Role');

    // Cleanup created DB
    await db.close();
    if (File(file).existsSync()) File(file).deleteSync();
  });
}
