import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';

/// Bottom sheet for sharing the interview report PDF
class ShareBottomSheet extends StatelessWidget {
  final String filePath;
  final String candidateName;

  const ShareBottomSheet({
    super.key,
    required this.filePath,
    required this.candidateName,
  });

  /// Show the share bottom sheet
  static void show(
    BuildContext context,
    String filePath,
    String candidateName,
  ) {
    debugPrint('📊 ShareBottomSheet.show called with: $filePath');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          ShareBottomSheet(filePath: filePath, candidateName: candidateName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Interview_Report_${candidateName.replaceAll(' ', '_')}.pdf';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Share Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(
                context,
                icon: Icons.chat_bubble_outline,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => _shareToApp(context, 'WhatsApp'),
              ),
              _buildShareOption(
                context,
                icon: Icons.email_outlined,
                label: 'Email',
                color: AppColors.primary,
                onTap: () => _shareToApp(context, 'Email'),
              ),
              _buildShareOption(
                context,
                icon: Icons.more_horiz,
                label: 'More',
                color: const Color(0xFF64748B),
                onTap: () => _shareToNative(context),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Close button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          // Extra padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareToApp(BuildContext context, String appName) async {
    // Both apps will use the native share sheet since direct deep-linking
    // to attachments is inconsistent across OS versions in Flutter.
    // However, the intent is captured and we show a clear UI.
    await _shareToNative(context);
  }

  Future<void> _shareToNative(BuildContext context) async {
    Navigator.pop(context); // Close sheet before sharing

    final box = context.findRenderObject() as RenderBox?;
    final rect = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 100, 100);

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Interview Report - $candidateName',
      text: 'Evaluation report for candidate: $candidateName',
      sharePositionOrigin: rect,
    );
  }
}
