import 'package:flutter/foundation.dart';
import '../../../../core/providers/base_provider.dart';
import '../../../../core/services/cache_manager.dart';
import '../../../../core/utils/retry_helper.dart';
import '../../../../shared/domain/entities/interview_question.dart';
import '../../../../shared/domain/entities/question_category.dart';
import '../../../../shared/domain/repositories/interview_question_repository.dart';

/// Provider for managing interview questions state and operations
class InterviewQuestionProvider extends BaseProvider<InterviewQuestion> {
  final InterviewQuestionRepository _repository;

  InterviewQuestionProvider(this._repository);

  // Additional state
  List<QuestionCategoryEntity> _categories = [];
  Map<String, dynamic> _stats = {};
  String? _selectedCategory;
  String? _selectedDifficulty;
  String? _selectedRole;
  List<String> _selectedTags = [];

  // Getters
  List<InterviewQuestion> get questions => items;
  List<QuestionCategoryEntity> get categories => _categories;
  Map<String, dynamic> get stats => _stats;
  String? get selectedCategory => _selectedCategory;
  String? get selectedDifficulty => _selectedDifficulty;
  String? get selectedRole => _selectedRole;
  List<String> get selectedTags => _selectedTags;

  /// Get filtered questions based on current filters
  List<InterviewQuestion> get filteredQuestions {
    return questions.where((question) {
      return question.matchesSearchCriteria(
        categoryFilter: _selectedCategory,
        difficultyFilter: _selectedDifficulty,
        roleFilter: _selectedRole,
        tagFilters: _selectedTags.isNotEmpty ? _selectedTags : null,
      );
    }).toList();
  }

  /// Load interview questions with caching and fallback
  Future<void> loadQuestions({
    String? category,
    String? difficulty,
    String? roleSpecific,
    List<String>? tags,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        'questions_${category ?? 'all'}_${difficulty ?? 'all'}_${roleSpecific ?? 'all'}';

    // Try cache first unless force refresh
    if (!forceRefresh) {
      final cachedQuestions = CacheManager.get<List<InterviewQuestion>>(
        cacheKey,
      );
      if (cachedQuestions != null && cachedQuestions.isNotEmpty) {
        debugPrint(
          '✅ Using cached questions (${cachedQuestions.length} items)',
        );
        setItems(cachedQuestions);
        return;
      }
    }

    await loadItemsWithFallback(
      loadFromBackend: () => _loadQuestionsFromBackend(
        category: category,
        difficulty: difficulty,
        roleSpecific: roleSpecific,
        tags: tags,
        cacheKey: cacheKey,
      ),
      loadFallback: _loadFallbackQuestions,
    );
  }

  /// Load questions from backend with retry logic
  Future<void> _loadQuestionsFromBackend({
    String? category,
    String? difficulty,
    String? roleSpecific,
    List<String>? tags,
    required String cacheKey,
  }) async {
    await RetryHelper.withRetry(
      () async {
        debugPrint('📥 Fetching questions from backend...');

        // Check if questions exist, if not initialize them
        final hasQuestions = await _repository.hasQuestions();
        if (!hasQuestions) {
          debugPrint(
            '📝 No questions found, initializing default questions...',
          );
          await _repository.initializeDefaultQuestions();
        }

        // Fetch questions
        final questions = await _repository.getQuestions(
          category: category,
          difficulty: difficulty,
          roleSpecific: roleSpecific,
          tags: tags,
        );

        if (questions.isNotEmpty) {
          setItems(questions);
          markBackendTried();

          // Cache the questions
          CacheManager.set(
            cacheKey,
            questions,
            const Duration(minutes: 15), // Cache for 15 minutes
          );

          debugPrint(
            '✅ Successfully loaded ${questions.length} questions from backend',
          );
        }
      },
      config: RetryHelper.networkConfig,
      shouldRetry: RetryHelper.isRetryableError,
    );
  }

  /// Load fallback questions (empty list with message)
  void _loadFallbackQuestions() {
    debugPrint('🔄 Using fallback questions (empty list)');
    setItems([]);
  }

  /// Load question categories
  Future<void> loadCategories({bool forceRefresh = false}) async {
    const cacheKey = 'question_categories';

    // Try cache first unless force refresh
    if (!forceRefresh) {
      final cachedCategories = CacheManager.get<List<QuestionCategoryEntity>>(
        cacheKey,
      );
      if (cachedCategories != null && cachedCategories.isNotEmpty) {
        debugPrint(
          '✅ Using cached categories (${cachedCategories.length} items)',
        );
        _categories = cachedCategories;
        notifyListeners();
        return;
      }
    }

    try {
      setLoading(true);

      await RetryHelper.withRetry(
        () async {
          debugPrint('📥 Fetching categories from backend...');

          final categories = await _repository.getCategories();
          _categories = categories;

          // Cache the categories
          CacheManager.set(
            cacheKey,
            categories,
            const Duration(hours: 1), // Cache for 1 hour
          );

          debugPrint('✅ Successfully loaded ${categories.length} categories');
          notifyListeners();
        },
        config: RetryHelper.networkConfig,
        shouldRetry: RetryHelper.isRetryableError,
      );
    } catch (e) {
      // Categories are optional, so don't treat this as a critical error
      debugPrint('⚠️ Categories not available: $e');
      _categories = []; // Set empty list instead of error
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  /// Load question statistics
  Future<void> loadStats({bool forceRefresh = false}) async {
    const cacheKey = 'question_stats';

    // Try cache first unless force refresh
    if (!forceRefresh) {
      final cachedStats = CacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedStats != null && cachedStats.isNotEmpty) {
        debugPrint('✅ Using cached stats');
        _stats = cachedStats;
        notifyListeners();
        return;
      }
    }

    try {
      setLoading(true);

      final stats = await _repository.getQuestionStats();
      _stats = stats;

      // Cache the stats
      CacheManager.set(
        cacheKey,
        stats,
        const Duration(minutes: 10), // Cache for 10 minutes
      );

      debugPrint('✅ Successfully loaded question stats');
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      debugPrint('❌ Error loading stats: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Get random questions for interview
  Future<List<InterviewQuestion>> getRandomQuestions({
    required int count,
    String? category,
    String? difficulty,
    String? roleSpecific,
  }) async {
    try {
      return await _repository.getRandomQuestions(
        count: count,
        category: category,
        difficulty: difficulty,
        roleSpecific: roleSpecific,
      );
    } catch (e) {
      debugPrint('❌ Error getting random questions: $e');
      return [];
    }
  }

  /// Set category filter
  void setSelectedCategory(String? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  /// Set difficulty filter
  void setSelectedDifficulty(String? difficulty) {
    if (_selectedDifficulty != difficulty) {
      _selectedDifficulty = difficulty;
      notifyListeners();
    }
  }

  /// Set role filter
  void setSelectedRole(String? role) {
    if (_selectedRole != role) {
      _selectedRole = role;
      notifyListeners();
    }
  }

  /// Set tag filters
  void setSelectedTags(List<String> tags) {
    if (_selectedTags != tags) {
      _selectedTags = tags;
      notifyListeners();
    }
  }

  /// Clear all filters
  void clearFilters() {
    bool hasChanges = false;

    if (_selectedCategory != null) {
      _selectedCategory = null;
      hasChanges = true;
    }

    if (_selectedDifficulty != null) {
      _selectedDifficulty = null;
      hasChanges = true;
    }

    if (_selectedRole != null) {
      _selectedRole = null;
      hasChanges = true;
    }

    if (_selectedTags.isNotEmpty) {
      _selectedTags = [];
      hasChanges = true;
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    // Clear caches
    CacheManager.remove('question_categories');
    CacheManager.remove('question_stats');

    // Clear questions cache with current filters
    final cacheKey =
        'questions_${_selectedCategory ?? 'all'}_${_selectedDifficulty ?? 'all'}_${_selectedRole ?? 'all'}';
    CacheManager.remove(cacheKey);

    // Reload all data
    await Future.wait([
      loadQuestions(
        category: _selectedCategory,
        difficulty: _selectedDifficulty,
        roleSpecific: _selectedRole,
        tags: _selectedTags.isNotEmpty ? _selectedTags : null,
        forceRefresh: true,
      ),
      loadCategories(forceRefresh: true),
      loadStats(forceRefresh: true),
    ]);
  }

  /// Initialize provider with default data
  Future<void> initialize() async {
    debugPrint('🔄 Initializing InterviewQuestionProvider...');

    await Future.wait([loadQuestions(), loadCategories(), loadStats()]);

    debugPrint('✅ InterviewQuestionProvider initialized');
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}
