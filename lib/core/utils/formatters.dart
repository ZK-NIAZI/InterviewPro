import 'package:intl/intl.dart';

/// Utility class for formatting dates, times, and durations
class AppFormatters {
  // Private constructor
  AppFormatters._();

  /// Format date as "MMM d, yyyy" (e.g., "Oct 24, 2023")
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Format date as "MMM d, y HH:mm" (e.g., "Oct 24, 23 14:30")
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yy HH:mm').format(date);
  }

  /// Format duration as "MM:SS" (e.g., "05:30")
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  /// Format duration as "Xh Ym" or "Ym" (e.g., "1h 30m" or "45m")
  static String formatDurationDetailed(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Format score as percentage "XX%" or "XX.X%"
  static String formatScore(double score) {
    return '${score.toStringAsFixed(1)}%';
  }
}
