import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/admin_banner_model.dart';
import '../../providers/banner_provider.dart';

class AdminBannerManagementScreen extends StatefulWidget {
  const AdminBannerManagementScreen({super.key});

  @override
  State<AdminBannerManagementScreen> createState() => _AdminBannerManagementScreenState();
}

class _AdminBannerManagementScreenState extends State<AdminBannerManagementScreen> {
  final _tagController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedIcon = 'star';

  @override
  void dispose() {
    _tagController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showAddBannerDialog(BuildContext context) {
    _tagController.text = '📢 إعلان جديد';
    _titleController.clear();
    _descController.clear();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.campaign, color: AppColors.primary),
              SizedBox(width: 8),
              Text('إضافة إعلان جديد للشريط'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    labelText: 'شارة الإعلان (الوسام العلوي)',
                    hintText: 'مثال: 🚀 قناة المطور أو 🔥 عرض خاص',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الإعلان *',
                    hintText: 'مثال: بدلها - صفقات حصرية اليوم',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'نص ووصف الإعلان *',
                    hintText: 'اكتب نص الإعلان الذي سيظهر في الشريط المتحرك...',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('الأيقونة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedIcon,
                      items: const [
                        DropdownMenuItem(value: 'star', child: Text('⭐ نجمة ذهبية')),
                        DropdownMenuItem(value: 'shield', child: Text('🛡️ درع أمان')),
                        DropdownMenuItem(value: 'swap', child: Text('🔄 مقايضة')),
                        DropdownMenuItem(value: 'campaign', child: Text('📢 بوق إعلان')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDlgState(() => _selectedIcon = v);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.trim().isEmpty) return;

                final newBanner = AdminBannerModel(
                  id: 'banner_${DateTime.now().millisecondsSinceEpoch}',
                  tag: _tagController.text.trim().isNotEmpty ? _tagController.text.trim() : '📢 إعلان الإدارة',
                  title: _titleController.text.trim(),
                  description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : 'إعلان رسمي من إدارة تطبيق بدلها.',
                  iconType: _selectedIcon,
                  createdAt: DateTime.now().toIso8601String(),
                );

                await Provider.of<BannerProvider>(context, listen: false).addBanner(newBanner);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('نشر الإعلان فوراً'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bannerProv = Provider.of<BannerProvider>(context);
    final banners = bannerProv.allBanners;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الشريط الإعلاني (Admin)'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBannerDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('إعلان جديد'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F4845),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'هذه اللوحة خاصة بإدارة التطبيق فقط. تتيح لك نشر وتعديل وتفعيل الإعلانات المتحركة التي تظهر لجميع الزوار أعلى واجهة السوق.',
                    style: TextStyle(fontSize: 12, color: Colors.white, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'الإعلانات المسجلة (${banners.length}):',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (banners.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('لا توجد إعلانات حالياً.')))
          else
            ...banners.map((b) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: b.isActive ? const Color(0xFF0F4845) : Colors.grey.shade300,
                      child: Icon(
                        b.iconType == 'shield'
                            ? Icons.shield
                            : b.iconType == 'swap'
                                ? Icons.swap_horiz
                                : Icons.star,
                        color: b.isActive ? const Color(0xFFFFCC00) : Colors.grey,
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(child: Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(b.tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                        ),
                      ],
                    ),
                    subtitle: Text(b.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: b.isActive,
                          onChanged: (val) => bannerProv.toggleBanner(b.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () => bannerProv.deleteBanner(b.id),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
