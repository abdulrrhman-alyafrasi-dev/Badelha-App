import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BadelhaLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showTagline;
  final Color? textColor;
  final bool useAsset;

  const BadelhaLogo({
    super.key,
    this.size = 72,
    this.showText = true,
    this.showTagline = false,
    this.textColor,
    this.useAsset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Giant Expressive Swap Icon Badge (with 3D Luxury Asset support)
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.26),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(80),
                blurRadius: size * 0.28,
                offset: Offset(0, size * 0.1),
              ),
              BoxShadow(
                color: Colors.amber.withAlpha(40),
                blurRadius: size * 0.35,
                offset: Offset(0, size * 0.05),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.26),
            child: useAsset
                ? Image.asset(
                    'assets/images/badelha_icon.png',
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildVectorFallback(),
                  )
                : _buildVectorFallback(),
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'بَدِّلْ',
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: textColor ?? AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: 'هَا',
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'BADELHA',
            style: TextStyle(
              fontSize: size * 0.14,
              fontWeight: FontWeight.w800,
              letterSpacing: 4.0,
              color: textColor?.withAlpha(180) ?? AppColors.textSecondary,
            ),
          ),
        ],
        if (showTagline) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withAlpha(90)),
            ),
            child: const Text(
              'شيء ما تحتاجه ؟ بدله بشيء تحتاجه !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVectorFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandHeroGradient,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.62, size * 0.62),
          painter: _SwapIconPainter(),
        ),
      ),
    );
  }
}

/// Custom painter rendering modern dual-exchange circular swap arrows
class _SwapIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Top Curve (Right arrow pointing right)
    final topRect = Rect.fromCircle(
      center: Offset(size.width * 0.5, size.height * 0.5),
      radius: size.width * 0.38,
    );
    canvas.drawArc(topRect, -2.8, 2.5, false, paint);

    // Arrowhead for top arc (Pointing right/down)
    final topPath = Path();
    topPath.moveTo(size.width * 0.88, size.height * 0.45);
    topPath.lineTo(size.width * 0.88, size.height * 0.22);
    topPath.lineTo(size.width * 0.68, size.height * 0.35);
    topPath.close();
    canvas.drawPath(topPath, fillPaint);

    // Bottom Curve (Left arrow pointing left)
    canvas.drawArc(topRect, 0.35, 2.5, false, paint);

    // Arrowhead for bottom arc (Pointing left/up)
    final bottomPath = Path();
    bottomPath.moveTo(size.width * 0.12, size.height * 0.55);
    bottomPath.lineTo(size.width * 0.12, size.height * 0.78);
    bottomPath.lineTo(size.width * 0.32, size.height * 0.65);
    bottomPath.close();
    canvas.drawPath(bottomPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
