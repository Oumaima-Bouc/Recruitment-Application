import 'package:equatable/equatable.dart';
import '../../models/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
  
  // Getters for backward compatibility (optional but helpful during refactor)
  String get email => user.email;
  String get userType => user.userType;
}

class AuthUnauthenticated extends AuthState {}

class AuthPendingVerification extends AuthState {
  final String name;
  final String email;
  final String password;
  final String userType;
  final String code;
  final String? bio;
  final String? photoPath;

  const AuthPendingVerification({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
    required this.code,
    this.bio,
    this.photoPath,
  });

  @override
  List<Object?> get props => [name, email, password, userType, code, bio, photoPath];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
