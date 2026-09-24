import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/dialogs/confirmation_dialog.dart';
import '../../../data/models/item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/marketplace_provider.dart';
import '../screens/item_details/item_details_screen.dart';
import '../screens/item_details/widgets/edit_item_modal.dart';
import 'item_image_widget.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const ItemCard({
    super.key,
    required this.item,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    // الاستماع لحالة المستخدم فقط لتحديث أزرار الإدارة تلقائياً
    final auth = context.watch<AuthProvider>();
    final isOwner = auth.currentUser != null &&
        (auth.currentUser!.id == item.userId || auth.currentUser!.isAdmin);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isFeatured ? const Color(0xFFFFD700) : const Color(0xFFE2E8F0),
          width: item.isFeatured ? 1.5 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(item.isFeatured ? 16 : 8),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ItemDetailsScreen(item: item),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Image Thumbnail Container with Overlay Badges
              Stack(
                children: [
                  ItemImageWidget(
                    images: item.images,
                    categoryId: item.categoryId,
                    width: double.infinity,
                    height: 98,
                    borderRadius: 12,
                    fit: BoxFit.cover,
                  ),

                  // Featured Badge Overlay
                  if (item.isFeatured)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 10, color: Colors.black),
                            SizedBox(width: 2),
                            Text(
                              'مميز',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Favorite Heart Button Overlay
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onFavoriteToggle,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(220),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: isFavorite ? Colors.red : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Trust Score Badge
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield, size: 9, color: Color(0xFF00A86B)),
                          const SizedBox(width: 2),
                          Text(
                            'ثقة ${item.userTrustScore}%',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Card Content Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title & Price Header
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.estimatedValue.toStringAsFixed(0)} ${AppStrings.currency}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),

                      // Barter Target "يريد:" Pill Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(30),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sync_alt, size: 10, color: AppColors.primary),
                            const SizedBox(width: 3),
                            const Text(
                              'يريد: ',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.wantedDescription,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // User Info & Location Row
                      Row(
                        children: [
                          _buildMiniAvatar(item),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.userName.isNotEmpty ? item.userName : 'مقايض',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            item.city,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // Footer Specs & Action Badges Row
                      Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _specBadge(
                                    item.condition,
                                    const Color(0xFFF8FAFC),
                                    AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 3),
                                  _specBadge(
                                    item.swapType == 'Swap+Cash' ? 'فرق مالي' : 'رأس برأس',
                                    item.swapType == 'Swap+Cash'
                                        ? const Color(0xFFFEF3C7)
                                        : const Color(0xFFE0F2FE),
                                    item.swapType == 'Swap+Cash'
                                        ? const Color(0xFF92400E)
                                        : const Color(0xFF0369A1),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (isOwner) ...[
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => EditItemModal.show(context, item: item),
                                borderRadius: BorderRadius.circular(4),
                                child: const Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  ConfirmationDialog.show(
                                    context,
                                    title: 'تأكيد الحذف',
                                    message: 'هل تريد حذف "${item.title}"؟',
                                    confirmText: 'حذف',
                                    onConfirm: () async {
                                      final market = context.read<MarketplaceProvider>();
                                      await market.deleteUserItem(
                                        item.id,
                                        currentUserId: auth.currentUser?.id ?? '',
                                        isAdmin: auth.currentUser?.isAdmin ?? false,
                                      );
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: const Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Icon(
                                    Icons.delete_outline,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniAvatar(ItemModel item) {
    final hasValidUrl = item.userImage.isNotEmpty &&
        (item.userImage.startsWith('http://') || item.userImage.startsWith('https://'));

    if (hasValidUrl) {
      return CircleAvatar(
        radius: 9,
        backgroundColor: AppColors.primaryLight,
        backgroundImage: NetworkImage(item.userImage),
        onBackgroundImageError: (_, __) {},
        child: item.userName.isNotEmpty
            ? Text(
                item.userName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              )
            : null,
      );
    }

    return CircleAvatar(
      radius: 9,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        item.userName.isNotEmpty ? item.userName[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _specBadge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textCol.withAlpha(40), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
          color: textCol,
        ),
      ),
    );
  }
}