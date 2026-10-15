import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:khedmni/data/local/database_helper.dart';
import 'package:khedmni/data/repositories/job_repository.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await databaseFactory.getDatabasesPath();
    final file = '$dbPath/khedmni.db';
    final f = File(file);
    if (await f.exists()) await f.delete();
  });

  test('JobRepository prefers job_posts and returns converted Job objects', () async {
    final db = await DatabaseHelper.instance.database;

    // Insert a company and job_post
    await db.insert('companies', {
      'id': 'cmp2',
      'name': 'RepoCo',
      'email': 'r@c.com',
      'industry': 'Tech',
      'website': 'x',
      'description': 'd',
      'contact': 'c',
      'logoUrl': 'logo.png'
    });

    await db.insert('job_posts', {
      'id': 'jp_repo1',
      'companyId': 'cmp2',
      'companyName': 'RepoCo Legacy',
      'companyLogo': null,
      'title': 'Repo Job',
      'description': 'desc',
      'requirements': 'a|b',
      'location': 'Casablanca',
      'deadline': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'type': 'Full-time'
    });

    final repo = JobRepository();
    final jobs = await repo.getAllJobs();
    expect(jobs.any((j) => j.id == 'jp_repo1'), isTrue);

    final job = await repo.getJobById('jp_repo1');
    expect(job, isNotNull);
    expect(job!.company, 'RepoCo'); // from companies table via JOIN takes precedence

    await DatabaseHelper.instance.close();
  });
}
