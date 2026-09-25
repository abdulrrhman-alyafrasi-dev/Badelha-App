import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/intents_helper.dart';
import '../../../data/models/circular_swap_model.dart';
import '../../providers/swap_provider.dart';

class CircularSwapScreen extends StatefulWidget {
  const CircularSwapScreen({super.key});

  @override
  State<CircularSwapScreen> createState() => _CircularSwapScreenState();
}

class _CircularSwapScreenState extends State<CircularSwapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SwapProvider>(context, listen: false).loadCircularSwaps();
    });
  }

  @override
  Widget build(BuildContext context) {
    final swap = Provider.of<SwapProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المقايضة الدائرية (3 أطراف)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => swap.loadCircularSwaps(),
          ),
        ],
      ),
      body: swap.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Educational Concept Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandHeroGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(60),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.change_circle_outlined, color: Colors.white, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'ما هي المقايضة الدائرية؟ (Circular Barter)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'عندما لا يتطابق شخصان مباشرة، يقوم محرك "بدلها" باكتشاف حلقة ثلاثية مغلقة (A → B → C → A) يحصل فيها كل شخص على ما يحتاجه تماماً بدون دفع أموال!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (swap.circularSwaps.isEmpty)
                  _buildNoCyclesFound(context)
                else ...[
                  Row(
                    children: [
                      const Icon(Icons.hub_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'تم اكتشاف ${swap.circularSwaps.length} حلقات تبادل ثلاثية مغلقة:',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...swap.circularSwaps.map((cycle) => _buildCycleCard(context, cycle)),
                ],
              ],
            ),
    );
  }

  Widget _buildNoCyclesFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.all_inclusive, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'لا توجد حلقات دائرية مكتملة حالياً',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'مع زيادة عدد الإعلانات في السوق، سيكتشف المحرك حلقات المقايضة الثلاثية تلقائياً.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleCard(BuildContext context, CircularSwapModel cycle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.secondary, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top cycle badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sync, color: AppColors.secondary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'توافق الحلقة: ${cycle.compatibilityScore}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  '3 مقايضين • 3 أجهزة',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Visual 3-step Chain
            _buildChainStep(
              number: '1',
              fromUser: cycle.userA.name,
              itemOffered: cycle.itemA.title,
              toUser: cycle.userC.name,
              phone: cycle.itemA.phoneNumber,
            ),
            _buildConnectingArrow(),
            _buildChainStep(
              number: '2',
              fromUser: cycle.userC.name,
              itemOffered: cycle.itemC.title,
              toUser: cycle.userB.name,
              phone: cycle.itemC.phoneNumber,
            ),
            _buildConnectingArrow(),
            _buildChainStep(
              number: '3',
              fromUser: cycle.userB.name,
              itemOffered: cycle.itemB.title,
              toUser: cycle.userA.name,
              phone: cycle.itemB.phoneNumber,
            ),

            const SizedBox(height: 16),

            // Explanation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                cycle.summary,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4),
              ),
            ),

            const SizedBox(height: 16),

            // Action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إرسال إشعارات التنسيق للأطراف الثلاثة لبدء المقايضة الدائرية!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.share_arrival_time_outlined),
                label: const Text('تنسيق وإطلاق الصفقة الثلاثية'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChainStep({
    required String number,
    required String fromUser,
    required String itemOffered,
    required String toUser,
    required String phone,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary,
            child: Text(number, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                children: [
                  TextSpan(text: fromUser, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' يعطي '),
                  TextSpan(text: '($itemOffered)', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const TextSpan(text: ' إلى '),
                  TextSpan(text: toUser, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, size: 18, color: AppColors.primary),
            onPressed: () => IntentsHelper.makePhoneCall(phone, context),
            tooltip: 'اتصال',
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Center(
        child: Icon(Icons.arrow_downward, size: 18, color: AppColors.secondary),
      ),
    );
  }
}
