import '../../data/models/circular_swap_model.dart';
import '../../data/models/item_model.dart';
import '../../data/models/user_model.dart';

class CircularSwapEngine {
  /// Detects 3-way circular barter cycles:
  /// User A has Item A, desires what User B offers (Item B)
  /// User B has Item B, desires what User C offers (Item C)
  /// User C has Item C, desires what User A offers (Item A)
  /// Result: Complete cycle A -> B -> C -> A where everyone's trade request is fulfilled!
  static List<CircularSwapModel> findTriangularSwaps({
    required List<ItemModel> allItems,
    required List<UserModel> allUsers,
  }) {
    final List<CircularSwapModel> results = [];
    final userMap = {for (var u in allUsers) u.id: u};

    // Filter available items with different owners
    final available = allItems.where((i) => i.status == 'Available').toList();

    for (int i = 0; i < available.length; i++) {
      final itemA = available[i];

      for (int j = 0; j < available.length; j++) {
        if (i == j) continue;
        final itemB = available[j];
        if (itemB.userId == itemA.userId) continue;

        // Does A want what B has?
        if (!_isSatisfiedBy(itemA, itemB)) continue;

        for (int k = 0; k < available.length; k++) {
          if (k == i || k == j) continue;
          final itemC = available[k];
          if (itemC.userId == itemA.userId || itemC.userId == itemB.userId) continue;

          // Does B want what C has?
          if (!_isSatisfiedBy(itemB, itemC)) continue;

          // Does C want what A has? (Closing the circle!)
          if (_isSatisfiedBy(itemC, itemA)) {
            final userA = userMap[itemA.userId] ??
                UserModel(id: itemA.userId, name: itemA.userName, phone: itemA.phoneNumber, password: '', city: itemA.city, createdAt: '');
            final userB = userMap[itemB.userId] ??
                UserModel(id: itemB.userId, name: itemB.userName, phone: itemB.phoneNumber, password: '', city: itemB.city, createdAt: '');
            final userC = userMap[itemC.userId] ??
                UserModel(id: itemC.userId, name: itemC.userName, phone: itemC.phoneNumber, password: '', city: itemC.city, createdAt: '');

            final cycleId = '${itemA.id}_${itemB.id}_${itemC.id}';
            // Avoid duplicates of permutations
            final exists = results.any((r) =>
                (r.itemA.id == itemA.id && r.itemB.id == itemB.id && r.itemC.id == itemC.id) ||
                (r.itemA.id == itemB.id && r.itemB.id == itemC.id && r.itemC.id == itemA.id) ||
                (r.itemA.id == itemC.id && r.itemB.id == itemA.id && r.itemC.id == itemB.id));

            if (!exists) {
              results.add(CircularSwapModel(
                id: cycleId,
                userA: userA,
                itemA: itemA,
                userB: userB,
                itemB: itemB,
                userC: userC,
                itemC: itemC,
                compatibilityScore: 94,
                summary:
                    'صفقة تبادل ثلاثية: ${userA.name} يعطي (${itemA.title}) إلى ${userC.name}، و ${userC.name} يعطي (${itemC.title}) إلى ${userB.name}، و ${userB.name} يعطي (${itemB.title}) إلى ${userA.name}!',
              ));
            }
          }
        }
      }
    }

    return results;
  }

  static bool _isSatisfiedBy(ItemModel seekerItem, ItemModel candidateItem) {
    // 1. Direct category match
    if (seekerItem.wantedCategoryId != null &&
        seekerItem.wantedCategoryId == candidateItem.categoryId) {
      return true;
    }

    // 2. Keyword match in wanted description
    final wanted = seekerItem.wantedDescription.toLowerCase();
    final candidateKeywords = '${candidateItem.title} ${candidateItem.brand} ${candidateItem.model} ${candidateItem.categoryName}'.toLowerCase();

    final words = wanted.split(RegExp(r'[\s,]+')).where((w) => w.length > 2);
    for (var word in words) {
      if (candidateKeywords.contains(word)) {
        return true;
      }
    }

    return false;
  }
}
