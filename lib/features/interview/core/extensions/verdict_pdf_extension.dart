import 'package:pdf/pdf.dart';
import '../../../../shared/domain/entities/enums.dart';

/// PDF extensions for [InterviewVerdict]
extension VerdictPdfX on InterviewVerdict {
  /// Get the badge background color associated with the verdict
  PdfColor get pdfColor {
    switch (this) {
      case InterviewVerdict.hire:
        return PdfColors.green100;
      case InterviewVerdict.nextRound:
        return PdfColors.blue100;
      case InterviewVerdict.hold:
        return PdfColors.orange100;
      case InterviewVerdict.reject:
        return PdfColors.red100;
    }
  }

  /// Get the badge text color associated with the verdict
  PdfColor get pdfTextColor {
    switch (this) {
      case InterviewVerdict.hire:
        return PdfColors.green800;
      case InterviewVerdict.nextRound:
        return PdfColors.blue800;
      case InterviewVerdict.hold:
        return PdfColors.orange800;
      case InterviewVerdict.reject:
        return PdfColors.red800;
    }
  }
}
