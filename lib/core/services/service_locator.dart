import 'package:get_it/get_it.dart';
import '../../shared/data/datasources/datasources.dart';
import '../../shared/data/repositories/repositories.dart';
import '../../shared/data/services/default_question_bank_service.dart';
import '../../shared/domain/repositories/repositories.dart';

/// Service locator for dependency injection
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Data sources
  sl.registerLazySingleton<InterviewLocalDataSource>(
    () => InterviewLocalDataSource(),
  );

  sl.registerLazySingleton<QuestionLocalDataSource>(
    () => QuestionLocalDataSource(),
  );

  // Repositories
  sl.registerLazySingleton<InterviewRepository>(
    () => InterviewRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(sl()),
  );

  // Services
  sl.registerLazySingleton<DefaultQuestionBankService>(
    () => DefaultQuestionBankService(sl()),
  );

  // Initialize data sources
  await sl<InterviewLocalDataSource>().init();
  await sl<QuestionLocalDataSource>().init();

  // Initialize default question bank on first launch
  await sl<DefaultQuestionBankService>().initializeDefaultQuestions();
}
