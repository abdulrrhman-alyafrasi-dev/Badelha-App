import 'package:flutter/material.dart';

class MatchBadge extends StatelessWidget {
  final int score;
  final bool isLarge;

  const MatchBadge({
    super.key,
    required this.score,
    this.isLarge = false,
  });

  Color _getBadgeColor() {
    if (score >= 85) return const Color(0xFF059669);
    if (score >= 70) return const Color(0xFF2563EB);
    if (score >= 50) return const Color(0xFFD97706);
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBadgeColor();

    if (isLarge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              'توافق $score%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Match',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color.withAlpha(180),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(80),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            '$score% Match',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
