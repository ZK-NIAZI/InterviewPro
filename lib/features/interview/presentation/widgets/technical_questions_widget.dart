import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../pages/report_preview_page.dart';
import '../providers/voice_recording_provider.dart';
import 'playback_dialog.dart';

/// Technical questions widget with check/cancel icons
class TechnicalQuestionsWidget extends StatelessWidget {
  final List<TechnicalQuestion> questions;

  const TechnicalQuestionsWidget({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: const Text(
            'KEY TECHNICAL QUESTIONS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: questions
              .map((question) => _buildQuestionItem(question))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildQuestionItem(TechnicalQuestion question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: Icon(
              question.isCorrect ? Icons.check_circle : Icons.cancel,
              size: 20,
              color: question.isCorrect
                  ? AppColors.primary
                  : const Color(0xFF9CA3AF),
            ),
          ),

          const SizedBox(width: 12),

          // Question content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  question.feedback,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Playback button
          if (question.questionId.isNotEmpty)
            Consumer<VoiceRecordingProvider>(
              builder: (context, provider, child) {
                final hasRecording = provider.hasRecording(question.questionId);
                if (!hasRecording) return const SizedBox.shrink();

                return IconButton(
                  icon: const Icon(
                    Icons.play_circle_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  onPressed: () {
                    PlaybackDialog.show(
                      context,
                      question.questionId,
                      question.question,
                    );
                  },
                  tooltip: 'Listen to response',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                );
              },
            ),
        ],
      ),
    );
  }
}
