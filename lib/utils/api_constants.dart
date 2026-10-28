class ApiConstants {
  // Emulator sathi 10.0.2.2, real device sathi tumcha PC cha local IP (jasa 192.168.x.x)
  // static const String baseUrl = 'https://api.hihr.app/api';
   static const String baseUrl = 'http://localhost:5000/api';
  static const String signupSendOtp = "$baseUrl/user/sign-up-send-otp";
  static const String signupVerifyOtp = "$baseUrl/user/signup-verify-otp";
  static const String jobs = "$baseUrl/jobs";
  static const String recentJobs = "/jobpost/public";
  static const String recentJobsFallback = "/jobs";
}
