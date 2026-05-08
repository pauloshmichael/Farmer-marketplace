import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${AuthEndpoints.login}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'token': data['token'],
          'user': UserModel.fromJson(data['user']),
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${AuthEndpoints.register}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'token': data['token'],
          'user': UserModel.fromJson(data['user']),
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${AuthEndpoints.forgotPassword}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset link sent to your email',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Failed to send reset link',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${AuthEndpoints.resetPassword}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'token': token,
          'password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset successfully',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${AuthEndpoints.verifyEmail}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({'token': token}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Email verified successfully',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Failed to verify email',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${AuthEndpoints.logout}'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Logged out successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to logout',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> changePassword(String token, String oldPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${AuthEndpoints.changePassword}'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password changed successfully',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
}