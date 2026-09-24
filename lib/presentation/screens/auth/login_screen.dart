import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/badelha_logo.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/matching_provider.dart';
import '../../providers/notification_provider.dart';
import '../shell/main_shell_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../merchant/store_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool returnAfterLogin;

  const LoginScreen({super.key, this.returnAfterLogin = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login Controllers
  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  String _regCity = 'صنعاء';
  String _regRole = 'customer';
  String? _regAvatarPath;
  final ImagePicker _picker = ImagePicker();

  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeyRegister = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regPhoneController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  void fillDemoAccount(String phone, String password) {
    _loginPhoneController.text = phone;
    _loginPasswordController.text = password;

    _tabController.animateTo(0);

    setState(() {});
  }

  void _onSuccessLogin(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user != null) {
      Provider.of<MarketplaceProvider>(
        context,
        listen: false,
      ).loadUserItems(user.id);
      Provider.of<MatchingProvider>(
        context,
        listen: false,
      ).findMatchesForUser(user.id);
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).loadNotifications(user.id);

      // Post-Login Routing based on user role
      if (user.isAdmin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
        return;
      } else if (user.isMerchant) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const StoreDashboardScreen()),
        );
        return;
      }
    }

    if (widget.returnAfterLogin && Navigator.canPop(context)) {
      Navigator.pop(context, true);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainShellScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('تسجيل الدخول / إنشاء حساب'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const BadelhaLogo(size: 70, showText: true, showTagline: true),
              const SizedBox(height: 20),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: 'تسجيل الدخول'),
                    Tab(text: 'حساب جديد'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tab Views
              SizedBox(
                height: 520,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Login Form
                    Form(
                      key: _formKeyLogin,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _loginPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'رقم الهاتف *',
                              prefixIcon: Icon(Icons.phone),
                              hintText: 'مثال: 771234567',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'يرجى إدخال رقم الهاتف'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _loginPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'كلمة المرور *',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'يرجى إدخال كلمة المرور'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : () async {
                                      if (_formKeyLogin.currentState!
                                          .validate()) {
                                        final ok = await auth.login(
                                          _loginPhoneController.text,
                                          _loginPasswordController.text,
                                        );
                                        if (context.mounted) {
                                          if (ok) {
                                            _onSuccessLogin(context);
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  auth.authError ??
                                                      'رقم الهاتف أو كلمة المرور غير صحيحة',
                                                ),
                                                backgroundColor:
                                                    AppColors.error,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('دخول إلى السوق'),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const Text(
                            'الدخول بحسابات جاهزة',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'اختيار حساب جاهز للتجربة',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('مدير النظام'),
                              ),
                              DropdownMenuItem(
                                value: 'abdurahman',
                                child: Text('عبدالرحمن اليفرسي'),
                              ),
                              DropdownMenuItem(
                                value: 'tech',
                                child: Text('متجر التكنولوجيا الحديثة'),
                              ),
                              DropdownMenuItem(
                                value: 'ahmed',
                                child: Text('أحمد المقايض'),
                              ),
                              DropdownMenuItem(
                                value: 'sara',
                                child: Text('سارة الشامري'),
                              ),
                            ],
                            onChanged: (value) {
                              switch (value) {
                                case 'admin':
                                  fillDemoAccount('777000000', 'admin123');
                                  break;

                                case 'abdurahman':
                                  fillDemoAccount('772442264', 'password123');
                                  break;

                                case 'tech':
                                  fillDemoAccount('777111222', 'password123');
                                  break;

                                case 'ahmed':
                                  fillDemoAccount('771234567', 'password123');
                                  break;

                                case 'sara':
                                  fillDemoAccount('772345678', 'password123');
                                  break;
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // Tab 2: Register Form
                    Form(
                      key: _formKeyRegister,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Optional Avatar Picker
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 34,
                                    backgroundColor: AppColors.primaryLight,
                                    backgroundImage: _regAvatarPath != null
                                        ? FileImage(File(_regAvatarPath!))
                                        : null,
                                    child: _regAvatarPath == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 38,
                                            color: AppColors.primary,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final XFile? file = await _picker
                                            .pickImage(
                                              source: ImageSource.gallery,
                                              imageQuality: 80,
                                            );
                                        if (file != null) {
                                          setState(
                                            () => _regAvatarPath = file.path,
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'الصورة الشخصية (اختيارية)',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _regNameController,
                              decoration: const InputDecoration(
                                labelText: 'الاسم الكامل *',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'يرجى إدخال الاسم'
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _regPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'رقم الهاتف (للاتصال والتواصل) *',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              validator: (v) => v == null || v.trim().length < 8
                                  ? 'أدخل رقم هاتف صحيح'
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _regEmailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText:
                                    'البريد الإلكتروني (اختياري للمراسلة)',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue:
                                  AppConstants.yemenGovernorates.contains(
                                    _regCity,
                                  )
                                  ? _regCity
                                  : 'صنعاء',
                              decoration: const InputDecoration(
                                labelText: 'المحافظة (اليمن) *',
                                prefixIcon: Icon(Icons.location_city),
                              ),
                              items: AppConstants.yemenGovernorates.map((gov) {
                                return DropdownMenuItem(
                                  value: gov,
                                  child: Text(
                                    gov,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _regCity = v);
                              },
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _regRole,
                              decoration: const InputDecoration(
                                labelText: 'نوع الحساب في المنصة *',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'customer',
                                  child: Text(
                                    'عميل عادي (مستخدم شخصي للمقايضة)',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'merchant',
                                  child: Text(
                                    'متجر تجاري معتمد (محل جوالات / إلكترونيات)',
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _regRole = v);
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _regPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'كلمة المرور *',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (v) => v == null || v.length < 4
                                  ? 'كلمة المرور 4 أحرف على الأقل'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: auth.isLoading
                                    ? null
                                    : () async {
                                        if (_formKeyRegister.currentState!
                                            .validate()) {
                                          final ok = await auth.register(
                                            name: _regNameController.text,
                                            phone: _regPhoneController.text,
                                            password:
                                                _regPasswordController.text,
                                            city: _regCity,
                                            role: _regRole,
                                            image: _regAvatarPath ?? '',
                                            email: _regEmailController.text
                                                .trim(),
                                          );
                                          if (context.mounted) {
                                            if (ok) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    '🎉 تم إنشاء حسابك بنجاح! مرحباً بك في بدلها.',
                                                  ),
                                                  backgroundColor:
                                                      AppColors.primary,
                                                ),
                                              );
                                              _onSuccessLogin(context);
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    auth.authError ??
                                                        'حدث خطأ أثناء التسجيل، ربما الرقم مسجل مسبقاً.',
                                                  ),
                                                  backgroundColor:
                                                      AppColors.error,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('إنشاء الحساب وبدء المقايضة'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Continue as Guest Option
              TextButton.icon(
                onPressed: () {
                  auth.logout(); // Explicitly guest
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainShellScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                ),
                label: const Text(
                  'المتابعة كمتصفح فقط (بدون تسجيل دخول)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
