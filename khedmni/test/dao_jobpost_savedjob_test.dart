import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:khedmni/data/dao/job_post_dao.dart';
import 'package:khedmni/data/dao/saved_job_dao.dart';
import 'package:khedmni/data/local/database_helper.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Remove test DB if exists
    final dbPath = await databaseFactory.getDatabasesPath();
    final file = '$dbPath/khedmni.db';
    final f = File(file);
    if (await f.exists()) await f.delete();
  });

  test('JobPostDao returns joined company fields and SavedJobDao stores resources', () async {
    final db = await DatabaseHelper.instance.database;

    // Insert a company
    await db.insert('companies', {
      'id': 'comp1',
      'name': 'Joined Co',
      'email': 'a@b.com',
      'industry': 'Tech',
      'website': 'x',
      'description': 'd',
      'contact': 'c',
      'logoUrl': 'logo.png'
    });

    // Insert a job_post that references companyId
    await db.insert('job_posts', {
      'id': 'jp1',
      'companyId': 'comp1',
      'companyName': 'Legacy Name',
      'companyLogo': null,
      'title': 'Test Job',
      'description': 'desc',
      'requirements': '[]',
      'location': 'Rabat',
      'deadline': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'type': 'Full-time'
    });

    final jobPostDao = JobPostDao();
    final posts = await jobPostDao.getAllJobPosts();
    expect(posts.any((p) => p.id == 'jp1'), isTrue);

    final jp = await jobPostDao.getJobPostById('jp1');
    expect(jp, isNotNull);
    // companyName should resolve to the company table value via JOIN
    expect(jp!.companyName, 'Joined Co');

    // Test SavedJobDao
    final saved = SavedJobDao();
    await saved.saveResource('u1', 'job_post', 'jp1');
    final resources = await saved.getSavedResources('u1');
    expect(resources.length, 1);
    expect(resources.first['resourceType'], 'job_post');
    expect(resources.first['resourceId'], 'jp1');

    // Cleanup
    await DatabaseHelper.instance.close();
  });

  test('JobPostDao handles missing company and SavedJobDao resource helpers', () async {
    final dbPath = await databaseFactory.getDatabasesPath();
    final file = '$dbPath/khedmni.db';

    // Ensure a fresh database for this test
    final f = File(file);
    if (await f.exists()) await f.delete();

    final db = await DatabaseHelper.instance.database;

    // Insert a job_post with non-existing companyId but with companyName present
    await db.insert('job_posts', {
      'id': 'jp_missing_company',
      'companyId': 'missing_comp',
      'companyName': 'Legacy Name',
      'companyLogo': null,
      'title': 'Orphaned Job',
      'description': 'desc',
      'requirements': '[]',
      'location': 'Rabat',
      'deadline': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'type': 'Part-time'
    });

    // Insert a job_post with null companyId and companyName set
    await db.insert('job_posts', {
      'id': 'jp_no_company',
      'companyId': null,
      'companyName': 'NoCo',
      'companyLogo': null,
      'title': 'No Co Job',
      'description': 'desc',
      'requirements': '[]',
      'location': 'Casablanca',
      'deadline': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'type': 'Contract'
    });

    final jobPostDao = JobPostDao();

    final orphan = await jobPostDao.getJobPostById('jp_missing_company');
    expect(orphan, isNotNull);
    expect(orphan!.companyName, 'Legacy Name');

    final noc = await jobPostDao.getJobPostById('jp_no_company');
    expect(noc, isNotNull);
    expect(noc!.companyName, 'NoCo');

    // SavedJobDao resource helpers
    final saved = SavedJobDao();
    await saved.saveResource('u2', 'job_post', 'jp_missing_company');
    expect(await saved.isResourceSaved('u2', 'job_post', 'jp_missing_company'), isTrue);

    await saved.unsaveResource('u2', 'job_post', 'jp_missing_company');
    expect(await saved.isResourceSaved('u2', 'job_post', 'jp_missing_company'), isFalse);

    await saved.saveJob('u3', 'legacy_job_1');
    expect(await saved.isJobSaved('u3', 'legacy_job_1'), isTrue);
    final ids = await saved.getSavedJobIds('u3');
    expect(ids, contains('legacy_job_1'));

    // Cleanup
    await DatabaseHelper.instance.close();
    if (await f.exists()) await f.delete();
  });
}
