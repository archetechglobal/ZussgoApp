import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AuthService {
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userKey = 'user';
  static const String _onboardingKey = 'hasSeenOnboarding';

  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.signup),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fullName': fullName, 'email': email, 'password': password}),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
    required String type,
    String? fullName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, 'otp': otp, 'type': type,
          if (fullName != null) 'fullName': fullName,
        }),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.resendOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.forgotPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.resetPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'newPassword': newPassword}),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> profileSetup({
    required String userId,
    String? fullName,
    String? gender, int? age, String? city, String? bio,
    String? travelStyle, String? schedule, String? socialEnergy, String? planningStyle,
    List<String>? interests, List<String>? values, String? energyLevel, String? travelPriority,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.profileSetup),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          if (fullName != null) 'fullName': fullName,
          if (gender != null) 'gender': gender,
          if (age != null) 'age': age,
          if (city != null) 'city': city,
          if (bio != null) 'bio': bio,
          if (travelStyle != null) 'travelStyle': travelStyle,
          if (schedule != null) 'schedule': schedule,
          if (socialEnergy != null) 'socialEnergy': socialEnergy,
          if (planningStyle != null) 'planningStyle': planningStyle,
          if (interests != null) 'interests': interests,
          if (values != null) 'values': values,
          if (energyLevel != null) 'energyLevel': energyLevel,
          if (travelPriority != null) 'travelPriority': travelPriority,
        }),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> getUsers({String? userId}) async {
    try {
      final url = userId != null ? '${ApiConfig.users}?userId=$userId' : ApiConfig.users;
      final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json'});
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    try { return jsonDecode(userStr) as Map<String, dynamic>; } catch (e) { return null; }
  }

  static Future<void> updateSavedUser(Map<String, dynamic> updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(updatedUser));
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  static Map<String, dynamic> _parse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Something went wrong',
        'data': data['data'],
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {'success': false, 'message': 'Invalid response', 'data': null, 'statusCode': response.statusCode};
    }
  }

  static Map<String, dynamic> _error() {
    return {'success': false, 'message': 'Could not connect to server', 'data': null, 'statusCode': 0};
  }
}