import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/enums.dart';

/// UI extensions for [InterviewVerdict]
extension VerdictUiX on InterviewVerdict {
  /// Get the color associated with the verdict
  Color get color {
    switch (this) {
      case InterviewVerdict.hire:
        return AppColors.success;
      case InterviewVerdict.nextRound:
        return AppColors.info;
      case InterviewVerdict.hold:
        return AppColors.warning;
      case InterviewVerdict.reject:
        return AppColors.error;
    }
  }

  /// Get the icon associated with the verdict
  IconData get icon {
    switch (this) {
      case InterviewVerdict.hire:
        return Icons.check_circle;
      case InterviewVerdict.nextRound:
        return Icons.next_plan;
      case InterviewVerdict.hold:
        return Icons.pause_circle;
      case InterviewVerdict.reject:
        return Icons.cancel;
    }
  }
}
