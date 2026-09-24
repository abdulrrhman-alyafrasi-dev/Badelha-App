import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/intents_helper.dart';
import '../../../data/models/store_model.dart';

class StoreProfileScreen extends StatelessWidget {
  final StoreModel store;

  const StoreProfileScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Store Banner and App Bar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                store.storeName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.brandHeroGradient,
                ),
                child: Center(
                  child: Icon(Icons.storefront, size: 80, color: Colors.white.withAlpha(50)),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification Badge Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, color: AppColors.primary, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'متجر تجاري معتمد ومرخص',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.accent, size: 16),
                          const SizedBox(width: 4),
                          Text(store.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Store Bio
                  Text(
                    store.bio,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                  ),

                  const SizedBox(height: 14),

                  // Location & Contact Row
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(store.city, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                      const SizedBox(width: 16),
                      const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('${store.itemsCount} عروض مقايضة نشطة', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Contact Store Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => IntentsHelper.makePhoneCall(store.phone, context),
                          icon: const Icon(Icons.phone),
                          label: const Text('اتصال بالمتجر'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => IntentsHelper.sendSms(phoneNumber: store.phone, itemTitle: store.storeName, context: context),
                          icon: const Icon(Icons.sms),
                          label: const Text('مراسلة SMS'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 10),

                  const Text(
                    'أجهزة وعروض مقايضة المتجر:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_moon_outlined, color: AppColors.primary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'جميع صفقات هذا المتجر تخضع لضمان تجربة فحص 30 يوم من المتجر مباشرة.',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
