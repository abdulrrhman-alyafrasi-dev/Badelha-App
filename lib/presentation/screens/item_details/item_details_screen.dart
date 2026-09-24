import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/auth_guard.dart';
import '../../../core/utils/intents_helper.dart';
import '../../../core/widgets/trust_badge.dart';
import '../../../data/models/item_model.dart';
import '../../widgets/item_image_widget.dart';
import '../../providers/auth_provider.dart';
import 'widgets/make_offer_modal.dart';
import 'widgets/owner_management_panel.dart';

class ItemDetailsScreen extends StatefulWidget {
  final ItemModel item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int _activeImageIndex = 0;
  late ItemModel _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentItem;
    final auth = Provider.of<AuthProvider>(context);
    final isMyOwnItem = auth.currentUser?.id == item.userId || (auth.currentUser?.isAdmin ?? false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(item.brand.isNotEmpty ? '${item.brand} ${item.model}' : item.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ رابط مشاركة صفقة المقايضة!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: Colors.redAccent),
            tooltip: AppStrings.reportListing,
            onPressed: () => _showReportDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery Slider
            Stack(
              children: [
                ItemImageWidget(
                  images: item.images.isNotEmpty && _activeImageIndex < item.images.length
                      ? [item.images[_activeImageIndex]]
                      : (item.images.isNotEmpty ? [item.images.first] : const []),
                  categoryId: item.categoryId,
                  width: MediaQuery.of(context).size.width,
                  height: 260,
                  borderRadius: 0,
                ),
                if (item.images.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        item.images.length,
                        (index) => GestureDetector(
                          onTap: () => setState(() => _activeImageIndex = index),
                          child: Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _activeImageIndex == index
                                  ? AppColors.primary
                                  : Colors.white.withAlpha(180),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Value Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.estimatedValue.toStringAsFixed(0)} ${AppStrings.currency}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const Text(
                            AppStrings.estimatedValue,
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Specifications Grid
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _specCell('الحالة', item.condition, Icons.check_circle_outline),
                            _specCell('الجودة', item.quality, Icons.verified_outlined),
                          ],
                        ),
                        const Divider(height: 16, color: AppColors.border),
                        Row(
                          children: [
                            _specCell('المدينة', item.city, Icons.location_on_outlined),
                            _specCell('الماركة', item.brand.isNotEmpty ? item.brand : 'عام', Icons.category_outlined),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // What Owner Wants (Golden Section)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withAlpha(80)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: AppColors.primaryDark, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'ماذا يريد صاحب المنتج في المقابل؟',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.wantedDescription,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        if (item.swapType == 'Swap+Cash') ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'يقبل مقايضة متوازنة مع دفع أو استلام فرق مالي (Swap + Cash)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'تفاصيل المنتج والمواصفات:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Owner Trust & Profile Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: _getUserAvatarProvider(item.userImage),
                          child: (item.userImage.isEmpty || _getUserAvatarProvider(item.userImage) == null)
                              ? Text(
                                  item.userName.isNotEmpty ? item.userName[0] : 'U',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.userName,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  if (item.userIsVerified) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, color: AppColors.primary, size: 16),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              TrustBadge(
                                trustScore: item.userTrustScore,
                                rating: item.userRating,
                                isVerified: item.userIsVerified,
                                compact: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 🛡️ Conditional Ownership Controls:
                  // If NOT my own item -> Show direct communication channels + propose swap offer
                  // If my own item (or Admin) -> Show Owner Management Panel (NO communication channels)
                  if (!isMyOwnItem) ...[
                    // Direct Communication Section (Phone & SMS Intents)
                    const Text(
                      'قنوات التواصل المباشر مع المقايض:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Phone Call Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              AuthGuard.verify(
                                context,
                                actionDescription: 'الاتصال بالمقايض',
                                onAllowed: () => IntentsHelper.makePhoneCall(item.phoneNumber, context),
                              );
                            },
                            icon: const Icon(Icons.phone_in_talk, size: 16),
                            label: const Text(AppStrings.contactOwner, style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // SMS Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              AuthGuard.verify(
                                context,
                                actionDescription: 'إرسال رسائل SMS للمقايض',
                                onAllowed: () => IntentsHelper.sendSms(
                                  phoneNumber: item.phoneNumber,
                                  itemTitle: item.title,
                                  context: context,
                                ),
                              );
                            },
                            icon: const Icon(Icons.sms_outlined, size: 16),
                            label: const Text(AppStrings.sendSms, style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Email Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              AuthGuard.verify(
                                context,
                                actionDescription: 'مراسلة المقايض عبر الإيميل',
                                onAllowed: () {
                                  IntentsHelper.sendEmail(
                                    email: item.userEmail.isNotEmpty ? item.userEmail : '${item.phoneNumber}@badelha.ye',
                                    itemTitle: item.title,
                                    ownerName: item.userName,
                                    context: context,
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.email_outlined, size: 16),
                            label: const Text('إيميل', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Propose Swap Action (Big Button)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AuthGuard.verify(
                            context,
                            actionDescription: 'تقديم عروض المقايضة',
                            onAllowed: () => MakeOfferModal.show(context, targetItem: item),
                          );
                        },
                        icon: const Icon(Icons.swap_horiz, size: 22),
                        label: const Text(
                          'تقديم عرض مقايضة فوري من ممتلكاتك',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ] else ...[
                    // 🛡️ Owner Control Panel (No contact channels)
                    OwnerManagementPanel(
                      item: item,
                      onUpdated: (updated) {
                        setState(() {
                          _currentItem = updated;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specCell(String title, String val, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إبلاغ عن محتوى أو منتج'),
        content: const Text('هل تشتبه في مخالفة هذا المنتج لسياسات المقايضة في منصة بدلها؟ سيقوم فريق المراجعة بفحصه فوراً.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('شكراً لمساهمتك، تم استلام البلاغ وسيتم التدقيق.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('إرسال البلاغ'),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getUserAvatarProvider(String image) {
    if (image.isEmpty) return null;
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return NetworkImage(image);
    }
    final file = File(image);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }
}
