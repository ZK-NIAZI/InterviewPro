import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';

/// Circular progress widget showing overall score with gauge-like appearance
class CircularProgressWidget extends StatelessWidget {
  final double score;
  final double size;
  final String? label;
  final bool showPercentage;

  const CircularProgressWidget({
    super.key,
    required this.score,
    this.size = 192.0,
    this.label,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    // Score is already in 0-100 range, clamp to ensure valid values
    final clampedScore = score.clamp(0.0, 100.0);
    final percentage = clampedScore.round();
    final progress = clampedScore / 100.0; // Convert to 0-1 range for painting

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: Size(size, size),
            painter: CircularProgressPainter(
              progress: 1.0,
              color: const Color(0xFFF3F4F6),
              strokeWidth: 12.0,
            ),
          ),

          // Progress circle with dynamic color
          CustomPaint(
            size: Size(size, size),
            painter: CircularProgressPainter(
              progress: progress,
              color: _getScoreColor(clampedScore),
              strokeWidth: 12.0,
            ),
          ),

          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showPercentage) ...[
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: size * 0.25, // Responsive font size
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(clampedScore),
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                label ?? 'Overall Score',
                style: TextStyle(
                  fontSize: size * 0.07, // Responsive font size
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get color based on score performance
  Color _getScoreColor(double score) {
    if (score >= 80.0) {
      return Colors.green; // Excellent
    } else if (score >= 70.0) {
      return AppColors.primary; // Good
    } else if (score >= 50.0) {
      return Colors.orange; // Average
    } else {
      return Colors.red; // Poor
    }
  }
}

/// Custom painter for circular progress indicator
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw arc from top (-π/2) clockwise
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CircularProgressPainter &&
        other.progress == progress &&
        other.color == color &&
        other.strokeWidth == strokeWidth;
  }

  @override
  int get hashCode => Object.hash(progress, color, strokeWidth);
}
