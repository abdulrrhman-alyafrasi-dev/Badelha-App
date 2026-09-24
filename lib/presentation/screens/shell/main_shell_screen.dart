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
  late final PageController _pageController;

  final List<Widget> _screens = [
    const MarketplaceScreen(),
    const SmartMatchesScreen(),
    const SizedBox(), // Placeholder for Add Item
    const ExploreScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.init();
      if (mounted) {
        final userId = auth.currentUser?.id ?? '';
        Provider.of<MarketplaceProvider>(context, listen: false).init(userId);
        if (userId.isNotEmpty) {
          Provider.of<NotificationProvider>(context, listen: false).loadNotifications(userId);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notif = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppColors.brandHeroGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sync_alt, color: Colors.white, size: 16),
              ),
            ],
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
                  style: TextStyle(fontSize: 10, color: Colors.brown, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        actions: [
          // Login prompt if Guest
          if (!auth.isLoggedIn)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (c) => const LoginScreen(returnAfterLogin: true)),
                );
              },
              icon: const Icon(Icons.login, size: 16, color: AppColors.primary),
              label: const Text('دخول', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            )
          else ...[
            // Circular Swap Icon
            IconButton(
              icon: const Icon(Icons.all_inclusive, color: AppColors.secondary),
              tooltip: 'المقايضة الدائرية (3 أطراف)',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CircularSwapScreen()),
                );
              },
            ),
            // Notifications Icon with badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    );
                  },
                ),
                if (notif.unreadCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${notif.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          if (index == 2) {
            AuthGuard.verify(
              context,
              actionDescription: 'إضافة منتج للمقايضة',
              onAllowed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddItemScreen()),
                );
              },
            );
            _pageController.jumpToPage(_currentIndex);
          } else {
            setState(() => _currentIndex = index);
          }
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Guard Add Item against guest
            AuthGuard.verify(
              context,
              actionDescription: 'إضافة منتج للمقايضة',
              onAllowed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddItemScreen()),
                );
              },
            );
          } else {
            setState(() => _currentIndex = index);
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
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
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add, color: Colors.white, size: 22),
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
