import 'package:hive/hive.dart';
import '../../domain/entities/entities.dart';
import '../models/interview_model.dart';

/// Local data source for managing interview data using Hive
class InterviewLocalDataSource {
  static const String _boxName = 'interviews';
  late Box<InterviewModel> _box;

  /// Initialize the data source
  Future<void> init() async {
    _box = await Hive.openBox<InterviewModel>(_boxName);
  }

  /// Get all interviews
  Future<List<Interview>> getAllInterviews() async {
    final models = _box.values.toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get interview by ID
  Future<Interview?> getInterviewById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }

  /// Save interview
  Future<void> saveInterview(Interview interview) async {
    final model = InterviewModel.fromEntity(interview);
    await _box.put(interview.id, model);
  }

  /// Update interview
  Future<void> updateInterview(Interview interview) async {
    final model = InterviewModel.fromEntity(interview);
    await _box.put(interview.id, model);
  }

  /// Delete interview
  Future<void> deleteInterview(String id) async {
    await _box.delete(id);
  }

  /// Get interviews by status
  Future<List<Interview>> getInterviewsByStatus(InterviewStatus status) async {
    final models = _box.values
        .where((model) => model.status == status)
        .toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get interviews by role
  Future<List<Interview>> getInterviewsByRole(Role role) async {
    final models = _box.values.where((model) => model.role == role).toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get interviews by level
  Future<List<Interview>> getInterviewsByLevel(Level level) async {
    final models = _box.values.where((model) => model.level == level).toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get recent interviews (last 10)
  Future<List<Interview>> getRecentInterviews({int limit = 10}) async {
    final models = _box.values.toList();
    models.sort((a, b) => b.startTime.compareTo(a.startTime));
    final limitedModels = models.take(limit).toList();
    return limitedModels.map((model) => model.toEntity()).toList();
  }

  /// Get interviews within date range
  Future<List<Interview>> getInterviewsInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final models = _box.values.where((model) {
      return model.startTime.isAfter(startDate) &&
          model.startTime.isBefore(endDate);
    }).toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get total count of interviews
  Future<int> getInterviewCount() async {
    return _box.length;
  }

  /// Get count of interviews by status
  Future<int> getInterviewCountByStatus(InterviewStatus status) async {
    return _box.values.where((model) => model.status == status).length;
  }

  /// Clear all interviews (for testing or reset purposes)
  Future<void> clearAllInterviews() async {
    await _box.clear();
  }

  /// Check if interview exists
  Future<bool> interviewExists(String id) async {
    return _box.containsKey(id);
  }

  /// Close the data source
  Future<void> close() async {
    await _box.close();
  }
}
