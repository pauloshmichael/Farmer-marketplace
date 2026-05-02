import 'package:flutter/material.dart';

class AppDimensions {
  // Padding and Margin
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;
  
  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusCircular = 50.0;
  
  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeXXXL = 24.0;
  static const double fontSizeDisplay = 32.0;
  
  // Icon Sizes
  static const double iconXS = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 48.0;
  
  // Button Sizes
  static const double buttonHeight = 50.0;
  static const double buttonWidth = double.infinity;
  static const double buttonSmallHeight = 40.0;
  static const double buttonLargeHeight = 56.0;
  
  // Card Sizes
  static const double cardElevation = 2.0;
  static const double cardElevationHigh = 8.0;
  
  // Image Sizes
  static const double avatarSizeS = 32.0;
  static const double avatarSizeM = 48.0;
  static const double avatarSizeL = 64.0;
  static const double avatarSizeXL = 96.0;
  
  // Product Card
  static const double productCardHeight = 280.0;
  static const double productCardWidth = 200.0;
  static const double productImageHeight = 140.0;
  
  // Screen Margins
  static const EdgeInsets screenPaddingH = EdgeInsets.symmetric(horizontal: paddingM);
  static const EdgeInsets screenPaddingHV = EdgeInsets.symmetric(horizontal: paddingM, vertical: paddingM);
  
  // Get screen width and height
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  // Responsive font size
  static double responsiveFontSize(BuildContext context, double size) {
    double scaleFactor = screenWidth(context) / 375; // 375 is base width (iPhone SE)
    return size * scaleFactor.clamp(0.8, 1.2);
  }
}