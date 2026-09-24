import '../../data/models/item_model.dart';

class SemanticSearchEngine {
  // Arabic & English synonym dictionary
  static final Map<String, List<String>> _synonyms = {
    'هاتف': ['جوال', 'موبايل', 'تلفون', 'ايفون', 'سامسونج', 'phone', 'smartphone', 'mobile'],
    'جوال': ['هاتف', 'موبايل', 'تلفون', 'ايفون', 'سامسونج', 'phone', 'smartphone'],
    'موبايل': ['هاتف', 'جوال', 'تلفون', 'phone'],
    'ايفون': ['iphone', 'apple', 'ابل', 'هاتف', 'جوال', 'برو ماكس'],
    'سامسونج': ['samsung', 'جالكسي', 'galaxy', 'الترا', 'ultra', 'جوال', 'هاتف'],
    'لابتوب': ['حاسوب', 'كمبيوتر محمول', 'ماك بوك', 'laptop', 'notebook', 'dell', 'macbook', 'lenovo', 'thinkpad'],
    'حاسوب': ['كمبيوتر', 'لابتوب', 'pc', 'computer'],
    'كمبيوتر': ['حاسوب', 'لابتوب', 'pc'],
    'ماك بوك': ['macbook', 'apple', 'ابل', 'لابتوب'],
    'بلايستيشن': ['سوني', 'playstation', 'ps5', 'ps4', 'ألعاب', 'قيمنق', 'gaming'],
    'سوني': ['بلايستيشن', 'playstation', 'ps5'],
    'ساعة': ['watch', 'smartwatch', 'ساعة ذكية', 'ابل واتش'],
    'دراجة': ['سيكل', 'عجلة', 'bike', 'bicycle'],
    'شاشة': ['تلفزيون', 'tv', 'monitor'],
    'سيارة': ['مركبة', 'car', 'auto'],
  };

  /// Expands user query into search terms including synonyms
  static List<String> expandQuery(String query) {
    final clean = query.trim().toLowerCase();
    final terms = <String>{clean};

    final words = clean.split(RegExp(r'\s+'));
    for (var w in words) {
      terms.add(w);
      for (var entry in _synonyms.entries) {
        if (entry.key == w || entry.value.contains(w)) {
          terms.add(entry.key);
          terms.addAll(entry.value);
        }
      }
    }

    return terms.toList();
  }

  /// "من يريد منتجي؟" (Who wants my item?):
  /// Finds market users who are explicitly seeking what my item offers
  static List<ItemModel> findWhoWantsMyItem({
    required ItemModel myItem,
    required List<ItemModel> allMarketItems,
  }) {
    final myKeywords = <String>{
      myItem.title.toLowerCase(),
      myItem.brand.toLowerCase(),
      myItem.model.toLowerCase(),
      myItem.categoryName.toLowerCase(),
    };

    // Add synonyms of my brand and category
    for (var k in myKeywords.toList()) {
      for (var entry in _synonyms.entries) {
        if (entry.key == k || entry.value.contains(k)) {
          myKeywords.add(entry.key);
          myKeywords.addAll(entry.value);
        }
      }
    }

    final matchedItems = <ItemModel>[];

    for (var target in allMarketItems) {
      if (target.userId == myItem.userId) continue;

      // 1. Direct Category Match
      if (target.wantedCategoryId != null && target.wantedCategoryId == myItem.categoryId) {
        matchedItems.add(target);
        continue;
      }

      // 2. Text Search in Wanted Description
      final wantedDesc = target.wantedDescription.toLowerCase();
      bool found = false;
      for (var keyword in myKeywords) {
        if (keyword.length > 2 && wantedDesc.contains(keyword)) {
          found = true;
          break;
        }
      }

      if (found) {
        matchedItems.add(target);
      }
    }

    return matchedItems;
  }
}
