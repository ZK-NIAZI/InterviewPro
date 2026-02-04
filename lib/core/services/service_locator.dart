import 'package:get_it/get_it.dart';
import '../../shared/data/datasources/datasources.dart';
import '../../shared/data/repositories/repositories.dart';
import '../../shared/domain/repositories/interview_repository.dart';
import '../../shared/domain/repositories/role_repository.dart';
import '../../shared/domain/repositories/experience_level_repository.dart';
import '../../shared/domain/repositories/interview_question_repository.dart';
import 'appwrite_service.dart';

/// Service locator for dependency injection
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Initialize Appwrite service first
  sl.registerLazySingleton<AppwriteService>(() => AppwriteService.instance);
  sl<AppwriteService>().initialize();

  // Data sources
  sl.registerLazySingleton<InterviewLocalDataSource>(
    () => InterviewLocalDataSource(),
  );

  sl.registerLazySingleton<RoleRemoteDatasource>(
    () => RoleRemoteDatasource(sl()),
  );

  sl.registerLazySingleton<ExperienceLevelRemoteDatasource>(
    () => ExperienceLevelRemoteDatasource(sl()),
  );

  sl.registerLazySingleton<InterviewQuestionRemoteDatasource>(
    () => InterviewQuestionRemoteDatasource(sl()),
  );

  // Repositories
  sl.registerLazySingleton<InterviewRepository>(
    () => InterviewRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<RoleRepository>(() => RoleRepositoryImpl(sl()));

  sl.registerLazySingleton<ExperienceLevelRepository>(
    () => ExperienceLevelRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<InterviewQuestionRepository>(
    () => InterviewQuestionRepositoryImpl(sl()),
  );

  // Initialize data sources
  await sl<InterviewLocalDataSource>().init();

  // Initialize interview questions from JSON
  await sl<InterviewQuestionRepository>().initializeDefaultQuestions();
}
