import '../../domain/entities/entities.dart';
import '../../domain/repositories/interview_repository.dart';
import '../datasources/interview_local_datasource.dart';

/// Implementation of InterviewRepository using local data source
class InterviewRepositoryImpl implements InterviewRepository {
  final InterviewLocalDataSource _localDataSource;

  InterviewRepositoryImpl(this._localDataSource);

  @override
  Future<List<Interview>> getAllInterviews() async {
    return await _localDataSource.getAllInterviews();
  }

  @override
  Future<Interview?> getInterviewById(String id) async {
    return await _localDataSource.getInterviewById(id);
  }

  @override
  Future<void> saveInterview(Interview interview) async {
    await _localDataSource.saveInterview(interview);
  }

  @override
  Future<void> updateInterview(Interview interview) async {
    await _localDataSource.updateInterview(interview);
  }

  @override
  Future<void> deleteInterview(String id) async {
    await _localDataSource.deleteInterview(id);
  }

  @override
  Future<List<Interview>> getInterviewsByStatus(InterviewStatus status) async {
    return await _localDataSource.getInterviewsByStatus(status);
  }

  @override
  Future<List<Interview>> getInterviewsByRole(Role role) async {
    return await _localDataSource.getInterviewsByRole(role);
  }

  @override
  Future<List<Interview>> getInterviewsByLevel(Level level) async {
    return await _localDataSource.getInterviewsByLevel(level);
  }

  @override
  Future<List<Interview>> getRecentInterviews({int limit = 10}) async {
    return await _localDataSource.getRecentInterviews(limit: limit);
  }

  @override
  Future<List<Interview>> getInterviewsInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _localDataSource.getInterviewsInDateRange(startDate, endDate);
  }

  @override
  Future<int> getInterviewCount() async {
    return await _localDataSource.getInterviewCount();
  }

  @override
  Future<int> getInterviewCountByStatus(InterviewStatus status) async {
    return await _localDataSource.getInterviewCountByStatus(status);
  }

  @override
  Future<bool> interviewExists(String id) async {
    return await _localDataSource.interviewExists(id);
  }
}
