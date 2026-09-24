import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/buttons/app_primary_button.dart';
import '../../../../data/models/item_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/marketplace_provider.dart';

/// 📝 Reusable Modal Bottom Sheet to Edit an Item
class EditItemModal extends StatefulWidget {
  final ItemModel item;
  final ValueChanged<ItemModel>? onUpdated;

  const EditItemModal({
    super.key,
    required this.item,
    this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required ItemModel item,
    ValueChanged<ItemModel>? onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => EditItemModal(item: item, onUpdated: onUpdated),
    );
  }

  @override
  State<EditItemModal> createState() => _EditItemModalState();
}

class _EditItemModalState extends State<EditItemModal> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _wantedCtrl;
  late final TextEditingController _descCtrl;

  late String _editCondition;
  late String _editQuality;
  late String _editCity;
  late String _editSwapType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item.title);
    _valueCtrl = TextEditingController(text: widget.item.estimatedValue.toStringAsFixed(0));
    _wantedCtrl = TextEditingController(text: widget.item.wantedDescription);
    _descCtrl = TextEditingController(text: widget.item.description);

    _editCondition = widget.item.condition;
    _editQuality = widget.item.quality;
    _editCity = widget.item.city;
    _editSwapType = widget.item.swapType;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _valueCtrl.dispose();
    _wantedCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final market = Provider.of<MarketplaceProvider>(context, listen: false);

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
                const Icon(Icons.edit_note, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'تعديل بيانات السلعة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Title
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'اسم السلعة وعنوان الإعلان *',
              ),
            ),
            const SizedBox(height: 12),

            // Value & City
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _valueCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'القيمة التقديرية (ريال) *',
                      suffixText: 'ريال',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: AppConstants.yemenGovernorates.contains(_editCity) ? _editCity : 'صنعاء',
                    decoration: const InputDecoration(labelText: 'المحافظة *'),
                    items: AppConstants.yemenGovernorates.map((gov) {
                      return DropdownMenuItem(
                        value: gov,
                        child: Text(gov, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _editCity = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Condition & Quality
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: const ['جديد بالكرتون', 'شبه جديد', 'ممتاز', 'جيد جداً', 'مقبول'].contains(_editCondition)
                        ? _editCondition
                        : 'ممتاز',
                    decoration: const InputDecoration(labelText: 'الحالة'),
                    items: const [
                      DropdownMenuItem(value: 'جديد بالكرتون', child: Text('جديد بالكرتون', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'شبه جديد', child: Text('شبه جديد', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'ممتاز', child: Text('ممتاز', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'جيد جداً', child: Text('جيد جداً', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'مقبول', child: Text('مقبول', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _editCondition = v);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: const ['Direct', 'Swap+Cash', 'Any'].contains(_editSwapType) ? _editSwapType : 'Direct',
                    decoration: const InputDecoration(labelText: 'نوع المقايضة'),
                    items: const [
                      DropdownMenuItem(value: 'Direct', child: Text('مباشرة فقط', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Swap+Cash', child: Text('مقايضة + كاش', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Any', child: Text('أي عرض', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _editSwapType = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Wanted Description
            TextField(
              controller: _wantedCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'ماذا تريد بالمقابل؟ *',
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'الوصف والملاحظات',
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
            AppPrimaryButton(
              text: 'حفظ التعديلات فوراً',
              loading: _isSaving,
              onPressed: () async {
                if (_titleCtrl.text.trim().isEmpty) return;

                final updated = widget.item.copyWith(
                  title: _titleCtrl.text.trim(),
                  estimatedValue: double.tryParse(_valueCtrl.text) ?? widget.item.estimatedValue,
                  city: _editCity,
                  condition: _editCondition,
                  quality: _editQuality,
                  swapType: _editSwapType,
                  wantedDescription: _wantedCtrl.text.trim(),
                  description: _descCtrl.text.trim(),
                );

                setState(() => _isSaving = true);
                await market.updateUserItem(
                  updated,
                  widget.item.images,
                  currentUserId: auth.currentUser?.id ?? '',
                  isAdmin: auth.currentUser?.isAdmin ?? false,
                );

                widget.onUpdated?.call(updated);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('⚡ تم تحديث بيانات السلعة فوراً بنجاح!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
