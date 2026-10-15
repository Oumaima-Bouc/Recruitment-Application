import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

Future<int> _previewMatches(DatabaseFactory dbFactory, String dbPath, String email) async {
  final db = await dbFactory.openDatabase(dbPath);
  try {
    final rows = await db.rawQuery('SELECT id, name, email, createdAt FROM users WHERE email = ?', [email]);
    if (rows.isEmpty) {
      print('No users found with email: $email');
      return 0;
    }

    print('Found ${rows.length} user(s) with email: $email');
    for (var r in rows) {
      print('- id: ${r['id']}, name: ${r['name']}, email: ${r['email']}, createdAt: ${r['createdAt']}');
    }
    return rows.length;
  } finally {
    await db.close();
  }
}

Future<int> _deleteMatches(DatabaseFactory dbFactory, String dbPath, String email) async {
  final db = await dbFactory.openDatabase(dbPath);
  try {
    final count = await db.rawDelete('DELETE FROM users WHERE email = ?', [email]);
    return count;
  } finally {
    await db.close();
  }
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run tools/delete_users_by_email.dart <email> [--delete]');
    exit(1);
  }

  final email = args[0];
  final shouldDelete = args.contains('--delete') || args.contains('-d');

  // Initialize ffi for desktop scripts
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Try to locate database file using getDatabasesPath()
  String dbPath = '';
  try {
    final dbDir = await databaseFactory.getDatabasesPath();
    dbPath = p.join(dbDir, 'khedmni.db');
  } catch (_) {}

  // If not found at getDatabasesPath, search workspace
  if (dbPath.isEmpty || !File(dbPath).existsSync()) {
    print('Database not found at default location. Searching workspace for khedmni.db...');
    final cwd = Directory.current;
    final matches = <String>[];
    await for (var f in cwd.list(recursive: true, followLinks: false)) {
      if (f is File && p.basename(f.path).toLowerCase() == 'khedmni.db') {
        matches.add(f.path);
      }
    }

    if (matches.isEmpty) {
      print('No khedmni.db file found in workspace. Please ensure the app database exists.');
      exit(1);
    }

    dbPath = matches.first;
    print('Using database at: $dbPath');
  } else {
    print('Using database at: $dbPath');
  }

  final matches = await _previewMatches(databaseFactory, dbPath, email);
  if (matches == 0) return;

  if (!shouldDelete) {
    print('\nDry run complete. To delete these users re-run with the --delete flag:');
    print('  dart run tools/delete_users_by_email.dart "$email" --delete');
    return;
  }

  stdout.write('Deleting $matches users with email $email. Are you sure? (y/N): ');
  final answer = stdin.readLineSync();
  if (answer == null || (answer.toLowerCase() != 'y' && answer.toLowerCase() != 'yes')) {
    print('Aborted by user. No changes made.');
    return;
  }

  final deleted = await _deleteMatches(databaseFactory, dbPath, email);
  print('Deleted $deleted user(s).');
}
