import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_recording_provider.dart';
import '../../../../core/constants/app_colors.dart';

class VoicePlaybackWidget extends StatelessWidget {
  final String questionId;
  final VoidCallback? onReRecord;

  const VoicePlaybackWidget({
    super.key,
    required this.questionId,
    this.onReRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceRecordingProvider>(
      builder: (context, provider, child) {
        final isPlaying = provider.isPlaying;
        final position = provider.currentPosition;
        final duration = provider.totalDuration;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: AppColors.primary,
                  size: 40,
                ),
                onPressed: () {
                  if (isPlaying) {
                    provider.pausePlayback();
                  } else {
                    provider.playRecording(questionId);
                  }
                },
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14,
                        ),
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.grey200,
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withOpacity(0.1),
                      ),
                      child: Slider(
                        value: position.inMilliseconds.toDouble(),
                        max: duration.inMilliseconds.toDouble() > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1.0,
                        onChanged: (value) {
                          provider.seekPlayback(
                            Duration(milliseconds: value.toInt()),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (onReRecord != null)
                Tooltip(
                  message: 'Re-record answer',
                  child: IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: onReRecord,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
