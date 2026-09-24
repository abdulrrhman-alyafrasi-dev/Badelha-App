import '../../data/models/item_model.dart';
import '../../data/models/match_result_model.dart';

class MatchingEngine {
  /// Calculate barter match compatibility between an owned item and a target item in the market.
  static MatchResultModel evaluateMatch({
    required ItemModel myItem,
    required ItemModel targetItem,
  }) {
    // 1. Category Score (30%)
    int categoryScore = 0;
    if (myItem.categoryId == targetItem.categoryId) {
      categoryScore = 30;
    } else if (myItem.wantedCategoryId == targetItem.categoryId ||
        targetItem.wantedCategoryId == myItem.categoryId) {
      categoryScore = 28;
    } else {
      // Cross-category compatible technology/home devices
      if (_areCompatibleCategories(myItem.categoryId, targetItem.categoryId)) {
        categoryScore = 18;
      } else {
        categoryScore = 8;
      }
    }

    // 2. Estimated Value Score (25%)
    final valA = myItem.estimatedValue;
    final valB = targetItem.estimatedValue;
    final maxVal = valA > valB ? valA : valB;
    final diff = (valA - valB).abs();
    final diffPercentage = maxVal > 0 ? (diff / maxVal) * 100 : 0.0;

    int valueScore = 0;
    if (diffPercentage <= 5) {
      valueScore = 25;
    } else if (diffPercentage <= 15) {
      valueScore = 20;
    } else if (diffPercentage <= 30) {
      valueScore = 14;
    } else if (diffPercentage <= 50) {
      valueScore = 8;
    } else {
      valueScore = 4;
    }

    // Cash difference calculation
    double suggestedCashDifference = 0.0;
    String cashPayer = 'none';
    if (diff > 50) {
      suggestedCashDifference = diff;
      cashPayer = valA < valB ? 'user_pays' : 'target_pays';
    }

    // 3. Quality & Condition Score (15%)
    int qualityScore = 0;
    if (myItem.condition == targetItem.condition && myItem.quality == targetItem.quality) {
      qualityScore = 15;
    } else if (myItem.condition == targetItem.condition || myItem.quality == targetItem.quality) {
      qualityScore = 11;
    } else {
      qualityScore = 7;
    }

    // 4. Location / City Score (15%)
    int locationScore = 0;
    if (myItem.city.trim().toLowerCase() == targetItem.city.trim().toLowerCase()) {
      locationScore = 15;
    } else {
      locationScore = 6; // Deliverable/Courier barter
    }

    // 5. User Wanted Preference Match (15%)
    int preferenceScore = 0;
    final targetWants = targetItem.wantedDescription.toLowerCase();
    final mySpecs = '${myItem.title} ${myItem.brand} ${myItem.model}'.toLowerCase();

    final myWants = myItem.wantedDescription.toLowerCase();
    final targetSpecs = '${targetItem.title} ${targetItem.brand} ${targetItem.model}'.toLowerCase();

    bool directDesireFromTarget = _containsKeywords(targetWants, mySpecs);
    bool directDesireFromMe = _containsKeywords(myWants, targetSpecs);

    if (directDesireFromTarget && directDesireFromMe) {
      preferenceScore = 15;
    } else if (directDesireFromTarget || directDesireFromMe) {
      preferenceScore = 12;
    } else if (targetItem.wantedCategoryId == myItem.categoryId) {
      preferenceScore = 10;
    } else {
      preferenceScore = 5;
    }

    final totalScore = categoryScore + valueScore + qualityScore + locationScore + preferenceScore;

    // Generate clear, transparent commercial reasons
    final List<String> reasons = [];
    if (categoryScore >= 25) {
      reasons.add('✓ فئة متطابقة تماماً بين الجهازين');
    } else if (categoryScore >= 18) {
      reasons.add('✓ فئات متبادلة متوافقة ومطلوبة');
    }

    if (valueScore >= 20) {
      reasons.add('✓ القيمة التقديرية متقاربة جداً وبدون فوارق تذكر');
    } else if (diff > 0) {
      final formattedDiff = diff.toStringAsFixed(0);
      if (cashPayer == 'user_pays') {
        reasons.add('✓ مقايضة مع فرق مالي مقترح: ادفع $formattedDiff ريال لتكافؤ الصفقة');
      } else {
        reasons.add('✓ مقايضة مع فرق مالي مقترح: يمنحك المقايض $formattedDiff ريال لتكافؤ الصفقة');
      }
    }

    if (preferenceScore >= 10) {
      reasons.add('✓ الطرف الآخر يبحث بالتحديد عن جهازك أو نوعه');
    }

    if (locationScore == 15) {
      reasons.add('✓ الطرفان في نفس المدينة (${myItem.city}) لتسهيل المعاينة الفورية');
    }

    if (targetItem.userTrustScore >= 90) {
      reasons.add('✓ المقايض يتمتع بمستوى ثقة استثنائي (${targetItem.userTrustScore}%) وتقييم ${targetItem.userRating}★');
    }

    return MatchResultModel(
      userItem: myItem,
      targetItem: targetItem,
      totalScore: totalScore.clamp(0, 100),
      categoryScore: categoryScore,
      valueScore: valueScore,
      qualityScore: qualityScore,
      locationScore: locationScore,
      preferenceScore: preferenceScore,
      reasons: reasons,
      suggestedCashDifference: suggestedCashDifference,
      cashPayer: cashPayer,
    );
  }

  static bool _areCompatibleCategories(String catA, String catB) {
    final techCategories = ['cat_electronics', 'cat_phones', 'cat_laptops', 'cat_gaming', 'cat_watches'];
    return techCategories.contains(catA) && techCategories.contains(catB);
  }

  static bool _containsKeywords(String text, String target) {
    final words = target.split(RegExp(r'\s+')).where((w) => w.length > 2);
    for (var w in words) {
      if (text.contains(w)) return true;
    }
    return false;
  }
}
