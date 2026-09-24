import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/matching_provider.dart';
import '../../providers/notification_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';
import '../merchant/store_dashboard_screen.dart';
import '../shell/main_shell_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Intro entrance animation
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    // Ambient breathing / pulsing animation for glowing badge
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _introController.forward();
    _startSessionCheck();
  }

  /// 🔐 Persistent Session Validation & Instant Auto-Routing Flow
  Future<void> _startSessionCheck() async {
    final stopwatch = Stopwatch()..start();

    // Check persistent session immediately
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final hasValidSession = await authProvider.checkSession();

    // Smooth entrance duration (~800ms)
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 800) {
      await Future.delayed(Duration(milliseconds: 800 - elapsed));
    }

    if (!mounted || _navigated) return;
    _navigated = true;

    if (hasValidSession && authProvider.isLoggedIn) {
      final user = authProvider.currentUser!;
      Provider.of<MarketplaceProvider>(context, listen: false).loadUserItems(user.id);
      Provider.of<MatchingProvider>(context, listen: false).findMatchesForUser(user.id);
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications(user.id);

      // Route directly based on role without displaying any login screen
      if (user.isAdmin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else if (user.isMerchant) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StoreDashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShellScreen()),
        );
      }
    } else {
      // No active token -> route to LoginScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF041315),
              Color(0xFF071F23),
              Color(0xFF09292F),
              Color(0xFF020C0D),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Ambient glowing radial backdrop circles
            Positioned(
              top: -60,
              right: -60,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 280 * _pulseAnimation.value,
                    height: 280 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00D084).withAlpha(45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 80,
              left: -70,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withAlpha(25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Content Area with Safe Layout
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top Tag
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withAlpha(30)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified_outlined, color: Color(0xFF00D084), size: 15),
                                      SizedBox(width: 6),
                                      Text(
                                        'سوق المقايضة والتبادل الذكي',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Hero Logo & Brand Identity (Ultra-Luxury Centerpiece)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value,
                                        child: child,
                                      );
                                    },
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(36),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00D084).withAlpha(110),
                                            blurRadius: 36,
                                            spreadRadius: 4,
                                            offset: const Offset(0, 10),
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFFFFD700).withAlpha(60),
                                            blurRadius: 28,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(36),
                                        child: Image.asset(
                                          'assets/images/badelha_icon.png',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: AppColors.primary,
                                            child: const Center(
                                              child: Icon(Icons.swap_horiz_rounded, size: 70, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 22),

                                // Arabic Name with Precise Tashkeel on Dal
                                SlideTransition(
                                  position: _slideAnimation,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Column(
                                      children: [
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: const TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'بَدِّلْ',
                                                style: TextStyle(
                                                  fontSize: 44,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0,
                                                  color: Colors.white,
                                                  shadows: [
                                                    Shadow(
                                                      color: Color(0xFF00D084),
                                                      blurRadius: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'هَا',
                                                style: TextStyle(
                                                  fontSize: 44,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0,
                                                  color: Color(0xFF00D084),
                                                  shadows: [
                                                    Shadow(
                                                      color: Color(0xFF00D084),
                                                      blurRadius: 24,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'B A D E L H A',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 6.0,
                                            color: Color(0xFFFFD700),
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        // Exact Tagline Badge requested by User
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withAlpha(16),
                                            borderRadius: BorderRadius.circular(30),
                                            border: Border.all(
                                              color: const Color(0xFF00D084).withAlpha(140),
                                              width: 1.2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF00D084).withAlpha(35),
                                                blurRadius: 18,
                                              ),
                                            ],
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 16),
                                              SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  'شيء ما تحتاجه ؟ بدله بشيء تحتاجه !',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 16),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Value Pillars Badges (3 Interactive Highlights)
                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(10),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.white.withAlpha(20)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildPillarItem(
                                        icon: Icons.sync_alt_rounded,
                                        title: 'مقايضة ذكية',
                                        subtitle: 'بدون عمولات',
                                        color: const Color(0xFF00D084),
                                      ),
                                      Container(width: 1, height: 36, color: Colors.white12),
                                      _buildPillarItem(
                                        icon: Icons.flash_on_rounded,
                                        title: 'مطابقة فورية',
                                        subtitle: 'توافق قيمي وجغرافي',
                                        color: const Color(0xFFFFD700),
                                      ),
                                      Container(width: 1, height: 36, color: Colors.white12),
                                      _buildPillarItem(
                                        icon: Icons.all_inclusive_rounded,
                                        title: 'تبادل ثلاثي',
                                        subtitle: 'A ➔ B ➔ C ➔ A',
                                        color: const Color(0xFF38BDF8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Action Buttons: Login / Register & Guest Explore
                            // Bottom Loading & Session Verification Indicator
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(14),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: Colors.white.withAlpha(24)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00D084).withAlpha(30),
                                          blurRadius: 16,
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D084)),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'جاري الدخول وتهيئة سوق المقايضة...',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    '✦ الإصدار التجاري المعتمد • مدعوم بمحرك المطابقة الذكي SQLite ✦',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white38,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withAlpha(160),
          ),
        ),
      ],
    );
  }
}
