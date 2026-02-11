import 'package:flutter/foundation.dart';
import '../../../../shared/domain/entities/entities.dart';
import '../../../../shared/domain/repositories/repositories.dart';

/// Provider for managing interview setup state and logic
class InterviewSetupProvider extends ChangeNotifier {
  final InterviewQuestionRepository _questionRepository;
  final InterviewRepository _interviewRepository;

  InterviewSetupProvider(this._questionRepository, this._interviewRepository);

  bool _isLoading = false;
  Role? _selectedRole;
  Level? _selectedLevel;
  String _candidateName = '';
  List<InterviewQuestion> _availableQuestions = [];

  // Getters
  bool get isLoading => _isLoading;
  Role? get selectedRole => _selectedRole;
  Level? get selectedLevel => _selectedLevel;
  String get candidateName => _candidateName;
  List<InterviewQuestion> get availableQuestions => _availableQuestions;
  bool get isValid =>
      _selectedRole != null &&
      _selectedLevel != null &&
      _candidateName.trim().isNotEmpty;

  /// Set the selected role and update available questions
  Future<void> setSelectedRole(Role role) async {
    if (_selectedRole == role) return;

    _selectedRole = role;
    notifyListeners();

    if (_selectedLevel != null) {
      await _loadQuestions();
    }
  }

  /// Set the selected level and update available questions
  Future<void> setSelectedLevel(Level level) async {
    if (_selectedLevel == level) return;

    _selectedLevel = level;
    notifyListeners();

    if (_selectedRole != null) {
      await _loadQuestions();
    }
  }

  /// Set the candidate name
  void setCandidateName(String name) {
    _candidateName = name;
    notifyListeners();
  }

  /// Load questions based on selected role and level
  Future<void> _loadQuestions() async {
    if (_selectedRole == null || _selectedLevel == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final allQuestions = await _questionRepository.getQuestions();
      _availableQuestions = allQuestions.where((question) {
        return question.isSuitableForRole(_selectedRole!.name) &&
            question.matchesDifficulty(_selectedLevel!.name);
      }).toList();
    } catch (e) {
      debugPrint('Error loading questions: $e');
      _availableQuestions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get the count of available questions for current selection
  Future<int> getQuestionCount() async {
    if (_selectedRole == null || _selectedLevel == null) return 0;

    try {
      final allQuestions = await _questionRepository.getQuestions();
      final filteredQuestions = allQuestions.where((question) {
        return question.isSuitableForRole(_selectedRole!.name) &&
            question.matchesDifficulty(_selectedLevel!.name);
      }).toList();
      return filteredQuestions.length;
    } catch (e) {
      debugPrint('Error getting question count: $e');
      return 0;
    }
  }

  /// Create a new interview with current settings
  Future<Interview> createInterview(String candidateName) async {
    if (_selectedRole == null || _selectedLevel == null) {
      throw Exception('Role and level must be selected');
    }

    if (candidateName.trim().isEmpty) {
      throw Exception('Candidate name is required');
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Load questions for the interview
      final allQuestions = await _questionRepository.getQuestions();
      final suitableQuestions = allQuestions.where((question) {
        return question.isSuitableForRole(_selectedRole!.name) &&
            question.matchesDifficulty(_selectedLevel!.name);
      }).toList();

      if (suitableQuestions.isEmpty) {
        throw Exception('No questions available for selected role and level');
      }

      // Shuffle questions for variety (questions will be loaded dynamically during interview)
      final shuffledQuestions = List<InterviewQuestion>.from(suitableQuestions);
      shuffledQuestions.shuffle();

      // Create the interview
      final interview = Interview(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        candidateName: candidateName.trim(),
        role: _selectedRole!,
        level: _selectedLevel!,
        startTime: DateTime.now(),
        lastModified: DateTime.now(),
        endTime: null,
        responses: [],
        status: InterviewStatus.notStarted,
        overallScore: null,
      );

      // Save the interview
      await _interviewRepository.saveInterview(interview);

      return interview;
    } catch (e) {
      debugPrint('Error creating interview: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset the provider state
  void reset() {
    _selectedRole = null;
    _selectedLevel = null;
    _candidateName = '';
    _availableQuestions = [];
    _isLoading = false;
    notifyListeners();
  }

  /// Get questions by category for current role and level
  Future<List<InterviewQuestion>> getQuestionsByCategory(
    String category,
  ) async {
    if (_selectedRole == null || _selectedLevel == null) return [];

    try {
      final allQuestions = await _questionRepository.getQuestions();
      return allQuestions.where((question) {
        return question.category.toLowerCase() == category.toLowerCase() &&
            question.isSuitableForRole(_selectedRole!.name) &&
            question.matchesDifficulty(_selectedLevel!.name);
      }).toList();
    } catch (e) {
      debugPrint('Error getting questions by category: $e');
      return [];
    }
  }

  /// Preview questions for current selection
  Future<List<InterviewQuestion>> previewQuestions({int limit = 5}) async {
    if (_selectedRole == null || _selectedLevel == null) return [];

    try {
      final allQuestions = await _questionRepository.getQuestions();
      final suitableQuestions = allQuestions.where((question) {
        return question.isSuitableForRole(_selectedRole!.name) &&
            question.matchesDifficulty(_selectedLevel!.name);
      }).toList();

      if (suitableQuestions.length <= limit) {
        return suitableQuestions;
      }

      return suitableQuestions.take(limit).toList();
    } catch (e) {
      debugPrint('Error previewing questions: $e');
      return [];
    }
  }
}
