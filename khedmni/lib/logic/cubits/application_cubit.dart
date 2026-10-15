import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/dao/application_dao.dart';
import '../../models/application.dart';
import 'application_state.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  final ApplicationDao _applicationDao = ApplicationDao();

  ApplicationCubit() : super(ApplicationInitial());

  Future<void> loadApplications(String? studentId) async {
    if (studentId == null) {
      emit(ApplicationError("User ID required"));
      return;
    }

    emit(ApplicationLoading());
    try {
      final apps = await _applicationDao.getApplicationsByStudentId(studentId);
      emit(ApplicationLoaded(applications: apps));
    } catch (e) {
      emit(ApplicationError(e.toString()));
    }
  }

  Future<void> searchApplications(String query) async {
    emit(ApplicationLoading());
    try {
      final apps = await _applicationDao.searchApplications(query);
      emit(ApplicationLoaded(applications: apps));
    } catch (e) {
      emit(ApplicationError(e.toString()));
    }
  }

  Future<void> addApplication(Application app) async {
    try {
      await _applicationDao.insertApplication(app);
      // Reload is tricky without studentId, typically we'd reload the list or just append.
      // Ideally we should know the current context (studentId) or rely on caller to reload.
      // For now, let's just emit success if needed, or rely on UI to refresh.
    } catch (e) {
      emit(ApplicationError(e.toString()));
    }
  }
}
