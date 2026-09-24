import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SwapSafetyDialog extends StatefulWidget {
  final String offerTitle;
  final VoidCallback onConfirmed;

  const SwapSafetyDialog({
    super.key,
    required this.offerTitle,
    required this.onConfirmed,
  });

  static Future<void> show(
    BuildContext context, {
    required String offerTitle,
    required VoidCallback onConfirmed,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SwapSafetyDialog(
        offerTitle: offerTitle,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<SwapSafetyDialog> createState() => _SwapSafetyDialogState();
}

class _SwapSafetyDialogState extends State<SwapSafetyDialog> {
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Icon & Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.amber, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'إقرار وإرشادات أمان المقايضة',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Offer Title Badge / Highlight
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'العرض: ${widget.offerTitle}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),

              // Official Disclaimer Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'عزيزنا العميل:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '«بدلها» هو سوق ذكي لمساعدتك في اكتشاف وتنظيم فرص المقايضة بين المستخدمين.\n\n'
                      'يرجى العلم بأن التطبيق لا يتضمن أي آلية لتحويل الأموال أو حجزها أو الدفع الإلكتروني، وتعتمد المقايضة كلياً على التبادل المادي المباشر بين الطرفين وجهاً لوجه.\n\n'
                      'نوصي الطرفين بشدة بالالتقاء شخصياً في مكان عام وآمن، وفحص السلع والتحقق من حالتها ومطابقتها والتأكد من موثوقية الطرف الآخر قبل تسليم أي سلعة أو إتمام التبادل.\n\n'
                      'غايتنا فقط توفير بيئة منظمة وآمنة لاكتشاف فرص التبادل.',
                      style: TextStyle(fontSize: 12, height: 1.6, color: Color(0xFF374151)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Checklist recommendations
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: const [
                    _CheckItem(text: 'حدد موعداً ومكاناً عاماً نهاراً (كالأسواق أو المراكز التجارية).'),
                    _CheckItem(text: 'افحص السلعة المعروضة وجربها بنفسك قبل إتمام المقايضة.'),
                    _CheckItem(text: 'تأكد من تسليم الفروق النقدية المتفق عليها يداً بيد.'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Mandatory Consent Checkbox
              CheckboxListTile(
                value: _agreedToTerms,
                onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text(
                  'أوافق على شروط المقايضة وسياسة الأمان والتحقق المباشر.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _agreedToTerms
                          ? () {
                              Navigator.of(context).pop();
                              widget.onConfirmed();
                            }
                          : null,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('تأكيد إتمام الصفقة', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;
  const _CheckItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}