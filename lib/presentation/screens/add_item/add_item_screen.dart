import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../auth/login_screen.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _descController = TextEditingController();
  final _valueController = TextEditingController();
  final _wantedController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedCategory = 'cat_phones';
  String _condition = 'ممتاز';
  String _quality = 'أصلي وكالة';
  int _quantity = 1;
  String _city = 'صنعاء';
  String _swapType = 'Direct';
  String _selectedImageTag = 'phone';
  String? _pickedImagePath;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> _visualPresets = [
    {'tag': 'phone', 'label': 'هاتف ذكي', 'icon': Icons.smartphone, 'color': Color(0xFF00A86B)},
    {'tag': 'laptop', 'label': 'حاسوب محمول', 'icon': Icons.laptop_mac, 'color': Color(0xFF4F46E5)},
    {'tag': 'gaming', 'label': 'منصة ألعاب', 'icon': Icons.sports_esports, 'color': Color(0xFFE11D48)},
    {'tag': 'watch', 'label': 'ساعة ذكية', 'icon': Icons.watch, 'color': Color(0xFFD97706)},
    {'tag': 'car', 'label': 'مركبة ودراجة', 'icon': Icons.directions_bike, 'color': Color(0xFF0891B2)},
    {'tag': 'home', 'label': 'أجهزة منزلية', 'icon': Icons.home, 'color': Color(0xFF7C3AED)},
  ];

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser != null && auth.currentUser!.phone.isNotEmpty) {
      _phoneController.text = auth.currentUser!.phone;
    }
    if (auth.currentUser != null && AppConstants.yemenGovernorates.contains(auth.currentUser!.city)) {
      _city = auth.currentUser!.city;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _descController.dispose();
    _valueController.dispose();
    _wantedController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          _pickedImagePath = file.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر اختيار الصورة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final market = Provider.of<MarketplaceProvider>(context);

    // 1. Guard against guest access
    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('إضافة منتج للمقايضة')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, size: 56, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                const Text(
                  'تسجيل الدخول مطلوب لإضافة منتجاتك',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'أنت تتصفح التطبيق كزائر. لإضافة سلعك وحمايتها وتلقي عروض المقايضة، يرجى تسجيل الدخول أو إنشاء حساب جديد مجاناً.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (c) => const LoginScreen(returnAfterLogin: true)),
                      );
                    },
                    child: const Text('تسجيل الدخول / إنشاء حساب الآن'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Safe Category Fallback
    final List<CategoryModel> safeCategories = market.categories.isNotEmpty
        ? market.categories
        : [
            CategoryModel(id: 'cat_phones', name: 'هواتف ذكية', icon: 'smartphone'),
            CategoryModel(id: 'cat_laptops', name: 'لابتوبات وحواسيب', icon: 'laptop_mac'),
            CategoryModel(id: 'cat_gaming', name: 'ألعاب ومنصات فيديو', icon: 'sports_esports'),
            CategoryModel(id: 'cat_electronics', name: 'إلكترونيات عامة', icon: 'devices'),
            CategoryModel(id: 'cat_watches', name: 'ساعات ذكية', icon: 'watch'),
            CategoryModel(id: 'cat_home', name: 'المنزل والأجهزة', icon: 'home'),
            CategoryModel(id: 'cat_vehicles', name: 'مركبات ودراجات', icon: 'directions_bike'),
          ];

    final bool categoryFound = safeCategories.any((c) => c.id == _selectedCategory);
    final String activeCategoryId = categoryFound ? _selectedCategory : safeCategories.first.id;

    // 3. Safe City Fallback (Strictly Yemen Governorates)
    final bool cityFound = AppConstants.yemenGovernorates.contains(_city);
    final String activeCity = cityFound ? _city : 'صنعاء';

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج جديد للمقايضة'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Notice: Phone & Safety
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(80)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.primaryDark),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'رقم الهاتف إجباري لضمان جدية المقايضة وسرعة تواصل الأطراف معاً داخل محافظتك.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 4. Mandatory Product Image Section
            _buildMandatoryImageSection(),

            const SizedBox(height: 18),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'اسم المنتج وعنوان الإعلان *',
                hintText: 'مثال: سامسونج جالكسي S23 الترا 512GB',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال اسم المنتج' : null,
            ),

            const SizedBox(height: 14),

            // Category & City (Strictly Yemen Only & Overflow-safe)
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: activeCategoryId,
                    decoration: const InputDecoration(labelText: 'الفئة *'),
                    items: safeCategories.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          c.name,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: activeCity,
                    decoration: const InputDecoration(labelText: 'المحافظة (اليمن) *'),
                    items: AppConstants.yemenGovernorates.map((gov) {
                      return DropdownMenuItem(
                        value: gov,
                        child: Text(
                          gov,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _city = v);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Brand & Model
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'الماركة / الشركة',
                      hintText: 'مثال: Samsung, Apple',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: 'الموديل',
                      hintText: 'مثال: S23, XPS 15',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Condition & Quality (Fully guarded and isExpanded: true)
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: const ['جديد بالكرتون', 'شبه جديد', 'ممتاز', 'جيد جداً', 'مقبول'].contains(_condition) ? _condition : 'ممتاز',
                    decoration: const InputDecoration(labelText: 'حالة المنتج *'),
                    items: const [
                      DropdownMenuItem(value: 'جديد بالكرتون', child: Text('جديد بالكرتون', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'شبه جديد', child: Text('شبه جديد', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'ممتاز', child: Text('ممتاز', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'جيد جداً', child: Text('جيد جداً', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'مقبول', child: Text('مقبول', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _condition = v);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: const ['أصلي وكالة', 'درجة أولى', 'تجاري'].contains(_quality) ? _quality : 'أصلي وكالة',
                    decoration: const InputDecoration(labelText: 'الجودة *'),
                    items: const [
                      DropdownMenuItem(value: 'أصلي وكالة', child: Text('أصلي وكالة', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'درجة أولى', child: Text('درجة أولى', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'تجاري', child: Text('تجاري', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _quality = v);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Estimated Value & Quantity
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'القيمة التقديرية للسلعة *',
                      hintText: 'مثال: 2500',
                      suffixText: 'ريال',
                    ),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'أدخل قيمة رقمية صحيحة' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: _quantity.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الكمية *',
                      hintText: '1',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'أدخل الكمية';
                      final val = int.tryParse(v.trim());
                      if (val == null || val <= 0) return 'كمية غير صالحة';
                      return null;
                    },
                    onChanged: (v) {
                      final val = int.tryParse(v.trim());
                      if (val != null && val > 0) {
                        _quantity = val;
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // What do you want in return? (The Barter Anchor)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(120)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.swap_horizontal_circle, color: AppColors.primaryDark, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'ماذا تريد الحصول عليه بالمقابل؟ *',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _wantedController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'حدد بدقة ما تبحث عنه لمساعدة محرك المطابقة الذكي (مثلاً: لابتوب بمواصفات جرافيكس، أو بلايستيشن 5)...',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'يرجى كتابة ما ترغب به في المقابل' : null,
                  ),
                  const SizedBox(height: 10),
                  // Dropdown with isExpanded: true (FIXES RIGHT OVERFLOW BY 83 PIXELS)
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: const ['Direct', 'Swap+Cash', 'Any'].contains(_swapType) ? _swapType : 'Direct',
                    decoration: const InputDecoration(labelText: 'نوع المقايضة المقبول لديك'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Direct',
                        child: Text(
                          'مقايضة مباشرة فقط (رأس برأس)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Swap+Cash',
                        child: Text(
                          'مقايضة مع إمكانية دفع أو استلام فرق مالي (Swap + Cash)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Any',
                        child: Text(
                          'أي عرض مناسب متوافق',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _swapType = v);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Description
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'وصف تفصيلي لحالة السلعة والمرفقات',
                hintText: 'مدة الاستخدام، حالة الشاشة والبطارية، الفاتورة الأصلية، إلخ...',
              ),
            ),

            const SizedBox(height: 14),

            // Mandatory Phone Number
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف للتواصل المباشر والرسائل (إجباري) *',
                hintText: '771234567 أو 711234567',
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (v) => v == null || v.trim().length < 8 ? 'رقم الهاتف إجباري للمقايضة' : null,
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          // Check Mandatory Image
                          if (_pickedImagePath == null && _selectedImageTag.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⚠️ صورة المنتج إجبارية! يرجى التقاط صورة أو اختيارها من المعرض لعرض سلعتك في السوق.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() => _isSubmitting = true);

                          try {
                            final currentUserId = auth.currentUser!.id;

                            // Update phone if edited
                            if (auth.currentUser!.phone != _phoneController.text.trim()) {
                              await auth.updatePhoneNumber(_phoneController.text.trim());
                            }

                            String imagePayload = _selectedImageTag;
                            if (_pickedImagePath != null) {
                              try {
                                final file = File(_pickedImagePath!);
                                if (await file.exists()) {
                                  final bytes = await file.readAsBytes();
                                  imagePayload = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                                } else {
                                  imagePayload = _pickedImagePath!;
                                }
                              } catch (e) {
                                imagePayload = _pickedImagePath!;
                              }
                            }

                            final newItem = ItemModel(
                              id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                              userId: currentUserId,
                              categoryId: activeCategoryId,
                              title: _titleController.text.trim(),
                              description: _descController.text.trim().isNotEmpty
                                  ? _descController.text.trim()
                                  : 'منتج متاح للمقايضة الفورية بحالة ممتازة.',
                              brand: _brandController.text.trim(),
                              model: _modelController.text.trim(),
                              condition: _condition,
                              quality: _quality,
                              quantity: _quantity,
                              estimatedValue: double.tryParse(_valueController.text) ?? 1000.0,
                              city: activeCity,
                              phoneNumber: _phoneController.text.trim(),
                              wantedDescription: _wantedController.text.trim(),
                              swapType: _swapType,
                              status: 'Available',
                              createdAt: DateTime.now().toIso8601String(),
                            );

                            await market.addNewItem(newItem, [imagePayload]);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🎉 تم نشر منتجك في سوق بدلها بنجاح! يبحث المحرك عن مطابقات مناسبة الآن.'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setState(() => _isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('حدث خطأ أثناء إضافة المنتج: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(
                  _isSubmitting ? 'جاري نشر السلعة وحفظ البيانات...' : 'نشر المنتج في السوق وبدء المطابقة',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMandatoryImageSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (_pickedImagePath != null || _selectedImageTag.isNotEmpty)
              ? AppColors.primary
              : Colors.red.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'صورة المنتج المعروض (إجبارية للعرض في السوق) *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
              ),
              const Spacer(),
              if (_pickedImagePath != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('✓ صورة حقيقية', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Image Preview or Placeholder
          if (_pickedImagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.file(
                    File(_pickedImagePath!),
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.white),
                        onPressed: () => setState(() => _pickedImagePath = null),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Camera & Gallery Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text('التقاط بالكاميرا'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('اختيار من المعرض'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),

          // Visual Preset Tags (Quick Fallback Visuals)
          const Text(
            'أو حدد نوع ومظهر الجهاز سريعاً:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _visualPresets.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final preset = _visualPresets[i];
                final isSelected = _selectedImageTag == preset['tag'] && _pickedImagePath == null;
                final color = preset['color'] as Color;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageTag = preset['tag'];
                      _pickedImagePath = null; // Prioritize chosen preset if tapped
                    });
                  },
                  child: Container(
                    width: 76,
                    decoration: BoxDecoration(
                      color: isSelected ? color.withAlpha(25) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? color : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(preset['icon'] as IconData, color: color, size: 22),
                        const SizedBox(height: 3),
                        Text(
                          preset['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
