import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:hyper_local/models/auth/profile_response_model.dart';

import '../models/auth/signup_request_model.dart';
import '../models/auth/signup_response_model.dart';

import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // ==========================================
  // SIGNUP - SEND OTP
  // POST /api/user/sign-up-send-otp
  // ==========================================

  Future<SignupResponseModel> sendSignupOtp(
    SignupRequestModel data,
  ) async {
    final response = await _apiService.postRequest(
      '/user/sign-up-send-otp',
      data.toJson(),
    );

    return SignupResponseModel.fromJson(response);
  }

  // ==========================================
  // SIGNUP - VERIFY OTP
  // POST /api/user/sign-up-verify-otp
  // ==========================================

  Future<SignupResponseModel> verifySignupOtp(
    SignupVerifyOtpRequestModel data,
  ) async {
    final response = await _apiService.postRequest(
      // '/user/sign-up-verify-otp',
      '/user/signup-verify-otp', // 👈 backend route confirm झाल्यावर इथेच बदल करा
      data.toJson(),
    );

    return SignupResponseModel.fromJson(response);
  }
//login-api
   Future<LoginResponseModel> loginSendOtp(LoginRequestModel data) async {
    final response = await _apiService.postRequest(
      '/user/login-send-otp',
      data.toJson(),
    );
    return LoginResponseModel.fromJson(response);
  }

  // ==========================================
  // LOGIN - VERIFY OTP
  // POST /api/user/login-verify-otp
  // ==========================================
  Future<LoginResponseModel> loginVerifyOtp(VerifyOtpRequestModel data) async {
    final response = await _apiService.postRequest(
      '/user/login-verify-otp',
      data.toJson(),
    );
    return LoginResponseModel.fromJson(response);
  }

    // ==========================================
  // GET PROFILE
  // GET /api/user/profile
  // ==========================================
  Future<ProfileResponseModel> getProfile() async {
    final response = await _apiService.getRequest('/user/profile');
    return ProfileResponseModel.fromJson(response);
  }
    // ==========================================
  // UPLOAD PROFILE PHOTO
  // POST /api/user/upload-profile-photo
  // ==========================================
  Future<ProfileResponseModel> uploadProfilePhoto({
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    final response = await _apiService.postMultipart(
      '/user/upload-profile-photo',
      fields: {},
      fileField: 'photo',
      file: imageFile,
      fileBytes: imageBytes,
      fileName: fileName,
    );
    return ProfileResponseModel.fromJson(response);
  }

  // ==========================================
  // UPDATE PROFILE
  // PUT /api/user/update-profile
  // ==========================================
  Future<ProfileResponseModel> updateProfile({
    required String name,
    required String email,
    required String mobileNo,
    required String address,
  }) async {
    final response = await _apiService.putRequest(
      '/user/update-profile',
      {
        "name": name,
        "email": email,
        "mobile_no": mobileNo,
        "address": address,
      },
    );
    return ProfileResponseModel.fromJson(response);
  }

  // ==========================================
  // GET INDUSTRIES
  // GET /api/industries
  // ==========================================
  Future<List<String>> getIndustries() async {
    try {
      final response = await _apiService.getRequest('/industries');
      if (response['success'] == true && response['industries'] != null) {
        final list = response['industries'] as List;
        return list.map((e) => e['name'].toString()).toList();
      }
    } catch (e) {
      print('Error fetching industries: $e');
    }
    return [];
  }
}