import 'package:get_it/get_it.dart';
import '../../shared/data/datasources/datasources.dart';
import '../../shared/data/repositories/repositories.dart';
import '../../shared/domain/repositories/interview_repository.dart';
import '../../shared/domain/repositories/role_repository.dart';
import '../../shared/domain/repositories/experience_level_repository.dart';
import '../../shared/domain/repositories/interview_question_repository.dart';
import 'appwrite_service.dart';
import 'interview_session_manager.dart';

/// Service locator for dependency injection
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Initialize Appwrite service first
  sl.registerLazySingleton<AppwriteService>(() => AppwriteService.instance);
  sl<AppwriteService>().initialize();

  // Data sources
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
    () => InterviewRepositoryImpl(),
  );

  sl.registerLazySingleton<RoleRepository>(() => RoleRepositoryImpl(sl()));

  sl.registerLazySingleton<ExperienceLevelRepository>(
    () => ExperienceLevelRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<InterviewQuestionRepository>(
    () => InterviewQuestionRepositoryImpl(sl()),
  );

  // Services
  sl.registerLazySingleton<InterviewSessionManager>(
    () => InterviewSessionManager(sl<InterviewRepository>()),
  );

  // Initialize data sources
  // (No local data sources to initialize)

  // Initialize interview questions from JSON
  await sl<InterviewQuestionRepository>().initializeDefaultQuestions();

  // Load any cached interview session
  await sl<InterviewSessionManager>().loadSessionFromCache();
}
