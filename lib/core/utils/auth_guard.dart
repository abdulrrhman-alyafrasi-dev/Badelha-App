import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../constants/app_colors.dart';

class AuthGuard {
  /// Protects any interactive action (Call, SMS, Swap offer, Add item)
  static bool verify(
    BuildContext context, {
    required String actionDescription,
    required VoidCallback onAllowed,
  }) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.isLoggedIn) {
      onAllowed();
      return true;
    }

    // Show Auth Required Dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('تسجيل الدخول مطلوب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'أنت تتصفح التطبيق حالياً كـ "متصفح فقط".\n\nلإتمام $actionDescription يجب تسجيل الدخول أو إنشاء حساب مجاني لحماية بيانات المقايضة والتواصل.',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (c) => const LoginScreen(returnAfterLogin: true),
                ),
              );
            },
            child: const Text('تسجيل الدخول / حساب جديد'),
          ),
        ],
      ),
    );

    return false;
  }
}
