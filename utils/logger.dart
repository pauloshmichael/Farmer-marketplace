import 'package:flutter/foundation.dart';

class AppLogger {
  static const bool isDebugMode = kDebugMode;
  
  static void logInfo(String message) {
    if (isDebugMode) {
      debugPrint('📘 INFO: $message');
    }
  }
  
  static void logSuccess(String message) {
    if (isDebugMode) {
      debugPrint('✅ SUCCESS: $message');
    }
  }
  
  static void logWarning(String message) {
    if (isDebugMode) {
      debugPrint('⚠️ WARNING: $message');
    }
  }
  
  static void logError(String message, {dynamic error, StackTrace? stackTrace}) {
    if (isDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) {
        debugPrint('   Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('   Stack trace: $stackTrace');
      }
    }
  }
  
  static void logNetwork(String message) {
    if (isDebugMode) {
      debugPrint('🌐 NETWORK: $message');
    }
  }
  
  static void logAuth(String message) {
    if (isDebugMode) {
      debugPrint('🔐 AUTH: $message');
    }
  }
  
  static void logDatabase(String message) {
    if (isDebugMode) {
      debugPrint('🗄️ DATABASE: $message');
    }
  }
  
  static void logApi(String endpoint, {Map<String, dynamic>? request, Map<String, dynamic>? response}) {
    if (isDebugMode) {
      debugPrint('📡 API: $endpoint');
      if (request != null) {
        debugPrint('   Request: $request');
      }
      if (response != null) {
        debugPrint('   Response: $response');
      }
    }
  }
  
  static void logPerformance(String action, Duration duration) {
    if (isDebugMode) {
      debugPrint('⚡ PERFORMANCE: $action took ${duration.inMilliseconds}ms');
    }
  }
}