import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ItemImageWidget extends StatelessWidget {
  final List<String> images;
  final String categoryId;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const ItemImageWidget({
    super.key,
    required this.images,
    this.categoryId = '',
    this.width = 100,
    this.height = 100,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = images.isNotEmpty ? images.first.trim() : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: _buildContent(imagePath),
      ),
    );
  }

  Widget _buildContent(String rawPath) {
    if (rawPath.isEmpty) {
      return _buildPresetIcon('');
    }

    // 1. رابط إنترنت شبكي (HTTP / HTTPS)
    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      return Image.network(
        rawPath,
        width: width.isFinite ? width : null,
        height: height.isFinite ? height : null,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPresetIcon(rawPath),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: const Color(0xFFF1F5F9),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
      );
    }

    // 2. صور مدمجة داخل التطبيق (Assets)
    if (rawPath.startsWith('assets/')) {
      return Image.asset(
        rawPath,
        width: width.isFinite ? width : null,
        height: height.isFinite ? height : null,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPresetIcon(rawPath),
      );
    }

    // 3. صور مشفرة بصيغة Base64
    if (rawPath.startsWith('data:image/') ||
        (rawPath.length > 200 && !rawPath.contains('/') && !rawPath.contains('\\'))) {
      try {
        String base64Content = rawPath;
        if (base64Content.contains(',')) {
          base64Content = base64Content.split(',').last;
        }
        final bytes = base64Decode(base64Content.trim());
        return Image.memory(
          bytes,
          width: width.isFinite ? width : null,
          height: height.isFinite ? height : null,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPresetIcon(rawPath),
        );
      } catch (e) {
        debugPrint('Base64 image decode fallback: $e');
      }
    }

    // 4. ملف محلي على القرص (فقط للأجهزة وليس للويب)
    if (!kIsWeb) {
      String cleanPath = rawPath;
      if (cleanPath.startsWith('file://')) {
        cleanPath = cleanPath.replaceFirst('file://', '');
        if (cleanPath.startsWith('/') && cleanPath.length > 2 && cleanPath[2] == ':') {
          cleanPath = cleanPath.substring(1);
        }
      }

      try {
        final file = File(cleanPath);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: width.isFinite ? width : null,
            height: height.isFinite ? height : null,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildPresetIcon(rawPath),
          );
        }
      } catch (_) {
        // تجاهل أخطاء الوصول للقرص
      }
    }

    // 5. الأيقونة الافتراضية المخصصة حسب الصنف
    return _buildPresetIcon(rawPath);
  }

  Widget _buildPresetIcon(String tag) {
    IconData icon = Icons.devices_other;
    Color color = AppColors.primary;
    String label = 'سلعة';

    final lowerTag = tag.toLowerCase();
    if (lowerTag.contains('phone') || categoryId == 'cat_phones') {
      icon = Icons.smartphone;
      color = const Color(0xFF00A86B);
      label = 'هاتف ذكي';
    } else if (lowerTag.contains('laptop') || categoryId == 'cat_laptops') {
      icon = Icons.laptop_mac;
      color = const Color(0xFF4F46E5);
      label = 'حاسوب';
    } else if (lowerTag.contains('gaming') || categoryId == 'cat_gaming') {
      icon = Icons.sports_esports;
      color = const Color(0xFFE11D48);
      label = 'ألعاب';
    } else if (lowerTag.contains('watch') || categoryId == 'cat_watches') {
      icon = Icons.watch;
      color = const Color(0xFFD97706);
      label = 'ساعة';
    } else if (lowerTag.contains('car') || categoryId == 'cat_vehicles') {
      icon = Icons.directions_bike;
      color = const Color(0xFF0891B2);
      label = 'مركبة';
    } else if (lowerTag.contains('home') || categoryId == 'cat_home') {
      icon = Icons.home;
      color = const Color(0xFF7C3AED);
      label = 'منزل';
    }

    final double? effectiveWidth = width.isFinite ? width : null;
    final double? effectiveHeight = height.isFinite ? height : null;
    final double iconSize = (width.isFinite ? width * 0.38 : 56.0).clamp(24.0, 64.0);

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        border: Border.all(color: color.withAlpha(70), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: color),
          if (effectiveHeight == null || effectiveHeight >= 65) ...[
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}