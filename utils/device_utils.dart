import 'package:flutter/material.dart';
import 'dart:io';

class DeviceUtils {
  // Check if device is iOS
  static bool get isIOS => Platform.isIOS;
  
  // Check if device is Android
  static bool get isAndroid => Platform.isAndroid;
  
  // Check if device is Web
  static bool get isWeb => Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  
  // Get device type
  static String get deviceType {
    if (isIOS) return 'iOS';
    if (isAndroid) return 'Android';
    if (isWeb) return 'Web';
    return 'Unknown';
  }
  
  // Get screen size
  static Size screenSize(BuildContext context) => MediaQuery.of(context).size;
  
  // Get screen width
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  
  // Get screen height
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  // Check if keyboard is open
  static bool isKeyboardOpen(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
  
  // Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
  
  // Get status bar height
  static double get statusBarHeight {
    return Platform.isIOS ? 44 : 24;
  }
  
  // Get bottom navigation bar height
  static double get bottomNavBarHeight {
    return Platform.isIOS ? 83 : 56;
  }
  
  // Check if device has notch
  static bool get hasNotch {
    if (Platform.isIOS) {
      return true; // All modern iPhones have notch/dynamic island
    }
    return false;
  }
}