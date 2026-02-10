import 'dart:ui';
import 'package:flutter/material.dart';

/// A minimal dialog that displays a simple confirmation message
/// after a PDF is successfully saved.
class DownloadSuccessDialog extends StatelessWidget {
  final String fileName;

  const DownloadSuccessDialog({super.key, required this.fileName});

  /// Static method to show the dialog
  static Future<void> show(
    BuildContext context, {
    required String fileName,
    String? filePath, // Keep for backward compatibility but not used
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => DownloadSuccessDialog(fileName: fileName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Dialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$fileName saved in your device',
                style: const TextStyle(fontSize: 15, color: Colors.black),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
