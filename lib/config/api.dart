class ApiConfig {
  static const String baseUrl = "http://10.0.2.2:8000";

  static const String signup = "$baseUrl/auth/signup";
  static const String login = "$baseUrl/auth/login";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";
  static const String resendOtp = "$baseUrl/auth/resend-otp";
  static const String profileSetup = "$baseUrl/auth/profile-setup";
  static const String users = "$baseUrl/auth/users";

  static const String profile = "$baseUrl/profile";
}