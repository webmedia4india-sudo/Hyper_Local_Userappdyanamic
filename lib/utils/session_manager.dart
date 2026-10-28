import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/signup_response_model.dart';

class SessionManager {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserMobile = 'user_mobile';
  static const String _keyProfilePhoto = 'user_profile_photo';
  static const String _keySelectedCityId = 'selected_city_id';
  static const String _keySelectedCityName = 'selected_city_name';

  /// Save login session data to SharedPreferences
  static Future<void> saveSession({
    required String token,
    LoginUserModel? user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int? existingUserId = prefs.getInt(_keyUserId);
    if (user != null && existingUserId != null && existingUserId != user.id) {
      await prefs.remove('saved_resume_data');
      await prefs.remove('resume_completion_percent');
      await prefs.remove('resume_completed_points');
      await prefs.remove('resume_total_points');
    }
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyAuthToken, token);

    if (user != null) {
      await prefs.setInt(_keyUserId, user.id);
      if (user.name != null) {
        await prefs.setString(_keyUserName, user.name!);
      }
      if (user.email != null) {
        await prefs.setString(_keyUserEmail, user.email!);
      }
      await prefs.setString(_keyUserMobile, user.mobileNo);
    }
  }

  /// Check if user is currently logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    final String? token = prefs.getString(_keyAuthToken);
    if (token == 'signup_user_session' || token == 'active_user_session') {
      return false;
    }
    return isLoggedIn && (token != null && token.isNotEmpty);
  }

  /// Retrieve stored authentication token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(_keyAuthToken);
    if (token == 'signup_user_session' || token == 'active_user_session') {
      return null;
    }
    return token;
  }

  /// Retrieve cached user details
  /// Save user profile photo to SharedPreferences
  static Future<void> saveProfilePhoto(String photoPathOrUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfilePhoto, photoPathOrUrl);
    await prefs.setString('profile_photo', photoPathOrUrl);
    await prefs.setString('profile_image', photoPathOrUrl);
  }

  /// Retrieve stored profile photo directly
  static Future<String?> getProfilePhoto() async {
    final details = await getUserDetails();
    return details['photo'] as String?;
  }

  /// Retrieve cached user details
  static Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString(_keyUserName);
    String? email = prefs.getString(_keyUserEmail);
    String? mobile = prefs.getString(_keyUserMobile);
    String? photo = prefs.getString(_keyProfilePhoto) ??
        prefs.getString('profile_photo') ??
        prefs.getString('profile_image');
    int? id = prefs.getInt(_keyUserId);

    // Fallback: Check if user data is stored as a JSON object in localStorage / SharedPreferences
    if (name == null || name.trim().isEmpty || photo == null || photo.trim().isEmpty) {
      const jsonKeys = [
        'user',
        'user_data',
        'userData',
        'loggedInUser',
        'userInfo',
        'user_profile',
      ];
      for (final key in jsonKeys) {
        final rawJson = prefs.getString(key);
        if (rawJson != null && rawJson.trim().isNotEmpty) {
          try {
            final decoded = jsonDecode(rawJson);
            if (decoded is Map<String, dynamic>) {
              name ??= decoded['name']?.toString() ??
                  decoded['userName']?.toString() ??
                  decoded['user_name']?.toString();
              email ??= decoded['email']?.toString() ??
                  decoded['user_email']?.toString() ??
                  decoded['userEmail']?.toString();
              mobile ??= decoded['mobile_no']?.toString() ??
                  decoded['mobile']?.toString() ??
                  decoded['user_mobile']?.toString();
              photo ??= decoded['profile_photo']?.toString() ??
                  decoded['profilePhoto']?.toString() ??
                  decoded['photo']?.toString() ??
                  decoded['image']?.toString() ??
                  decoded['avatar']?.toString();
              if (id == null && decoded['id'] != null) {
                id = int.tryParse(decoded['id'].toString());
              }
              if (name != null && name.trim().isNotEmpty && photo != null && photo.trim().isNotEmpty) {
                break;
              }
            }
          } catch (_) {}
        }
      }
    }

    if (name == null || name.trim().isEmpty) {
      name = prefs.getString('name') ?? prefs.getString('userName');
    }
    if (photo == null || photo.trim().isEmpty) {
      photo = prefs.getString('photo') ?? prefs.getString('image') ?? prefs.getString('avatar');
    }

    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'photo': photo,
    };
  }

  /// Retrieve stored user name directly
  static Future<String?> getUserName() async {
    final details = await getUserDetails();
    return details['name'] as String?;
  }

  /// Save user's selected city
  static Future<void> saveSelectedCity({
    required int cityId,
    required String cityName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySelectedCityId, cityId);
    await prefs.setString(_keySelectedCityName, cityName);
  }

  /// Retrieve stored selected city ID
  static Future<int?> getSelectedCityId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySelectedCityId);
  }

  /// Retrieve stored selected city name
  static Future<String?> getSelectedCityName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedCityName);
  }

  /// Clear all saved session data upon Logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserMobile);
    await prefs.remove(_keyProfilePhoto);
    await prefs.remove('profile_photo');
    await prefs.remove('profile_image');
    await prefs.remove('user');
    await prefs.remove('user_data');
    await prefs.remove('userData');
    await prefs.remove('name');
    await prefs.remove('userName');
    await prefs.remove('saved_resume_data');
    await prefs.remove('resume_completion_percent');
    await prefs.remove('resume_completed_points');
    await prefs.remove('resume_total_points');
  }
}
