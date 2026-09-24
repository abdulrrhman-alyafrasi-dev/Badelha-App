import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badelha_app/data/models/item_model.dart';
import 'package:badelha_app/data/models/user_model.dart';
import 'package:badelha_app/data/services/session_service.dart';
import 'package:badelha_app/domain/services/matching_engine.dart';
import 'package:badelha_app/domain/services/circular_swap_engine.dart';
import 'package:badelha_app/domain/services/semantic_search_engine.dart';
import 'package:badelha_app/domain/services/trust_calculator.dart';

void main() {
  group('1. Matching Engine Algorithmic Tests (30% + 25% + 15% + 15% + 15%)', () {
    final itemA = ItemModel(
      id: 'item_a',
      userId: 'user_a',
      categoryId: 'cat_phones',
      title: 'سامسونج Galaxy S23 Ultra',
      description: 'جهاز بحالة ممتازة',
      brand: 'Samsung',
      model: 'Galaxy S23',
      condition: 'ممتاز',
      quality: 'أصلي',
      estimatedValue: 2800.0,
      city: 'صنعاء',
      phoneNumber: '+967771234567',
      wantedDescription: 'لابتوب ديل XPS',
      wantedCategoryId: 'cat_laptops',
      createdAt: '2026-03-10',
    );

    final itemB = ItemModel(
      id: 'item_b',
      userId: 'user_b',
      categoryId: 'cat_laptops',
      title: 'Dell XPS 15',
      description: 'لابتوب نظيف جداً',
      brand: 'Dell',
      model: 'XPS 15',
      condition: 'ممتاز',
      quality: 'أصلي',
      estimatedValue: 3000.0,
      city: 'صنعاء',
      phoneNumber: '+967779876543',
      wantedDescription: 'سامسونج S23 الترا',
      wantedCategoryId: 'cat_phones',
      createdAt: '2026-03-11',
    );

    test('Computes high match compatibility with clear reasons and cash diff', () {
      final match = MatchingEngine.evaluateMatch(myItem: itemA, targetItem: itemB);

      // Verify calculation components
      expect(match.totalScore, greaterThanOrEqualTo(80));
      expect(match.locationScore, equals(15)); // Same city 'صنعاء'
      expect(match.qualityScore, equals(15)); // Both 'ممتاز' & 'أصلي'
      expect(match.reasons.isNotEmpty, isTrue);

      // Verify suggested cash difference: 3000 - 2800 = 200
      expect(match.suggestedCashDifference, equals(200.0));
      expect(match.cashPayer, equals('user_pays'));
    });
  });

  group('2. Circular Swap Engine Tests (A -> B -> C -> A)', () {
    final user1 = UserModel(id: 'u1', name: 'أحمد', phone: '111', password: '', city: 'الرياض', createdAt: '');
    final user2 = UserModel(id: 'u2', name: 'باسم', phone: '222', password: '', city: 'الرياض', createdAt: '');
    final user3 = UserModel(id: 'u3', name: 'جمال', phone: '333', password: '', city: 'الرياض', createdAt: '');

    final item1 = ItemModel(
      id: 'it1',
      userId: 'u1',
      categoryId: 'cat_phones',
      title: 'هاتف آيفون 13',
      description: '',
      condition: 'ممتاز',
      estimatedValue: 2000,
      city: 'الرياض',
      phoneNumber: '111',
      wantedDescription: 'بلايستيشن 5',
      wantedCategoryId: 'cat_gaming',
      createdAt: '',
    );

    final item2 = ItemModel(
      id: 'it2',
      userId: 'u2',
      categoryId: 'cat_gaming',
      title: 'PlayStation 5',
      description: '',
      condition: 'ممتاز',
      estimatedValue: 2000,
      city: 'الرياض',
      phoneNumber: '222',
      wantedDescription: 'لابتوب ديل',
      wantedCategoryId: 'cat_laptops',
      createdAt: '',
    );

    final item3 = ItemModel(
      id: 'it3',
      userId: 'u3',
      categoryId: 'cat_laptops',
      title: 'لابتوب Dell XPS',
      description: '',
      condition: 'ممتاز',
      estimatedValue: 2000,
      city: 'الرياض',
      phoneNumber: '333',
      wantedDescription: 'هاتف آيفون',
      wantedCategoryId: 'cat_phones',
      createdAt: '',
    );

    test('Detects 3-way triangular barter cycle correctly', () {
      final cycles = CircularSwapEngine.findTriangularSwaps(
        allItems: [item1, item2, item3],
        allUsers: [user1, user2, user3],
      );

      expect(cycles.isNotEmpty, isTrue);
      expect(cycles.first.compatibilityScore, equals(94));
    });
  });

  group('3. Semantic Search Engine & Synonym Expansion', () {
    test('Expands colloquial and technical synonyms correctly', () {
      final expandedJawal = SemanticSearchEngine.expandQuery('جوال');
      expect(expandedJawal.contains('هاتف'), isTrue);
      expect(expandedJawal.contains('phone'), isTrue);

      final expandedLaptop = SemanticSearchEngine.expandQuery('لابتوب');
      expect(expandedLaptop.contains('حاسوب'), isTrue);
      expect(expandedLaptop.contains('notebook'), isTrue);
    });
  });

  group('4. Trust Calculator Tests', () {
    test('Computes accurate trust score and badges', () {
      final user = UserModel(
        id: 'u_test',
        name: 'عبدالرحمن',
        phone: '+967771234567',
        password: '',
        city: 'صنعاء',
        createdAt: '',
        rating: 4.9,
        isVerified: true,
        swapsCompleted: 18,
      );

      final score = TrustCalculator.calculateScore(user);
      expect(score, greaterThanOrEqualTo(90));

      final title = TrustCalculator.getTrustLevelTitle(score);
      expect(title.isNotEmpty, isTrue);
    });
  });

  group('5. Role-Based Access Control (RBAC) & User Security', () {
    test('Default user role is strictly customer and status is active', () {
      final customer = UserModel(
        id: 'c1',
        name: 'محمد',
        phone: '770000001',
        password: 'pass',
        city: 'صنعاء',
        createdAt: '2026-03-01',
      );

      expect(customer.role, equals('customer'));
      expect(customer.isCustomer, isTrue);
      expect(customer.isAdmin, isFalse);
      expect(customer.isMerchant, isFalse);
      expect(customer.isActive, isTrue);
      expect(customer.isBanned, isFalse);
    });

    test('Merchant and Admin accounts enforce proper role badges and flags', () {
      final merchant = UserModel(
        id: 'm1',
        name: 'متجر صنعاء',
        phone: '770000002',
        password: 'pass',
        city: 'صنعاء',
        role: 'merchant',
        status: 'active',
        createdAt: '2026-03-01',
      );
      expect(merchant.isMerchant, isTrue);
      expect(merchant.isAdmin, isFalse);

      final admin = UserModel(
        id: 'a1',
        name: 'المدير العام',
        phone: '777777777',
        password: 'pass',
        city: 'صنعاء',
        role: 'admin',
        status: 'active',
        createdAt: '2026-03-01',
      );
      expect(admin.isAdmin, isTrue);
      expect(admin.isCustomer, isFalse);

      final bannedUser = customerCopyWithStatus(merchant, 'banned');
      expect(bannedUser.isBanned, isTrue);
      expect(bannedUser.isActive, isFalse);
    });
  });

  group('6. Product Listing Lifecycle & Expiration System', () {
    test('Listing correctly computes expiration date and statuses', () {
      final item = ItemModel(
        id: 'it_test',
        userId: 'u1',
        categoryId: 'cat_phones',
        title: 'iPhone 14 Pro',
        description: 'نظيف جداً',
        condition: 'ممتاز',
        estimatedValue: 3500,
        city: 'صنعاء',
        phoneNumber: '771234567',
        createdAt: DateTime.now().toIso8601String(),
        status: 'Available',
      );

      expect(item.isAvailable, isTrue);
      expect(item.isExpired, isFalse);
      expect(item.expiresAt.isNotEmpty, isTrue);

      // Verify expiration transition
      final expiredItem = item.copyWith(status: 'Expired');
      expect(expiredItem.isExpired, isTrue);
      expect(expiredItem.isAvailable, isFalse);
    });
  });

  group('7. Persistent Authentication & Laravel Sanctum Token Session', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Generates realistic Laravel Sanctum token format (id|token)', () {
      final token = SessionService.generateSanctumToken('user_172000000');
      expect(token.contains('|'), isTrue);
      final parts = token.split('|');
      expect(parts.length, equals(2));
      expect(parts[0].isNotEmpty, isTrue);
      expect(parts[1].length, equals(48));
    });

    test('Saves, retrieves, and validates active persistent session', () async {
      expect(await SessionService.hasValidSession(), isFalse);

      final token = SessionService.generateSanctumToken('user_test_99');
      await SessionService.saveSession(token: token, userId: 'user_test_99', role: 'customer');

      expect(await SessionService.hasValidSession(), isTrue);
      expect(await SessionService.getAccessToken(), equals(token));
      expect(await SessionService.getUserId(), equals('user_test_99'));
      expect(await SessionService.getUserRole(), equals('customer'));

      // Test Logout / Purge Session
      await SessionService.clearSession();
      expect(await SessionService.hasValidSession(), isFalse);
      expect(await SessionService.getAccessToken(), isNull);
      expect(await SessionService.getUserId(), isNull);
    });
  });
}

UserModel customerCopyWithStatus(UserModel user, String status) {
  return user.copyWith(status: status);
}
