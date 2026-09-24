import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/buttons/app_primary_button.dart';
import '../../../../data/models/item_model.dart';
import '../../../../data/models/swap_offer_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/marketplace_provider.dart';
import '../../../providers/swap_provider.dart';

/// Reusable Modal to Submit a Swap Proposal
class MakeOfferModal extends StatefulWidget {
  final ItemModel targetItem;

  const MakeOfferModal({super.key, required this.targetItem});

  static Future<void> show(BuildContext context, {required ItemModel targetItem}) {
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    if (market.myItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ليس لديك منتجات مضافة للمقايضة بعد. أضف منتجاً أولاً لتقدمه كعرض!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return Future.value();
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => MakeOfferModal(targetItem: targetItem),
    );
  }

  @override
  State<MakeOfferModal> createState() => _MakeOfferModalState();
}

class _MakeOfferModalState extends State<MakeOfferModal> {
  late ItemModel _selectedItem;
  final _cashDiffCtrl = TextEditingController(text: '0');
  final _messageCtrl = TextEditingController();
  String _cashPayer = 'sender';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    _selectedItem = market.myItems.first;
    _updateCashDiff();
  }

  void _updateCashDiff() {
    final diff = widget.targetItem.estimatedValue - _selectedItem.estimatedValue;
    if (diff > 0) {
      _cashDiffCtrl.text = diff.toStringAsFixed(0);
      _cashPayer = 'sender';
    } else if (diff < 0) {
      _cashDiffCtrl.text = (-diff).toStringAsFixed(0);
      _cashPayer = 'receiver';
    } else {
      _cashDiffCtrl.text = '0';
    }
  }

  @override
  void dispose() {
    _cashDiffCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final swap = Provider.of<SwapProvider>(context, listen: false);

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sync_alt, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'تقديم عرض مقايضة رسمي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'أنت تطلب: ${widget.targetItem.title} (${widget.targetItem.estimatedValue.toStringAsFixed(0)} ريال)',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'اختر من منتجاتك المعروضة للمقايضة:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: AppDimensions.borderRadiusMD,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ItemModel>(
                  isExpanded: true,
                  value: _selectedItem,
                  items: market.myItems.map((item) {
                    return DropdownMenuItem<ItemModel>(
                      value: item,
                      child: Text('${item.title} (${item.estimatedValue.toStringAsFixed(0)} ريال)'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedItem = val;
                        _updateCashDiff();
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'فرق مالي مقترح يدويًا (Swap + Cash اختياري):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cashDiffCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'المبلغ الإضافي إن وجد',
                      suffixText: 'ريال',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _cashPayer,
                  items: const [
                    DropdownMenuItem(value: 'sender', child: Text('سأدفعه أنا')),
                    DropdownMenuItem(value: 'receiver', child: Text('يدفعه الطرف الآخر')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _cashPayer = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('رسالة توضيحية لصاحب السلعة:'),
            const SizedBox(height: 6),
            TextField(
              controller: _messageCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'مثال: جهازي بحالة ممتازة ومعه كافة أغراضه ومستعد للمعاينة...',
              ),
            ),
            const SizedBox(height: 20),
            AppPrimaryButton(
              text: 'إرسال عرض المقايضة الآن',
              loading: _isSending,
              onPressed: () async {
                final double cash = double.tryParse(_cashDiffCtrl.text) ?? 0.0;
                final offer = SwapOfferModel(
                  id: 'offer_' + DateTime.now().millisecondsSinceEpoch.toString(),
                  senderId: auth.currentUser?.id ?? 'user_1',
                  receiverId: widget.targetItem.userId,
                  offeredItemId: _selectedItem.id,
                  requestedItemId: widget.targetItem.id,
                  cashDifference: cash,
                  cashPayer: _cashPayer,
                  message: _messageCtrl.text,
                  createdAt: DateTime.now().toIso8601String(),
                );

                setState(() => _isSending = true);
                try {
                  await swap.sendSwapOffer(offer);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 تم إرسال عرض المقايضة بنجاح! سيتم إشعار الطرف الآخر.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) setState(() => _isSending = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
