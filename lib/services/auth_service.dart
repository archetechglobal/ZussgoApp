import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AuthService {

  // ─── SIGNUP ───
  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.signup),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": fullName,
          "email": email,
          "password": password,
        }),
      );

      print("SIGNUP RESPONSE: ${response.body}");
      return _parseResponse(response);
    } catch (e) {
      return _connectionError();
    }
  }

  // ─── LOGIN ───
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      return _parseResponse(response);
    } catch (e) {
      return _connectionError();
    }
  }

  // ─── VERIFY OTP ───
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
    required String type,
    String? fullName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyOtp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "type": type,
          if (fullName != null) "fullName": fullName,
        }),
      );

      return _parseResponse(response);
    } catch (e) {
      return _connectionError();
    }
  }

  // ─── FORGOT PASSWORD (send OTP) ───
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.forgotPassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      return _parseResponse(response);
    } catch (e) {
      return _connectionError();
    }
  }

  // ─── RESET PASSWORD (verify OTP + new password) ───
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.resetPassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "newPassword": newPassword,
        }),
      );

      return _parseResponse(response);
    } catch (e) {
      return _connectionError();
    }
  }

  // ─── RESEND OTP ───
  static Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.resendOtp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      return _parseResponse(response);
    } catch (e) {
      return _connectionError();
    }
  }

  // ─── PROFILE SETUP ───
  static Future<Map<String, dynamic>> profileSetup({
    required String userId,
    required String gender,
    required int age,
    String? city,
    String? travelStyle,
    String? bio,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.profileSetup),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "gender": gender,
          "age": age,
          if (city != null) "city": city,
          if (travelStyle != null) "travelStyle": travelStyle,
          if (bio != null) "bio": bio,
        }),
      );

      return _parseResponse(response);
    } catch (e) {
      return _connectionError();
    }
  }

  // Update saved session (for when profile gets completed)
  static Future<void> updateSavedUser(Map<String, dynamic> updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(updatedUser));
  }

  // ─── GET OTHER USERS (for home feed) ───
  static Future<Map<String, dynamic>> getUsers({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.users}?userId=$userId"),
        headers: {"Content-Type": "application/json"},
      );

      return _parseResponse(response);
    } catch (e) {
      return _connectionError();
    }
  }

  // ─── TOKEN STORAGE (for remember me + auto-login) ───

  // Save tokens + user data after successful login/verify
  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('user_data', jsonEncode(user));
    await prefs.setBool('is_logged_in', true);
  }

  // Check if user has a saved session (for auto-login)
  static Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Get saved user data
  static Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Get saved access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Clear session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    await prefs.clear();
    if (hasSeenOnboarding) {
      await prefs.setBool('has_seen_onboarding', true);
    }
  }

  // Mark that user has seen onboarding
  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  // Check if user has seen onboarding
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  // ─── HELPERS ───

  static Map<String, dynamic> _parseResponse(http.Response response) {
    final data = jsonDecode(response.body);
    return {
      "success": data["success"] ?? false,
      "message": data["message"] ?? "Something went wrong",
      "data": data["data"],
      "code": data["code"],
      "statusCode": response.statusCode,
    };
  }

  static Map<String, dynamic> _connectionError() {
    return {
      "success": false,
      "message": "Could not connect to server. Make sure backend is running.",
      "data": null,
      "statusCode": 0,
    };
  }
}