import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/transcript_parser.dart';
import '../providers/audio_player_provider.dart';

/// A full-screen transcript viewer with a chat-style interface and audio synchronization.
class TranscriptViewerWidget extends StatelessWidget {
  final String rawTranscript;
  final String candidateName;
  final String role;

  const TranscriptViewerWidget({
    super.key,
    required this.rawTranscript,
    required this.candidateName,
    required this.role,
  });

  /// Static method to show the transcript viewer
  static Future<void> show(
    BuildContext context, {
    required String rawTranscript,
    required String candidateName,
    required String role,
    required AudioPlayerProvider audioProvider,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ChangeNotifierProvider.value(
          value: audioProvider,
          child: TranscriptViewerWidget(
            rawTranscript: rawTranscript,
            candidateName: candidateName,
            role: role,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final turns = TranscriptParser.parse(rawTranscript);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Interview Transcript',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$candidateName • $role',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: Stack(
        children: [
          // Message List
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            itemCount: turns.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final turn = turns[index];
              return _ChatBubble(turn: turn);
            },
          ),

          // Mini Audio Player at bottom
          Positioned(bottom: 0, left: 0, right: 0, child: _MiniAudioPlayer()),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final TranscriptTurn turn;

  const _ChatBubble({required this.turn});

  @override
  Widget build(BuildContext context) {
    final isInterviewer = turn.isInterviewer;

    return Column(
      crossAxisAlignment: isInterviewer
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        // Speaker Label
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
          child: Text(
            turn.speaker,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Bubble
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isInterviewer
                ? AppColors.grey100
                : AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isInterviewer ? 0 : 16),
              bottomRight: Radius.circular(isInterviewer ? 16 : 0),
            ),
            border: Border.all(
              color: isInterviewer
                  ? AppColors.grey200
                  : AppColors.primary.withOpacity(0.1),
            ),
          ),
          child: Text(
            turn.text,
            style: const TextStyle(
              fontSize: 14.5,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniAudioPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Play/Pause
              GestureDetector(
                onTap: provider.togglePlayPause,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    provider.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Progress and Time
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 5,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 10,
                        ),
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: Colors.grey[200],
                        thumbColor: AppColors.primary,
                      ),
                      child: Slider(
                        value: provider.progress.clamp(0.0, 1.0),
                        onChangeStart: (_) => provider.startSeeking(),
                        onChanged: (value) {
                          final position = Duration(
                            milliseconds:
                                (value * provider.totalDuration.inMilliseconds)
                                    .toInt(),
                          );
                          provider.seek(position);
                        },
                        onChangeEnd: (_) => provider.endSeeking(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.formatDuration(provider.currentPosition),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            provider.formatDuration(provider.totalDuration),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
