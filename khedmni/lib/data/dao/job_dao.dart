import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../models/job.dart';

class JobDao {
  final dbHelper = DatabaseHelper.instance;

  /// Insert a new job
  Future<int> insertJob(Job job) async {
    final db = await dbHelper.database;
    
    // Convert Job to Map
    final jobMap = {
      'id': job.id,
      'title': job.title,
      'company': job.company,
      'location': job.location,
      'salary': job.salary,
      'description': job.description,
      'requirements': job.requirements.join('|'), // Store as pipe-separated string
      'postedDate': job.postedDate,
      'jobType': job.jobType,
      'category': job.category,
      'deadline': job.deadline.toIso8601String(),
    };
    
    return await db.insert(
      'jobs',
      jobMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all jobs
  Future<List<Job>> getAllJobs() async {
    final db = await dbHelper.database;
    final maps = await db.query('jobs', orderBy: 'postedDate DESC');
    
    return List.generate(maps.length, (i) {
      return Job(
        id: (maps[i]['id'] ?? '') as String,
        title: (maps[i]['title'] ?? 'Untitled') as String,
        company: (maps[i]['company'] ?? 'Unknown Company') as String,
        location: (maps[i]['location'] ?? 'Remote') as String,
        salary: (maps[i]['salary'] ?? 'Not specified') as String,
        description: (maps[i]['description'] ?? 'No description provided') as String,
        requirements: (maps[i]['requirements'] as String?)?.split('|') ?? [],
        postedDate: (maps[i]['postedDate'] ?? 'Recently') as String,
        jobType: (maps[i]['jobType'] ?? 'Full-time') as String,
        category: (maps[i]['category'] ?? 'IT & Tech') as String,
        deadline: maps[i]['deadline'] != null 
            ? DateTime.parse(maps[i]['deadline'] as String)
            : DateTime.now().add(const Duration(days: 30)),
      );
    });
  }

  /// Get job by ID
  Future<Job?> getJobById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'jobs',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return Job(
        id: (map['id'] ?? '') as String,
        title: (map['title'] ?? 'Untitled') as String,
        company: (map['company'] ?? 'Unknown Company') as String,
        location: (map['location'] ?? 'Remote') as String,
        salary: (map['salary'] ?? 'Not specified') as String,
        description: (map['description'] ?? 'No description provided') as String,
        requirements: (map['requirements'] as String?)?.split('|') ?? [],
        postedDate: (map['postedDate'] ?? 'Recently') as String,
        jobType: (map['jobType'] ?? 'Full-time') as String,
        category: (map['category'] ?? 'IT & Tech') as String,
        deadline: map['deadline'] != null 
            ? DateTime.parse(map['deadline'] as String)
            : DateTime.now().add(const Duration(days: 30)),
      );
    }
    return null;
  }

  /// Search jobs by title or company
  Future<List<Job>> searchJobs(String query) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'jobs',
      where: 'title LIKE ? OR company LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'postedDate DESC',
    );

    return List.generate(maps.length, (i) {
      return Job(
        id: (maps[i]['id'] ?? '') as String,
        title: (maps[i]['title'] ?? 'Untitled') as String,
        company: (maps[i]['company'] ?? 'Unknown Company') as String,
        location: (maps[i]['location'] ?? 'Remote') as String,
        salary: (maps[i]['salary'] ?? 'Not specified') as String,
        description: (maps[i]['description'] ?? 'No description provided') as String,
        requirements: (maps[i]['requirements'] as String?)?.split('|') ?? [],
        postedDate: (maps[i]['postedDate'] ?? 'Recently') as String,
        jobType: (maps[i]['jobType'] ?? 'Full-time') as String,
        category: (maps[i]['category'] ?? 'IT & Tech') as String,
        deadline: maps[i]['deadline'] != null 
            ? DateTime.parse(maps[i]['deadline'] as String)
            : DateTime.now().add(const Duration(days: 30)),
      );
    });
  }

  /// Filter jobs by type
  Future<List<Job>> getJobsByType(String jobType) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'jobs',
      where: 'jobType = ?',
      whereArgs: [jobType],
      orderBy: 'postedDate DESC',
    );

    return List.generate(maps.length, (i) {
      return Job(
        id: (maps[i]['id'] ?? '') as String,
        title: (maps[i]['title'] ?? 'Untitled') as String,
        company: (maps[i]['company'] ?? 'Unknown Company') as String,
        location: (maps[i]['location'] ?? 'Remote') as String,
        salary: (maps[i]['salary'] ?? 'Not specified') as String,
        description: (maps[i]['description'] ?? 'No description provided') as String,
        requirements: (maps[i]['requirements'] as String?)?.split('|') ?? [],
        postedDate: (maps[i]['postedDate'] ?? 'Recently') as String,
        jobType: (maps[i]['jobType'] ?? 'Full-time') as String,
        category: (maps[i]['category'] ?? 'IT & Tech') as String,
        deadline: maps[i]['deadline'] != null 
            ? DateTime.parse(maps[i]['deadline'] as String)
            : DateTime.now().add(const Duration(days: 30)),
      );
    });
  }

  /// Delete a job
  Future<int> deleteJob(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'jobs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all jobs
  Future<int> deleteAllJobs() async {
    final db = await dbHelper.database;
    return await db.delete('jobs');
  }

  /// Seed jobs (insert multiple jobs at once)
  Future<void> seedJobs(List<Job> jobs) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    
    for (var job in jobs) {
      final jobMap = {
        'id': job.id,
        'title': job.title,
        'company': job.company,
        'location': job.location,
        'salary': job.salary,
        'description': job.description,
        'requirements': job.requirements.join('|'),
        'postedDate': job.postedDate,
        'jobType': job.jobType,
        'category': job.category,
        'deadline': job.deadline.toIso8601String(),
      };
      batch.insert('jobs', jobMap, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit(noResult: true);
  }
}
