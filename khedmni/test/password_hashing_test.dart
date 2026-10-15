import 'package:flutter_test/flutter_test.dart';
import 'package:khedmni/data/repositories/auth_repository.dart';
import 'package:khedmni/data/dao/user_dao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthRepository repo;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    repo = AuthRepository();
  });

  test('passwords are hashed and login works', () async {
    final email = 'hash.test+${DateTime.now().millisecondsSinceEpoch}@example.com';

    // complete signup will hash the password
    final user = await repo.completeSignup(name: 'Hash Test', email: email, password: 'secret123', userType: 'student');

    final dao = UserDao();
    final stored = await dao.getUserById(user.id);
    expect(stored, isNotNull);
    expect(stored!.password, isNot('secret123'));

    // Login should accept plain password
    final logged = await repo.login(email, 'secret123');
    expect(logged, isNotNull);
    expect(logged.email, email);
  });

  test('changePassword verifies current and updates hash', () async {
    final email = 'changepw.test+${DateTime.now().millisecondsSinceEpoch}@example.com';

    final user = await repo.completeSignup(name: 'CP Test', email: email, password: 'oldpass', userType: 'student');
    final ok = await repo.changePassword(user.id, 'oldpass', 'newpass');
    expect(ok, isTrue);

    // Login with new password
    final logged = await repo.login(email, 'newpass');
    expect(logged, isNotNull);
  });
}