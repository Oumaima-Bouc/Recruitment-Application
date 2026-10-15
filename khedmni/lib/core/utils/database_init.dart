import '../../data/local/database_helper.dart';

/// Initialize and seed the database on app startup
/// Call this method in main.dart before runApp()
Future<void> initializeDatabase() async {
  final dbHelper = DatabaseHelper.instance;
  
  // Ensure database is created
  await dbHelper.database;
  
  // Seed database if needed (only runs on first launch)
  await dbHelper.seedDatabaseIfNeeded();
}

/// Force reseed the database (useful for development/testing)
/// WARNING: This will delete existing data and reseed
Future<void> resetDatabase() async {
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.forceReseedDatabase();
}
