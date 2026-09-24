import '../../data/models/user_model.dart';

class TrustCalculator {
  /// Calculate updated trust score (0 - 100)
  static int calculateScore(UserModel user) {
    int score = 65; // Base starting score

    // Profile verification bonus
    if (user.isVerified) {
      score += 15;
    }

    // Swaps completed (up to +15 points)
    final swapsBonus = (user.swapsCompleted * 1.5).clamp(0, 15).toInt();
    score += swapsBonus;

    // Rating effect (4.0 to 5.0 gives up to +10 points)
    if (user.rating >= 4.0) {
      final ratingBonus = ((user.rating - 4.0) * 10).round();
      score += ratingBonus;
    } else {
      score -= ((4.0 - user.rating) * 15).round();
    }

    return score.clamp(20, 100);
  }

  /// Get trust badge title
  static String getTrustLevelTitle(int score) {
    if (score >= 95) return 'عضو ماسي فائق الموثوقية';
    if (score >= 88) return 'مقايض موثوق معتمد';
    if (score >= 75) return 'مقايض نشط وموثوق';
    if (score >= 60) return 'عضو جديد قيد التقييم';
    return 'مستوى ثقة منخفض';
  }
}
