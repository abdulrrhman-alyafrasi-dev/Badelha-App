import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';

/// 💬 Standard Confirmation Dialog (Delete, Warning, Actions)
class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final IconData icon;
  final Future<void> Function() onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = 'تأكيد',
    this.cancelText = 'إلغاء',
    this.confirmColor = AppColors.error,
    this.icon = Icons.warning_amber_rounded,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    Color confirmColor = AppColors.error,
    IconData icon = Icons.warning_amber_rounded,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
      ),
    );
  }

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusXL),
      title: Row(
        children: [
          Icon(widget.icon, color: widget.confirmColor, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Text(
        widget.message,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(false),
          child: Text(widget.cancelText, style: const TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: _isProcessing
              ? null
              : () async {
                  setState(() => _isProcessing = true);
                  try {
                    await widget.onConfirm();
                    if (!mounted) return;
                    Navigator.of(context).pop(true);
                  } catch (e) {
                    if (mounted) setState(() => _isProcessing = false);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.confirmColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusMD),
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(widget.confirmText),
        ),
      ],
    );
  }
}
