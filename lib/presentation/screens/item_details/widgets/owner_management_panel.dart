import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/cards/remaining_time_badge.dart';
import '../../../../core/widgets/dialogs/confirmation_dialog.dart';
import '../../../../data/models/item_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/marketplace_provider.dart';
import 'edit_item_modal.dart';

/// Owner Control Panel for Item Details Screen
class OwnerManagementPanel extends StatelessWidget {
  final ItemModel item;
  final ValueChanged<ItemModel>? onUpdated;
  final VoidCallback? onDeleted;

  const OwnerManagementPanel({
    super.key,
    required this.item,
    this.onUpdated,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final market = Provider.of<MarketplaceProvider>(context, listen: false);

    return Container(
      padding: AppDimensions.paddingLG,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: AppDimensions.borderRadiusXL,
        border: Border.all(color: AppColors.primary.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.manage_accounts, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'لوحة إدارة منتجك الخاص',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
              ),
              const Spacer(),
              RemainingTimeBadge(
                createdAt: item.createdAt,
                expiresAt: item.expiresAt,
                status: item.status,
                compact: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Edit Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => EditItemModal.show(context, item: item, onUpdated: onUpdated),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('تعديل السلعة', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusMD),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Refresh Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final success = await market.refreshListing(item.id, auth.currentUser!.id);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✨ تم تجديد الإعلان بنجاح ورفعه لقمة نتائج السوق!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('تجديد العرض', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusMD),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ConfirmationDialog.show(
                      context,
                      title: 'تأكيد حذف المنتج',
                      message: 'هل أنت متأكد من رغبتك في حذف "' + item.title + '" نهائياً من السوق؟ لن يتمكن المقايضون من رؤيته بعد الآن.',
                      confirmText: 'نعم، حذف نهائي',
                      onConfirm: () async {
                        final success = await market.deleteUserItem(
                          item.id,
                          currentUserId: auth.currentUser?.id ?? '',
                          isAdmin: auth.currentUser?.isAdmin ?? false,
                        );
                        if (context.mounted) {
                          onDeleted?.call();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? '🗑️ تم حذف المنتج من السوق بنجاح!' : 'حدث خطأ أثناء الحذف.'),
                              backgroundColor: success ? AppColors.primary : Colors.red,
                            ),
                          );
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.delete_forever, size: 16),
                  label: const Text('حذف', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusMD),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
