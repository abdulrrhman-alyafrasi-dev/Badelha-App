import 'package:flutter/material.dart';

/// 📐 Badelha Design System - Unified Dimensions & Spacing
class AppDimensions {
  // Border Radii
  static const double radiusXS = 4.0;
  static const double radiusSM = 6.0;
  static const double radiusMD = 10.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radius2XL = 20.0;

  static final BorderRadius borderRadiusSM = BorderRadius.circular(radiusSM);
  static final BorderRadius borderRadiusMD = BorderRadius.circular(radiusMD);
  static final BorderRadius borderRadiusLG = BorderRadius.circular(radiusLG);
  static final BorderRadius borderRadiusXL = BorderRadius.circular(radiusXL);
  static final BorderRadius borderRadius2XL = BorderRadius.circular(radius2XL);

  // Paddings & Margins
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  static const EdgeInsets paddingXS = EdgeInsets.all(space4);
  static const EdgeInsets paddingSM = EdgeInsets.all(space8);
  static const EdgeInsets paddingMD = EdgeInsets.all(space12);
  static const EdgeInsets paddingLG = EdgeInsets.all(space16);
  static const EdgeInsets paddingXL = EdgeInsets.all(space24);

  // Button Heights
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightMD = 48.0;
  static const double buttonHeightLG = 52.0;
}
