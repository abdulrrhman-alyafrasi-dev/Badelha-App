import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/intents_helper.dart';
import '../../data/models/admin_banner_model.dart';
import '../providers/banner_provider.dart';

class AdminBannerCarousel extends StatefulWidget {
  const AdminBannerCarousel({super.key});

  @override
  State<AdminBannerCarousel> createState() => _AdminBannerCarouselState();
}

class _AdminBannerCarouselState extends State<AdminBannerCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final banners = Provider.of<BannerProvider>(context, listen: false).banners;
      if (banners.isNotEmpty && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerProv = Provider.of<BannerProvider>(context);
    final banners = bannerProv.banners;

    if (bannerProv.isLoading || banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 125,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return _buildBannerCard(context, banner);
            },
          ),
        ),
        const SizedBox(height: 6),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 18 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFFFFCC00)
                    : Colors.grey.shade400.withAlpha(120),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCard(BuildContext context, AdminBannerModel banner) {
    Color badgeColor = const Color(0xFFFFCC00);
    try {
      badgeColor = Color(int.parse(banner.badgeColor));
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F4845),
            Color(0xFF09312E),
            Color(0xFF082725),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3835).withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final targetUrl = banner.actionUrl.isNotEmpty ? banner.actionUrl : (banner.id == 'banner_dev_channel' ? 'https://t.me/Al_YafarsiDev77' : '');
            if (targetUrl.isNotEmpty) {
              IntentsHelper.openUrl(targetUrl, context);
            } else {
              _showBannerDetails(context, banner);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Tag Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    banner.tag,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Main Info Row: Icon + Title/Subtitle + Arrow
                Row(
                  children: [
                    // Leading Icon Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF19615B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Center(
                        child: _getBannerIcon(banner.iconType),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Title & Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            banner.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withAlpha(200),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Trailing Action Arrow
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Color(0xFF5EEAD4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getBannerIcon(String type) {
    switch (type) {
      case 'shield':
        return const Icon(Icons.shield_rounded, color: Color(0xFF00D084), size: 22);
      case 'swap':
        return const Icon(Icons.swap_horiz_rounded, color: Color(0xFFFF8A00), size: 24);
      case 'campaign':
        return const Icon(Icons.campaign_rounded, color: Color(0xFF38BDF8), size: 22);
      default:
        return const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 24);
    }
  }

  void _showBannerDetails(BuildContext context, AdminBannerModel banner) {
    final targetUrl = banner.actionUrl.isNotEmpty ? banner.actionUrl : (banner.id == 'banner_dev_channel' ? 'https://t.me/Al_YafarsiDev77' : '');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getBannerIcon(banner.iconType),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    banner.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                banner.tag,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              banner.description,
              style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            if (targetUrl != null && targetUrl.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    IntentsHelper.openUrl(targetUrl, context);
                  },
                  icon: const Icon(Icons.telegram, color: Colors.white, size: 22),
                  label: const Text('الانتقال إلى القناة الرسمية بالتليجرام 🚀'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF229ED9),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
