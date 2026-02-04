import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/domain/entities/question_response.dart';
import '../providers/report_data_provider.dart';

/// Widget displaying detailed question breakdown by category
class QuestionBreakdownWidget extends StatelessWidget {
  final List<QuestionBreakdownItem> breakdown;
  final bool showDetails;

  const QuestionBreakdownWidget({
    super.key,
    required this.breakdown,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Question Breakdown by Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ...breakdown.map((item) => _buildBreakdownItem(item)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.quiz_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No question data available',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(QuestionBreakdownItem item) {
    final accuracy = item.accuracy;
    final accuracyColor = _getAccuracyColor(accuracy);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accuracyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accuracyColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${accuracy.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: accuracyColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Statistics row
          Row(
            children: [
              _buildStatChip(
                icon: Icons.quiz_outlined,
                label: 'Total',
                value: item.totalQuestions.toString(),
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                icon: Icons.check_circle_outline,
                label: 'Correct',
                value: item.correctAnswers.toString(),
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                icon: Icons.cancel_outlined,
                label: 'Incorrect',
                value: item.incorrectAnswers.toString(),
                color: Colors.red,
              ),
            ],
          ),

          // Progress bar
          const SizedBox(height: 12),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: accuracy / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  color: accuracyColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          // Detailed responses (if enabled)
          if (showDetails && item.responses.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Question Details:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...item.responses
                .take(3)
                .map((response) => _buildResponseItem(response)),
            if (item.responses.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '... and ${item.responses.length - 3} more questions',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseItem(QuestionResponse response) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            response.isCorrect ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: response.isCorrect ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              response.questionText.length > 60
                  ? '${response.questionText.substring(0, 60)}...'
                  : response.questionText,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80.0) {
      return Colors.green; // Excellent
    } else if (accuracy >= 70.0) {
      return AppColors.primary; // Good
    } else if (accuracy >= 50.0) {
      return Colors.orange; // Average
    } else {
      return Colors.red; // Poor
    }
  }
}
