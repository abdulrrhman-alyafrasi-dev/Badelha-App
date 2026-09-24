import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/auth_guard.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/notification_provider.dart';
import '../add_item/add_item_screen.dart';
import '../auth/login_screen.dart';
import '../circular_swap/circular_swap_screen.dart';
import '../explore/explore_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../matching/smart_matches_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MarketplaceScreen(),
    SmartMatchesScreen(),
    SizedBox.shrink(), // Placeholder لن يتم الانتقال إليه في الـ Stack
    ExploreScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      await auth.init();

      if (!mounted) return;
      final userId = auth.currentUser?.id ?? '';
      context.read<MarketplaceProvider>().init(userId);

      if (userId.isNotEmpty) {
        context.read<NotificationProvider>().loadNotifications(userId);
      }
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == 2) {
      // التحقق من صلاحية المستخدم قبل فتح صفحة الإضافة كشاشة كاملة
      AuthGuard.verify(
        context,
        actionDescription: 'إضافة منتج للمقايضة',
        onAllowed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notif = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 54,
        leading: Center(
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: AppColors.brandHeroGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sync_alt, color: Colors.white, size: 16),
          ),
        ),
        title: Row(
          children: [
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 8),
            if (!auth.isLoggedIn)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: const Text(
                  'متصفح فقط',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          if (!auth.isLoggedIn)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (c) => const LoginScreen(returnAfterLogin: true),
                  ),
                );
              },
              icon: const Icon(Icons.login, size: 16, color: AppColors.primary),
              label: const Text(
                'دخول',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.all_inclusive, color: AppColors.secondary),
              tooltip: 'المقايضة الدائرية (3 أطراف)',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CircularSwapScreen(),
                  ),
                );
              },
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                if (notif.unreadCount > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${notif.unreadCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: AppStrings.navMarket,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt_outlined),
            activeIcon: Icon(Icons.bolt),
            label: AppStrings.navFoundForYou,
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
            label: AppStrings.navAddItem,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: AppStrings.navExplore,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}