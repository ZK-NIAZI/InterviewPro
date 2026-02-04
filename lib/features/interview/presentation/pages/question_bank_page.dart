import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/domain/entities/interview_question.dart';
import '../providers/interview_question_provider.dart';
import '../widgets/question_card_widget.dart';
import '../widgets/question_filter_widget.dart';

/// Question Bank page for managing interview questions
class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InterviewQuestionProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Question Bank',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () => _showStatsDialog(),
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Question Statistics',
          ),
          IconButton(
            onPressed: () => _refreshQuestions(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Questions',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          const QuestionFilterWidget(),

          // Questions List
          Expanded(
            child: Consumer<InterviewQuestionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading questions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _refreshQuestions(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredQuestions = provider.filteredQuestions;

                if (filteredQuestions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No questions found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters or refresh the page',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.clearFilters(),
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredQuestions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: QuestionCardWidget(
                        question: filteredQuestions[index],
                        onTap: () =>
                            _showQuestionDetails(filteredQuestions[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _refreshQuestions() {
    context.read<InterviewQuestionProvider>().refreshAll();
  }

  void _showStatsDialog() {
    final provider = context.read<InterviewQuestionProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Question Statistics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow(
                'Total Questions',
                provider.stats['totalQuestions']?.toString() ?? '0',
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                'Average Duration',
                '${provider.stats['averageDuration']?.toStringAsFixed(1) ?? '0'} min',
              ),
              const SizedBox(height: 16),
              const Text(
                'By Category:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...((provider.stats['byCategory'] as Map<String, dynamic>?) ?? {})
                  .entries
                  .map(
                    (entry) => _buildStatRow(entry.key, entry.value.toString()),
                  ),
              const SizedBox(height: 16),
              const Text(
                'By Difficulty:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...((provider.stats['byDifficulty'] as Map<String, dynamic>?) ??
                      {})
                  .entries
                  .map(
                    (entry) => _buildStatRow(entry.key, entry.value.toString()),
                  ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showQuestionDetails(InterviewQuestion question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          question.categoryDisplayName,
          style: const TextStyle(fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Difficulty', question.difficultyDisplayName),
              _buildDetailRow('Duration', '${question.expectedDuration} min'),
              if (question.roleSpecific != null)
                _buildDetailRow('Role', question.roleSpecific!),
              if (question.tags.isNotEmpty)
                _buildDetailRow('Tags', question.tags.join(', ')),
              if (question.sampleAnswer != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Sample Answer:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(question.sampleAnswer!),
              ],
              if (question.evaluationCriteria.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Evaluation Criteria:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...question.evaluationCriteria.map(
                  (criteria) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(criteria)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
