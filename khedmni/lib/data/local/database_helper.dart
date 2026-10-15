import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dao/user_dao.dart';
import '../dao/job_dao.dart';
import '../dao/company_dao.dart';
import '../dao/notification_dao.dart';
import '../dao/job_post_dao.dart';
// import '../dummy_data.dart'; // Removed dummy data import

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    // If we have a cached DB reference, ensure it's still open; otherwise re-open
    if (_database != null) {
      try {
        await _database!.getVersion(); // will throw if database is closed
        return _database!;
      } catch (e) {
        _database = null;
      }
    }

    _database = await _initDB('khedmni.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 16,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      singleInstance: false,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN photoUrl TEXT');
      } catch (_) {}
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN title TEXT');
      } catch (_) {}
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE saved_jobs (
          userId TEXT NOT NULL,
          jobId TEXT NOT NULL,
          PRIMARY KEY (userId, jobId),
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (jobId) REFERENCES jobs (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN cvUrl TEXT');
      } catch (_) {}
    }
    if (oldVersion < 6) {
      // Add deadline column to jobs table
      // SQLite does not support adding NOT NULL columns with no default value easily in ALTER TABLE.
      // So we add it as nullable or with default. TEXT is nullable by default.
      await db.execute('ALTER TABLE jobs ADD COLUMN deadline TEXT');
    }
    if (oldVersion < 7) {
      // Add followers column to companies table
      await db.execute(
        'ALTER TABLE companies ADD COLUMN followers INTEGER DEFAULT 0',
      );
    }
    if (oldVersion < 8) {
      // Add email verification fields to users table
      try {
        await db.execute(
          'ALTER TABLE users ADD COLUMN isEmailVerified INTEGER DEFAULT 0',
        );
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE users ADD COLUMN emailVerificationToken TEXT',
        );
      } catch (_) {}
    }

    // Version 9: Normalize job_posts and update saved_jobs schema to support multiple resource types
    if (oldVersion < 9) {
      // 1) Migrate saved_jobs to include resourceType/resourceId
      // Create new table with resourceType and resourceId
      await db.execute('''
        CREATE TABLE saved_jobs_new (
          userId TEXT NOT NULL,
          resourceType TEXT NOT NULL,
          resourceId TEXT NOT NULL,
          PRIMARY KEY (userId, resourceType, resourceId),
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      // Copy existing saves (assumes old schema had jobId referencing jobs)
      await db.execute('''
        INSERT INTO saved_jobs_new (userId, resourceType, resourceId)
        SELECT userId, 'job', jobId FROM saved_jobs
      ''');

      // Drop old table
      await db.execute('DROP TABLE IF EXISTS saved_jobs');

      // Rename new table
      await db.execute('ALTER TABLE saved_jobs_new RENAME TO saved_jobs');

      // 2) Normalize job_posts and consolidate old jobs into job_posts
      // Create a new job_posts table allowing nullable companyId so we can copy legacy data
      await db.execute('''
        CREATE TABLE job_posts_new (
          id TEXT PRIMARY KEY,
          companyId TEXT,
          companyName TEXT NOT NULL,
          companyLogo TEXT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          requirements TEXT NOT NULL,
          location TEXT NOT NULL,
          deadline TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          type TEXT NOT NULL,
          FOREIGN KEY (companyId) REFERENCES companies (id)
        )
      ''');

      // Copy existing job_posts into new table (keeping companyId/companyName)
      final existingJobPosts = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='job_posts'",
      );
      if (existingJobPosts.isNotEmpty) {
        await db.execute('''
          INSERT INTO job_posts_new (id, companyId, companyName, companyLogo, title, description, requirements, location, deadline, createdAt, type)
          SELECT id, companyId, companyName, companyLogo, title, description, requirements, location, deadline, createdAt, type FROM job_posts
        ''');
      } else {
        // No existing job_posts table (legacy DB). We'll rely on consolidating jobs below.
      }

      // Consolidate legacy jobs into job_posts_new
      // For jobs where a job_posts with same id doesn't exist, insert a job_post row using jobs data
      await db.execute('''
        INSERT INTO job_posts_new (id, companyId, companyName, companyLogo, title, description, requirements, location, deadline, createdAt, type)
        SELECT 
          j.id, 
          COALESCE((SELECT c.id FROM companies c WHERE c.name = j.company LIMIT 1), NULL) as companyId, 
          j.company as companyName, 
          NULL as companyLogo, 
          j.title, 
          j.description, 
          j.requirements, 
          j.location, 
          COALESCE(j.deadline, date('now', '+30 days')) AS deadline,
          datetime('now') as createdAt, 
          j.jobType as type
        FROM jobs j
        WHERE NOT EXISTS (SELECT 1 FROM job_posts_new p WHERE p.id = j.id)
      ''');

      // Drop old job_posts and rename new
      await db.execute('DROP TABLE IF EXISTS job_posts');
      await db.execute('ALTER TABLE job_posts_new RENAME TO job_posts');

      // Note: We keep the old jobs table for backward compatibility. In a future migration we can drop it after updating repositories.
    }
    if (oldVersion < 10) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN cvLastUpdated TEXT');
      } catch (e) {
        developer.log(
          '⚠️ cvLastUpdated column may already exist: $e',
          name: 'database_helper.onUpgrade',
        );
      }
    }
    if (oldVersion < 11) {
      // Create applications table if it doesn't exist
      await db.execute('''
        CREATE TABLE IF NOT EXISTS applications (
          id TEXT PRIMARY KEY,
          job_post_id TEXT,
          job_id TEXT,
          student_id TEXT NOT NULL,
          student_name TEXT,
          student_email TEXT,
          student_avatar TEXT,
          cover_letter TEXT,
          resume_url TEXT,
          applied_at TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending'
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_applications_job_post_id ON applications (job_post_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_applications_job_id ON applications (job_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_applications_student_id ON applications (student_id)',
      );
    }

    if (oldVersion < 12) {
      // Fix for "NOT NULL constraint failed: job_posts.companyId"
      // Recreate job_posts table ensuring companyId is nullable
      await db.execute('PRAGMA foreign_keys=OFF');
      await db.execute('''
        CREATE TABLE job_posts_fix (
          id TEXT PRIMARY KEY,
          companyId TEXT,
          companyName TEXT NOT NULL,
          companyLogo TEXT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          requirements TEXT NOT NULL,
          location TEXT NOT NULL,
          deadline TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          type TEXT NOT NULL,
          FOREIGN KEY (companyId) REFERENCES companies (id)
        )
      ''');

      try {
        await db.execute('''
          INSERT INTO job_posts_fix (id, companyId, companyName, companyLogo, title, description, requirements, location, deadline, createdAt, type)
          SELECT id, companyId, companyName, companyLogo, title, description, requirements, location, deadline, createdAt, type FROM job_posts
        ''');
      } catch (e) {
        developer.log(
          '⚠️ Error migrating data to job_posts_fix: $e',
          name: 'database_helper.onUpgrade',
        );
      }

      await db.execute('DROP TABLE IF EXISTS job_posts');
      await db.execute('ALTER TABLE job_posts_fix RENAME TO job_posts');
      await db.execute('PRAGMA foreign_keys=ON');
    }

    if (oldVersion < 13) {
      // Fix for "saved_jobs has no column named resourceType"
      // Recreate saved_jobs table with correct schema
      await db.execute('PRAGMA foreign_keys=OFF');

      // Keep old data if possible
      final oldTables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='saved_jobs'",
      );
      List<Map<String, dynamic>> oldData = [];
      if (oldTables.isNotEmpty) {
        try {
          oldData = await db.query('saved_jobs');
        } catch (e) {
          developer.log('⚠️ Could not read old saved_jobs data: $e');
        }
      }

      await db.execute('DROP TABLE IF EXISTS saved_jobs');
      await db.execute('''
        CREATE TABLE saved_jobs (
          userId TEXT NOT NULL,
          resourceType TEXT NOT NULL,
          resourceId TEXT NOT NULL,
          PRIMARY KEY (userId, resourceType, resourceId),
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      // Attempt to restore data, mapping potential legacy columns
      for (var row in oldData) {
        try {
          final uId = row['userId'] ?? row['userld'];
          final rType = row['resourceType'] ?? row['resource Type'] ?? 'job';
          final rId = row['resourceId'] ?? row['resourceld'] ?? row['jobId'];

          if (uId != null && rId != null) {
            await db.insert('saved_jobs', {
              'userId': uId,
              'resourceType': rType,
              'resourceId': rId,
            });
          }
        } catch (_) {}
      }

      await db.execute('PRAGMA foreign_keys=ON');
    }

    if (oldVersion < 14) {
      // Add company_followers table - check if it exists first
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='company_followers'",
      );

      if (tables.isEmpty) {
        await db.execute('''
          CREATE TABLE company_followers (
            userId TEXT NOT NULL,
            companyId TEXT NOT NULL,
            followedAt TEXT NOT NULL,
            PRIMARY KEY (userId, companyId),
            FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
            FOREIGN KEY (companyId) REFERENCES companies (id) ON DELETE CASCADE
          )
        ''');
        developer.log(
          '✅ Created company_followers table',
          name: 'database_helper.onUpgrade',
        );
      } else {
        developer.log(
          'ℹ️ company_followers table already exists, skipping creation',
          name: 'database_helper.onUpgrade',
        );
      }
    }

    if (oldVersion < 15) {
      try {
        await db.execute(
          'ALTER TABLE jobs ADD COLUMN category TEXT DEFAULT "Development"',
        );
        await db.execute(
          'ALTER TABLE job_posts ADD COLUMN category TEXT DEFAULT "Development"',
        );
      } catch (e) {
        developer.log(
          '⚠️ category column may already exist: $e',
          name: 'database_helper.onUpgrade',
        );
      }
    }
    // ⭐ NEW: Add company verification columns
    if (oldVersion < 9) {
      await db.execute(
        'ALTER TABLE companies ADD COLUMN isVerified INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE companies ADD COLUMN verificationDocs TEXT DEFAULT ""',
      );
      developer.log(
        '✅ Added verification columns to companies table',
        name: 'database_helper._onUpgrade',
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // User Table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        userType TEXT NOT NULL,
        phone TEXT,
        location TEXT,
        skills TEXT,
        bio TEXT,
        title TEXT,
        cvUrl TEXT,
        photoUrl TEXT,
        isEmailVerified INTEGER DEFAULT 0,
        emailVerificationToken TEXT,
        cvLastUpdated TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Job Table
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
        category TEXT NOT NULL,
        deadline TEXT NOT NULL
      )
    ''');

    // Company Table - ⭐ UPDATED: Added isVerified and verificationDocs
    await db.execute('''
      CREATE TABLE companies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        industry TEXT NOT NULL,
        website TEXT NOT NULL,
        description TEXT NOT NULL,
        contact TEXT NOT NULL,
        logoUrl TEXT,
        followers INTEGER DEFAULT 0,
        isVerified INTEGER DEFAULT 0,
        verificationDocs TEXT DEFAULT ""
      )
    ''');

    // JobPost Table (for company posted jobs) - companyId is nullable to allow legacy migrations
    await db.execute('''
      CREATE TABLE job_posts (
        id TEXT PRIMARY KEY,
        companyId TEXT,
        companyName TEXT NOT NULL,
        companyLogo TEXT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        requirements TEXT NOT NULL,
        location TEXT NOT NULL,
        deadline TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        FOREIGN KEY (companyId) REFERENCES companies (id)
      )
    ''');

    // Notifications Table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        type TEXT NOT NULL,
        relatedId TEXT
      )
    ''');

    // Saved Jobs Table - supports multiple resource types (e.g., 'job', 'job_post')
    await db.execute('''
      CREATE TABLE saved_jobs (
        userId TEXT NOT NULL,
        resourceType TEXT NOT NULL,
        resourceId TEXT NOT NULL,
        PRIMARY KEY (userId, resourceType, resourceId),
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Applications Table
    await db.execute('''
      CREATE TABLE applications (
        id TEXT PRIMARY KEY,
        job_post_id TEXT,
        job_id TEXT,
        student_id TEXT NOT NULL,
        student_name TEXT,
        student_email TEXT,
        student_avatar TEXT,
        cover_letter TEXT,
        resume_url TEXT,
        applied_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_applications_job_post_id ON applications (job_post_id)',
    );
    await db.execute(
      'CREATE INDEX idx_applications_job_id ON applications (job_id)',
    );
    await db.execute(
      'CREATE INDEX idx_applications_student_id ON applications (student_id)',
    );

    // Company Followers Table
    await db.execute('''
      CREATE TABLE company_followers (
        userId TEXT NOT NULL,
        companyId TEXT NOT NULL,
        followedAt TEXT NOT NULL,
        PRIMARY KEY (userId, companyId),
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (companyId) REFERENCES companies (id) ON DELETE CASCADE
      )
    ''');

    developer.log(
      '✅ Database tables created successfully',
      name: 'database_helper._createDB',
    );
  }

  /// Seed the database with dummy data on first launch
  /// (DISABLED - Dummy data removed)
  Future<void> seedDatabaseIfNeeded() async {
    developer.log(
      'ℹ️ Seeding disabled.',
      name: 'database_helper.seedDatabaseIfNeeded',
    );
  }

  /// (DISABLED - Dummy data removed)
  Future<void> seedDatabase() async {
    try {
      // Initialize DAOs
      final jobDao = JobDao();
      final companyDao = CompanyDao();
      final notificationDao = NotificationDao();

      // TODO: Add dummy data definitions (dummyUsers, dummyCompanies, dummyJobs, dummyNotifications)
      // Seeding code commented out until dummy data is defined

      // // Seed Users
      // developer.log(
      //   '  → Seeding users...',
      //   name: 'database_helper.seedDatabase',
      // );
      // final userDao = UserDao();
      // for (var user in dummyUsers) {
      //   await userDao.insertUser(user);
      // }
      // developer.log(
      //   '  ✔ ${dummyUsers.length} users seeded',
      //   name: 'database_helper.seedDatabase',
      // );

      // // Seed Companies
      // developer.log(
      //   '  → Seeding companies...',
      //   name: 'database_helper.seedDatabase',
      // );
      // await companyDao.seedCompanies(dummyCompanies);
      // developer.log(
      //   '  ✔ ${dummyCompanies.length} companies seeded',
      //   name: 'database_helper.seedDatabase',
      // );

      // // Seed Jobs
      // developer.log(
      //   '  → Seeding jobs...',
      //   name: 'database_helper.seedDatabase',
      // );
      // await jobDao.seedJobs(dummyJobs);
      // developer.log(
      //   '  ✔ ${dummyJobs.length} jobs seeded',
      //   name: 'database_helper.seedDatabase',
      // );

      // // Seed Notifications
      // developer.log(
      //   '  → Seeding notifications...',
      //   name: 'database_helper.seedDatabase',
      // );
      // await notificationDao.seedNotifications(dummyNotifications);
      // developer.log(
      //   '  ✔ ${dummyNotifications.length} notifications seeded',
      //   name: 'database_helper.seedDatabase',
      // );
    } catch (e, st) {
      developer.log(
        '❌ Error seeding database: $e',
        name: 'database_helper.seedDatabase',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
    developer.log('ℹ️ Seeding disabled.', name: 'database_helper.seedDatabase');
  }

  /// Force reseed the database (useful for development/testing)
  /// This will clear the seeded flag and reseed all data
  Future<void> forceReseedDatabase() async {
    final jobDao = JobDao();
    final notificationDao = NotificationDao();

    await jobDao.deleteAllJobs();
    await notificationDao.deleteAllNotifications();

    developer.log(
      'ℹ️ Force reseed called but dummy data is removed.',
      name: 'database_helper.forceReseedDatabase',
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
