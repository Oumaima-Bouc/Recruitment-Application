import 'package:flutter_test/flutter_test.dart';
import 'package:khedmni/data/repositories/auth_repository.dart';
import 'package:khedmni/models/user.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khedmni/data/dao/user_dao.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthRepository repo;

  setUp(() async {
    // Mock SharedPreferences for tests that call SharedPreferences.getInstance
    SharedPreferences.setMockInitialValues({});

    // Use ffi-backed sqflite implementation for desktop test environment
    // so databaseFactory is available when tests run.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Provide a mock HTTP client so tests don't rely on a running email service
    final mockHttp = MockClient((request) async {
      // Basic assertion to ensure we call the right endpoint
      expect(request.url.path, '/send-verification');
      return http.Response('{}', 200);
    });

    repo = AuthRepository(httpClient: mockHttp);
  });

  test('send code and verify via 4-digit token', () async {
    // Create a user signup attempt via startSignup (unique email)
    final email = 'test.user+${DateTime.now().millisecondsSinceEpoch}@example.com';
    final token = await repo.startSignup(email);

    // Fetch from DB via DAO
    final dao = UserDao();
    final fetched = await dao.getUserByEmail(email);
    expect(fetched, isNotNull);
    expect(fetched!.emailVerificationToken, isNotNull);
    expect(fetched.emailVerificationToken!.length, 4);

    // Token returned matches persisted token
    expect(token, fetched.emailVerificationToken);

    // Verify using token
    final ok = await repo.verifyEmailToken(fetched.id, fetched.emailVerificationToken!);
    expect(ok, isTrue);

    final after = await dao.getUserById(fetched.id);
    expect(after!.isEmailVerified, isTrue);
  });
}
