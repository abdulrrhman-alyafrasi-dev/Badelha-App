import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// ⏳ Listing Expiration & Time Remaining Badge
class RemainingTimeBadge extends StatelessWidget {
  final String createdAt;
  final String? expiresAt;
  final String status;
  final bool compact;

  const RemainingTimeBadge({
    super.key,
    required this.createdAt,
    this.expiresAt,
    required this.status,
    this.compact = true,
  });

  int get daysRemaining {
    if (status == 'Expired') return 0;
    try {
      DateTime target;
      if (expiresAt != null && expiresAt!.isNotEmpty) {
        target = DateTime.parse(expiresAt!);
      } else {
        target = DateTime.parse(createdAt).add(const Duration(days: 30));
      }
      final diff = target.difference(DateTime.now()).inDays;
      return diff > 0 ? diff : 0;
    } catch (_) {
      return 30;
    }
  }

  bool get isExpired => status == 'Expired' || daysRemaining <= 0;

  @override
  Widget build(BuildContext context) {
    if (isExpired) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 5 : 8,
          vertical: compact ? 1.5 : 3,
        ),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(compact ? 4 : 6),
          border: Border.all(color: Colors.red.shade200, width: 0.6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_off_outlined, size: compact ? 10 : 12, color: Colors.red.shade700),
            SizedBox(width: compact ? 2 : 4),
            Text(
              'منتهي الصلاحية',
              style: TextStyle(
                fontSize: compact ? 8.5 : 10,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
          ],
        ),
      );
    }

    final days = daysRemaining;
    final isUrgent = days <= 3;
    final Color bgColor = isUrgent ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9);
    final Color textColor = isUrgent ? const Color(0xFF92400E) : AppColors.textSecondary;
    final Color borderColor = isUrgent ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0);

    final String label = days == 0 ? 'ينتهي اليوم' : 'متبقٍ  يوم';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 8,
        vertical: compact ? 1.5 : 3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
        border: Border.all(color: borderColor, width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUrgent ? Icons.access_time_filled : Icons.access_time,
            size: compact ? 10 : 12,
            color: textColor,
          ),
          SizedBox(width: compact ? 2 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 8.5 : 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
