import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:khedmni/logic/cubits/auth_cubit.dart';
import 'package:khedmni/logic/cubits/auth_state.dart';
import 'package:khedmni/data/repositories/auth_repository.dart';
import 'package:khedmni/models/user.dart';

// Mock AuthRepository for testing
class MockAuthRepository extends AuthRepository {
  bool shouldThrowError = false;
  String errorMessage = 'Test error';
  User? mockUser;

  MockAuthRepository() {
    mockUser = User(
      id: 'test-id-123',
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      userType: 'student',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    if (email == 'test@example.com' && password == 'password123') {
      return mockUser!;
    }
    throw Exception('Invalid email or password');
  }

  @override
  Future<User> signup(
    String name,
    String email,
    String password, {
    String userType = 'student',
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    if (email == 'existing@example.com') {
      throw Exception('Email already registered');
    }
    return User(
      id: 'new-user-id',
      name: name,
      email: email,
      password: password,
      userType: userType,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return mockUser != null;
  }

  @override
  Future<User?> getCurrentUser() async {
    return mockUser;
  }

  @override
  Future<void> updateUserProfile(User user) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    mockUser = user;
  }
}

void main() {
  group('AuthCubit', () {
    late MockAuthRepository mockAuthRepository;
    late AuthCubit authCubit;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authCubit = AuthCubit(mockAuthRepository);
    });

    tearDown(() {
      authCubit.close();
    });

    test('initial state is AuthInitial', () {
      expect(authCubit.state, isA<AuthInitial>());
    });

    group('login', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when login succeeds',
        build: () => AuthCubit(mockAuthRepository),
        act: (cubit) => cubit.login('test@example.com', 'password123'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits AuthAuthenticated with correct user data',
        build: () => AuthCubit(mockAuthRepository),
        act: (cubit) => cubit.login('test@example.com', 'password123'),
        wait: const Duration(milliseconds: 200),
        verify: (cubit) {
          final state = cubit.state;
          expect(state, isA<AuthAuthenticated>());
          if (state is AuthAuthenticated) {
            expect(state.user.email, 'test@example.com');
            expect(state.user.name, 'Test User');
            expect(state.user.userType, 'student');
          }
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when login fails with wrong credentials',
        build: () => AuthCubit(mockAuthRepository),
        act: (cubit) => cubit.login('wrong@example.com', 'wrongpass'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('Invalid'),
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when repository throws error',
        build: () {
          mockAuthRepository.shouldThrowError = true;
          mockAuthRepository.errorMessage = 'Network error';
          return AuthCubit(mockAuthRepository);
        },
        act: (cubit) => cubit.login('test@example.com', 'password123'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            'Network error',
          ),
        ],
      );
    });

    group('signup', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when signup succeeds',
        build: () => AuthCubit(mockAuthRepository),
        act: (cubit) => cubit.signup(
          'New User',
          'newuser@example.com',
          'password123',
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits AuthAuthenticated with correct new user data',
        build: () => AuthCubit(mockAuthRepository),
        act: (cubit) => cubit.signup(
          'John Doe',
          'john@example.com',
          'secure123',
          userType: 'company',
        ),
        wait: const Duration(milliseconds: 200),
        verify: (cubit) {
          final state = cubit.state;
          expect(state, isA<AuthAuthenticated>());
          if (state is AuthAuthenticated) {
            expect(state.user.name, 'John Doe');
            expect(state.user.email, 'john@example.com');
            expect(state.user.userType, 'company');
          }
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when email already exists',
        build: () => AuthCubit(mockAuthRepository),
        act: (cubit) => cubit.signup(
          'Test',
          'existing@example.com',
          'password',
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('already registered'),
          ),
        ],
      );
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when logout succeeds',
        build: () => AuthCubit(mockAuthRepository),
        act: (cubit) => cubit.logout(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
      );
    });

    group('checkLoginStatus', () {
      blocTest<AuthCubit, AuthState>(
        'emits AuthAuthenticated when user is logged in',
        build: () => AuthCubit(mockAuthRepository),
        act: (cubit) => cubit.checkLoginStatus(),
        verify: (cubit) {
          final state = cubit.state;
          expect(state, isA<AuthAuthenticated>());
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits AuthUnauthenticated when user is not logged in',
        build: () {
          mockAuthRepository.mockUser = null;
          return AuthCubit(mockAuthRepository);
        },
        act: (cubit) => cubit.checkLoginStatus(),
        verify: (cubit) {
          final state = cubit.state;
          expect(state, isA<AuthUnauthenticated>());
        },
      );
    });

    group('updateProfile', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when profile update succeeds',
        build: () => AuthCubit(mockAuthRepository),
        seed: () => AuthAuthenticated(mockAuthRepository.mockUser!),
        act: (cubit) => cubit.updateProfile(
          name: 'Updated Name',
          bio: 'Updated bio',
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'updates user with new profile data',
        build: () => AuthCubit(mockAuthRepository),
        seed: () => AuthAuthenticated(mockAuthRepository.mockUser!),
        act: (cubit) => cubit.updateProfile(
          name: 'Jane Smith',
          title: 'Flutter Developer',
          skills: 'Dart, Flutter, Firebase',
          bio: 'Passionate mobile developer',
        ),
        wait: const Duration(milliseconds: 200),
        verify: (cubit) {
          final state = cubit.state;
          expect(state, isA<AuthAuthenticated>());
          if (state is AuthAuthenticated) {
            expect(state.user.name, 'Jane Smith');
            expect(state.user.title, 'Flutter Developer');
            expect(state.user.skills, 'Dart, Flutter, Firebase');
            expect(state.user.bio, 'Passionate mobile developer');
          }
        },
      );

      blocTest<AuthCubit, AuthState>(
        'does not update profile when not authenticated',
        build: () => AuthCubit(mockAuthRepository),
        seed: () => AuthUnauthenticated(),
        act: (cubit) => cubit.updateProfile(name: 'New Name'),
        expect: () => [],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when update fails',
        build: () {
          mockAuthRepository.shouldThrowError = true;
          mockAuthRepository.errorMessage = 'Update failed';
          return AuthCubit(mockAuthRepository);
        },
        seed: () => AuthAuthenticated(mockAuthRepository.mockUser!),
        act: (cubit) => cubit.updateProfile(name: 'New Name'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            'Update failed',
          ),
        ],
      );
    });

    group('integration test', () {
      blocTest<AuthCubit, AuthState>(
        'complete workflow: signup -> update profile -> logout',
        build: () => AuthCubit(mockAuthRepository),
        act: (cubit) async {
          await cubit.signup('Alice', 'alice@example.com', 'pass123');
          await Future.delayed(const Duration(milliseconds: 150));
          await cubit.updateProfile(
            name: 'Alice Johnson',
            bio: 'Software Engineer',
          );
          await Future.delayed(const Duration(milliseconds: 150));
          await cubit.logout();
        },
        wait: const Duration(seconds: 1),
        verify: (cubit) {
          final state = cubit.state;
          expect(state, isA<AuthUnauthenticated>());
        },
      );
    });
  });
}
