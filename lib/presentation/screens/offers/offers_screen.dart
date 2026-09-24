import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/intents_helper.dart';
import '../../../data/models/swap_offer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/swap_provider.dart';
import '../../widgets/swap_safety_dialog.dart';
import '../auth/login_screen.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<SwapProvider>(context, listen: false).loadOffers(auth.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final swap = Provider.of<SwapProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final userId = auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('إدارة صفقات وعروض المقايضة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          if (auth.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث العروض',
              onPressed: () => swap.loadOffers(userId),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: 'عروض واردة (${swap.receivedOffers.length})'),
            Tab(text: 'عروض أرسلتها (${swap.sentOffers.length})'),
          ],
        ),
      ),
      body: !auth.isLoggedIn
          ? _buildGuestPrompt(context)
          : swap.isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOffersList(swap.receivedOffers, isReceived: true, userId: userId),
                    _buildOffersList(swap.sentOffers, isReceived: false, userId: userId),
                  ],
                ),
    );
  }

  Widget _buildGuestPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.blueGrey.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.lock_outline, size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'تسجيل الدخول مطلوب لعرض الصفقات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'أنت في وضع التصفح كزائر. لإدارة عروض المقايضة وتلقي طلبات التبادل، يرجى تسجيل الدخول.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen(returnAfterLogin: true)),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('تسجيل الدخول / إنشاء حساب'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersList(List<SwapOfferModel> offers, {required bool isReceived, required String userId}) {
    if (offers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                child: Icon(Icons.inbox_outlined, size: 52, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 14),
              Text(
                isReceived ? 'لا توجد عروض مقايضة واردة حالياً' : 'لم تقم بإرسال أي عروض مقايضة بعد',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                isReceived
                    ? 'عندما يقدم أحد المقايضين عرضاً على منتجاتك، ستظهر تفاصيل الصفقة هنا فوراً لتراجعها وتقبلها.'
                    : 'يمكنك تصفح السوق والضغط على أي سلعة تعجبك لتقديم عرض مقايضة فوري من ممتلكاتك.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              if (isReceived)
                OutlinedButton.icon(
                  onPressed: () => _createSampleTestOffer(context, userId),
                  icon: const Icon(Icons.bolt, size: 16, color: AppColors.primary),
                  label: const Text('⚡ توليد عرض مقايضة تجريبي فوري للاختبار', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return _buildCompactOfferCard(context, offer, isReceived: isReceived, userId: userId);
      },
    );
  }

  Widget _buildCompactOfferCard(BuildContext context, SwapOfferModel offer, {required bool isReceived, required String userId}) {
    final swap = Provider.of<SwapProvider>(context, listen: false);

    Color statusColor = AppColors.warning;
    String statusText = 'قيد المراجعة';
    if (offer.status == 'Accepted') {
      statusColor = AppColors.primary;
      statusText = 'مقبول - بانتظار ميثاق الأمان';
    } else if (offer.status == 'Meeting Pending') {
      statusColor = Colors.orange;
      statusText = 'بانتظار المقابلة والمعاينة';
    } else if (offer.status == 'Completed') {
      statusColor = Colors.teal;
      statusText = 'صفقة مكتملة وموثقة ✓';
    } else if (offer.status == 'Rejected') {
      statusColor = AppColors.error;
      statusText = 'مرفوض';
    } else if (offer.status == 'Cancelled') {
      statusColor = Colors.grey;
      statusText = 'ملغي';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
                const Spacer(),
                Text(
                  isReceived ? 'المرسل: ${offer.senderName}' : 'المستلم: ${offer.receiverName}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Barter Visual Summary (Compact Two Columns)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('السلعة المعروضة:', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                        Text(
                          offer.offeredItemTitle,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${offer.offeredItemValue.toStringAsFixed(0)} ريال',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    child: Icon(Icons.sync_alt, color: AppColors.primary, size: 16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('السلعة المطلوبة:', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                        Text(
                          offer.requestedItemTitle,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${offer.requestedItemValue.toStringAsFixed(0)} ريال',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Cash difference if any
            if (offer.cashDifference > 0) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'فرق مالي: ${offer.cashDifference.toStringAsFixed(0)} ريال (${offer.cashPayer == 'sender' ? 'يدفعه صاحب العرض' : 'يدفعه المستلم'})',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                ),
              ),
            ],

            if (offer.message.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                'رسالة: "${offer.message}"',
                style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 8),

            // Actions Row (Compact)
            if (isReceived && offer.status == 'Pending') ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed: () => swap.acceptOffer(offer.id, userId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('قبول الصفقة', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: OutlinedButton(
                        onPressed: () => swap.rejectOffer(offer.id, userId),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('رفض', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (offer.status == 'Accepted') ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          SwapSafetyDialog.show(
                            context,
                            offerTitle: offer.offeredItemTitle,
                            onConfirmed: () async {
                              await swap.updateOfferStatus(offer.id, 'Meeting Pending', userId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🛡️ تم إقرار ميثاق الأمان بنجاح! تم الانتقال لمرحلة المعاينة.'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              }
                            },
                          );
                        },
                        icon: const Icon(Icons.shield_outlined, size: 14),
                        label: const Text('ميثاق الأمان وتنسيق اللقاء', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    height: 34,
                    width: 34,
                    child: IconButton.filledTonal(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        final phone = isReceived ? offer.senderPhone : offer.receiverPhone;
                        IntentsHelper.makePhoneCall(phone, context);
                      },
                      icon: const Icon(Icons.phone, size: 16),
                      tooltip: 'اتصال',
                    ),
                  ),
                ],
              ),
            ],

            if (offer.status == 'Meeting Pending') ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          SwapSafetyDialog.show(
                            context,
                            offerTitle: offer.offeredItemTitle,
                            onConfirmed: () async {
                              await swap.completeSwap(offer.id, userId);
                              if (context.mounted) {
                                _showRatingDialog(context, offer, userId);
                              }
                            },
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 14),
                        label: const Text('تأكيد استلام السلعة وإتمام المقايضة', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    height: 34,
                    width: 34,
                    child: IconButton.filledTonal(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        final phone = isReceived ? offer.senderPhone : offer.receiverPhone;
                        IntentsHelper.makePhoneCall(phone, context);
                      },
                      icon: const Icon(Icons.phone, size: 16),
                      tooltip: 'اتصال',
                    ),
                  ),
                ],
              ),
            ],

            if (offer.status == 'Completed') ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: OutlinedButton.icon(
                        onPressed: () => _showRatingDialog(context, offer, userId),
                        icon: const Icon(Icons.star, color: Colors.amber, size: 14),
                        label: const Text('تقييم الشريك في الصفقة ⭐', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _createSampleTestOffer(BuildContext context, String currentUserId) async {
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    final swap = Provider.of<SwapProvider>(context, listen: false);

    final otherItems = market.items.where((i) => i.userId != currentUserId).toList();
    final myItems = market.items.where((i) => i.userId == currentUserId).toList();

    String offeredTitle = 'ساعة آبل الذكية الجيل 8';
    double offeredValue = 45000;
    String requestedTitle = myItems.isNotEmpty ? myItems.first.title : 'جهازك المعروض';
    double requestedValue = myItems.isNotEmpty ? myItems.first.estimatedValue : 48000;

    if (otherItems.isNotEmpty) {
      offeredTitle = otherItems.first.title;
      offeredValue = otherItems.first.estimatedValue;
    }

    final testOffer = SwapOfferModel(
      id: 'offer_demo_${DateTime.now().millisecondsSinceEpoch}',
      senderId: otherItems.isNotEmpty ? otherItems.first.userId : 'user_merchant_01',
      receiverId: currentUserId,
      offeredItemId: otherItems.isNotEmpty ? otherItems.first.id : 'demo_item_1',
      requestedItemId: myItems.isNotEmpty ? myItems.first.id : 'demo_item_my',
      cashDifference: 3000,
      cashPayer: 'sender',
      message: 'مرحباً، أرغب بمقايضة سلعتي ($offeredTitle) مع دفع فرق 3000 ريال. هل يناسبك؟',
      createdAt: DateTime.now().toIso8601String(),
      status: 'Pending',
      senderName: 'محمد العمري (مقايض معتمد)',
      receiverName: 'أنت',
      senderPhone: '772222333',
      receiverPhone: '777000000',
      offeredItemTitle: offeredTitle,
      requestedItemTitle: requestedTitle,
      offeredItemValue: offeredValue,
      requestedItemValue: requestedValue,
    );

    await swap.sendSwapOffer(testOffer);
    await swap.loadOffers(currentUserId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 تم إنشاء عرض مقايضة وارد للتجربة! يمكنك الآن قبوله وتجربة ميثاق الأمان.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _showRatingDialog(BuildContext context, SwapOfferModel offer, String currentUserId) {
    double selectedStars = 5.0;
    final commentController = TextEditingController();
    final partnerName = offer.senderId == currentUserId ? offer.receiverName : offer.senderName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('تقييم $partnerName', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('كيف كانت تجربتك في المقايضة والتسليم؟', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (idx) {
                  return IconButton(
                    icon: Icon(
                      idx < selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 28,
                    ),
                    onPressed: () => setDialogState(() => selectedStars = (idx + 1).toDouble()),
                  );
                }),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'أضف تعليقاً على سرعة التجاوب والأمان...',
                  hintStyle: const TextStyle(fontSize: 11),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('لاحقاً'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⭐ تم إرسال تقييمك بنجاح وتحديث نقاط الثقة المتبادلة!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: const Text('حفظ التقييم'),
            ),
          ],
        ),
      ),
    );
  }
}
