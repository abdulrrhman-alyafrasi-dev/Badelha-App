import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/intents_helper.dart';
import '../../../core/widgets/match_badge.dart';
import '../../../data/models/match_result_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/matching_provider.dart';
import '../auth/login_screen.dart';
import '../item_details/item_details_screen.dart';
import '../../widgets/item_image_widget.dart';

class SmartMatchesScreen extends StatefulWidget {
  const SmartMatchesScreen({super.key});

  @override
  State<SmartMatchesScreen> createState() => _SmartMatchesScreenState();
}

class _SmartMatchesScreenState extends State<SmartMatchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<MatchingProvider>(context, listen: false)
            .findMatchesForUser(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final matching = Provider.of<MatchingProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.navFoundForYou)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                  child: const Icon(Icons.bolt, size: 56, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                const Text(
                  'خاصية "وجدنا لك" تتطلب تسجيل الدخول',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'سجل دخولك وأضف ممتلكاتك ليقوم المحرك الذكي باكتشاف أفضل صفقات المقايضة المتوافقة مع رغباتك فوراً وبنسب مئوية شفافة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (c) => const LoginScreen(returnAfterLogin: true)),
                    );
                  },
                  child: const Text('تسجيل الدخول / إنشاء حساب'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navFoundForYou),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (auth.currentUser != null) {
                matching.findMatchesForUser(auth.currentUser!.id);
              }
            },
          ),
        ],
      ),
      body: matching.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'محرك بدلها الذكي يحلل آلاف التوافقات في السوق...',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : matching.matches.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: matching.matches.length,
                  itemBuilder: (context, index) {
                    final match = matching.matches[index];
                    return _buildMatchCard(context, match);
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد مطابقات مباشرة حالياً لمنتجاتك',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'أضف منتجات أكثر أو حدد رغبات دقيقة لما تبحث عنه ليقوم المحرك باكتشاف الصفقات التوافقية فور توفرها.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                if (auth.currentUser != null) {
                  Provider.of<MatchingProvider>(context, listen: false)
                      .findMatchesForUser(auth.currentUser!.id);
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة فحص السوق الآن'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, MatchResultModel match) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Header: 92% Match
            Row(
              children: [
                MatchBadge(score: match.totalScore, isLarge: true),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: AppColors.primaryDark),
                      SizedBox(width: 4),
                      Text(
                        'صفقة رابحة مقترحة',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Barter Visual Exchange: My Item ↔ Target Item
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  // Left (My Item)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ItemImageWidget(
                          images: match.userItem.images,
                          width: 60,
                          height: 60,
                          borderRadius: 10,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'منتجك المعروض',
                          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                        Text(
                          match.userItem.title,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${match.userItem.estimatedValue.toStringAsFixed(0)} ريال',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ),

                  // Center Swap Arrow
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withAlpha(50), blurRadius: 6),
                      ],
                    ),
                    child: const Icon(Icons.swap_horiz, color: AppColors.primary, size: 24),
                  ),

                  // Right (Target Item)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ItemImageWidget(
                          images: match.targetItem.images,
                          width: 60,
                          height: 60,
                          borderRadius: 10,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'المقايض: ${match.targetItem.userName}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                        Text(
                          match.targetItem.title,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${match.targetItem.estimatedValue.toStringAsFixed(0)} ريال',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Transparent Explanation: Why did this match appear? (تفسير النتائج)
            const Text(
              'لماذا تم اقتراح هذه الصفقة لك؟ (تحليل الأسباب):',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: match.reasons.map((reason) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Contact & Deal Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ItemDetailsScreen(item: match.targetItem),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('معاينة وبدء الصفقة'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () {
                    IntentsHelper.makePhoneCall(match.targetItem.phoneNumber, context);
                  },
                  icon: const Icon(Icons.phone),
                  tooltip: 'اتصال فوري بالمقايض',
                ),
                const SizedBox(width: 4),
                IconButton.filledTonal(
                  onPressed: () {
                    IntentsHelper.sendSms(
                      phoneNumber: match.targetItem.phoneNumber,
                      itemTitle: match.targetItem.title,
                      context: context,
                    );
                  },
                  icon: const Icon(Icons.sms),
                  tooltip: 'إرسال SMS سريع',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
