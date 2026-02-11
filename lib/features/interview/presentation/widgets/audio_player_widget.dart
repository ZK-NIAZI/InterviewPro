import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/audio_player_provider.dart';

/// Professional audio player widget for interview recordings
class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final int? durationSeconds;

  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
    this.durationSeconds,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    // CRITICAL FIX: Use ChangeNotifierProvider (create) instead of .value
    // This ensures Provider automatically calls dispose() on the AudioPlayerProvider
    // when this widget is removed from the tree.
    return ChangeNotifierProvider(
      create: (_) {
        // Create and initialize the provider
        final provider = AudioPlayerProvider();
        provider.initialize(widget.audioPath);
        return provider;
      },
      child: Consumer<AudioPlayerProvider>(
        builder: (context, provider, child) {
          // Show error state if audio failed to load
          if (provider.error != null) {
            return _buildErrorState(provider.error!);
          }

          // Show loading state while initializing
          if (!provider.isInitialized) {
            return _buildLoadingState();
          }

          // Show audio player
          return _buildAudioPlayer(provider);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontSize: 13,
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading audio...',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(AudioPlayerProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.mic, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'Interview Recording',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Playback controls
          Row(
            children: [
              // Play/Pause button
              GestureDetector(
                onTap: provider.togglePlayPause,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    provider.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Progress slider
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: provider.progress.clamp(0.0, 1.0),
                    onChangeStart: (value) {
                      // Mark as seeking to prevent position stream updates
                      provider.startSeeking();
                    },
                    onChanged: (value) {
                      // Update UI position during drag (no actual seek yet)
                      final position = Duration(
                        milliseconds:
                            (value * provider.totalDuration.inMilliseconds)
                                .toInt(),
                      );
                      // This updates _currentPosition immediately for smooth UI
                      provider.seek(position);
                    },
                    onChangeEnd: (value) {
                      // End seeking state and perform final seek
                      final position = Duration(
                        milliseconds:
                            (value * provider.totalDuration.inMilliseconds)
                                .toInt(),
                      );
                      provider.seek(position);
                      provider.endSeeking();
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Time display
              Text(
                '${provider.formatDuration(provider.currentPosition)} / ${provider.formatDuration(provider.totalDuration)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
