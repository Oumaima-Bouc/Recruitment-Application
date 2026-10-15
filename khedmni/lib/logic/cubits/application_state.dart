import 'package:equatable/equatable.dart';
import '../../models/application.dart';

abstract class ApplicationState extends Equatable {
  const ApplicationState();

  @override
  List<Object?> get props => [];
}

class ApplicationInitial extends ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class ApplicationLoaded extends ApplicationState {
  final List<Application> applications;

  const ApplicationLoaded({required this.applications});

  @override
  List<Object?> get props => [applications];
}

class ApplicationError extends ApplicationState {
  final String message;

  const ApplicationError(this.message);

  @override
  List<Object?> get props => [message];
}
