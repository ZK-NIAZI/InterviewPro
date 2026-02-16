import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/voice_recording_provider.dart';

/// A widget that visualizes audio amplitude as a series of animated bars
class AudioWaveformWidget extends StatefulWidget {
  final double height;
  final Color? color;

  const AudioWaveformWidget({super.key, this.height = 40.0, this.color});

  @override
  State<AudioWaveformWidget> createState() => _AudioWaveformWidgetState();
}

class _AudioWaveformWidgetState extends State<AudioWaveformWidget>
    with SingleTickerProviderStateMixin {
  // Number of bars to display
  static const int _barCount = 12;

  // Stream subscription
  StreamSubscription<double>? _amplitudeSubscription;

  // Current amplitude level (0.0 to 1.0)
  double _currentAmplitude = 0.0;

  // Random number generator for "jitter" effect
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _subscribeToAmplitude();
  }

  void _subscribeToAmplitude() {
    final provider = context.read<VoiceRecordingProvider>();
    _amplitudeSubscription = provider.amplitudeStream.listen((amplitude) {
      if (mounted) {
        setState(() {
          _currentAmplitude = amplitude;
        });
      }
    });
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end, // Bars grow from bottom
        children: List.generate(_barCount, (index) => _buildBar(index)),
      ),
    );
  }

  Widget _buildBar(int index) {
    // Calculate height based on amplitude and some randomness
    // Center bars are taller, outer bars are shorter

    // Bell curve factor (0.0 to 1.0)
    // index 0 -> low, index 6 -> high, index 11 -> low
    final centerOffset = (index - (_barCount / 2)).abs();
    final bellFactor = 1.0 - (centerOffset / (_barCount / 2));

    // Base height (idle animation)
    // We use a sine wave based on time for a "breathing" effect would be ideal,
    // but for simplicity and performance, we'll just use a small base value.
    const minHeightPercentage = 0.15;

    // Active height contribution
    // Add randomness so bars don't move in perfect unison
    final randomJitter = 0.8 + (_random.nextDouble() * 0.4); // 0.8 to 1.2

    // Final height calculation
    // height = max_height * (min_base + (amplitude * bell_curve * jitter))
    double targetHeightPercentage =
        minHeightPercentage +
        (_currentAmplitude *
            bellFactor *
            randomJitter *
            (1.0 - minHeightPercentage));

    // Clamp
    if (targetHeightPercentage > 1.0) targetHeightPercentage = 1.0;

    // Ensure symmetrical visual by slightly coupling random seed to index if desired,
    // or just letting it be organic. Organic look is usually better for voice.

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutQuad,
          heightFactor: targetHeightPercentage,
          child: Container(
            decoration: BoxDecoration(
              color: widget.color ?? AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
