import 'dart:io';
import 'dart:typed_data' show Uint8List;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:hyper_local/models/auth/signup_response_model.dart';
import 'package:hyper_local/models/auth/profile_response_model.dart';
import '../models/auth/signup_request_model.dart';
import '../services/auth_service.dart';
import '../utils/session_manager.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String errorMessage = '';

  // ==========================================
  // SIGNUP - SEND OTP
  // ==========================================

  Future<bool> sendOtp({
    required String name,
    required String email,
    required String mobileNo,
    required String dob,
    required String gender,
    required String industry,
    required String currentRole,
  }) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final request = SignupRequestModel(
        name: name,
        email: email,
        mobileNo: mobileNo,
        dob: dob,
        gender: gender,
        industry: industry,
        currentRole: currentRole,
      );

      final response = await _authService.sendSignupOtp(request);

      if (!response.success) {
        errorMessage = response.message;
      }
      return response.success;
    } catch (e) {
      errorMessage = 'Something went wrong: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // SIGNUP - VERIFY OTP
  // ==========================================

  Future<bool> verifyOtp({
    required String name,
    required String email,
    required String mobileNo,
    required String dob,
    required String gender,
    required String industry,
    required String currentRole,
    required String otp,
  }) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final request = SignupVerifyOtpRequestModel(
        name: name,
        email: email,
        mobileNo: mobileNo,
        dob: dob,
        gender: gender,
        industry: industry,
        currentRole: currentRole,
        otp: otp,
      );

      final response = await _authService.verifySignupOtp(request);

      if (!response.success) {
        errorMessage = response.message;
      } else {
        if (response.token != null && response.token!.isNotEmpty) {
          await SessionManager.saveSession(
            token: response.token!,
            user: response.user,
          );
        }
      }

      return response.success;
    } catch (e) {
      errorMessage = 'Something went wrong: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //login-function
  LoginResponseModel? loggedInUser;

  // ==========================================
  // LOGIN - SEND OTP
  // ==========================================
  Future<bool> loginSendOtp({required String mobileNo}) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final request = LoginRequestModel(mobileNo: mobileNo);
      final response = await _authService.loginSendOtp(request);

      if (!response.success) {
        errorMessage = response.message;
      }
      return response.success;
    } catch (e) {
      errorMessage = 'Something went wrong: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // LOGIN - VERIFY OTP
  // ==========================================
  Future<bool> loginVerifyOtp({
    required String mobileNo,
    required String otp,
  }) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final request = VerifyOtpRequestModel(mobileNo: mobileNo, otp: otp);
      final response = await _authService.loginVerifyOtp(request);

      if (!response.success) {
        errorMessage = response.message;
      } else {
        loggedInUser = response;
        final token = (response.token != null && response.token!.isNotEmpty)
            ? response.token!
            : "";
        if (token.isNotEmpty) {
          await SessionManager.saveSession(
            token: token,
            user: response.user,
          );
        }
      }
      return response.success;
    } catch (e) {
      errorMessage = 'Something went wrong: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // LOGOUT USER
  // ==========================================
  Future<void> logout() async {
    await SessionManager.clearSession();
    loggedInUser = null;
    profileData = null;
    notifyListeners();
  }

  // ==========================================
  // CLEAR ERROR
  // ==========================================
  void clearError() {
    errorMessage = '';
    notifyListeners();
  }

  // ==========================================
  // PROFILE
  // ==========================================
  ProfileData? profileData;

  // ------------------------------------------
  // GET PROFILE
  // ------------------------------------------
  Future<bool> getProfile() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await _authService.getProfile();

      if (response.success && response.data != null) {
        // Preserve local photo if server doesn't return one:
        String? finalPhoto = response.data!.profilePhoto;
        if (finalPhoto == null || finalPhoto.trim().isEmpty) {
          final existingPhoto = profileData?.profilePhoto;
          if (existingPhoto != null && existingPhoto.trim().isNotEmpty) {
            finalPhoto = existingPhoto.trim();
          } else {
            final sessionPhoto = await SessionManager.getProfilePhoto();
            if (sessionPhoto != null && sessionPhoto.trim().isNotEmpty) {
              finalPhoto = sessionPhoto.trim();
            }
          }
        } else {
          await SessionManager.saveProfilePhoto(finalPhoto);
        }

        profileData = ProfileData(
          id: response.data!.id,
          name: response.data!.name.isNotEmpty
              ? response.data!.name
              : (profileData?.name ?? ''),
          email: response.data!.email.isNotEmpty
              ? response.data!.email
              : (profileData?.email ?? ''),
          mobileNo: response.data!.mobileNo.isNotEmpty
              ? response.data!.mobileNo
              : (profileData?.mobileNo ?? ''),
          dob: response.data!.dob ?? profileData?.dob,
          gender: response.data!.gender ?? profileData?.gender,
          address: response.data!.address ?? profileData?.address,
          profilePhoto: finalPhoto,
        );

        if (response.data!.name.isNotEmpty) {
          final currentToken = await SessionManager.getToken();
          if (currentToken != null && currentToken.isNotEmpty) {
            await SessionManager.saveSession(
              token: currentToken,
              user: LoginUserModel(
                id: response.data!.id,
                name: response.data!.name,
                email: response.data!.email,
                mobileNo: response.data!.mobileNo,
              ),
            );
          }
        }
      } else {
        errorMessage = response.message;
      }

      return response.success;
    } catch (e) {
      errorMessage = 'Something went wrong: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------------------------
  // UPDATE PROFILE
  // ------------------------------------------
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String mobileNo,
    required String address,
  }) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await _authService.updateProfile(
        name: name,
        email: email,
        mobileNo: mobileNo,
        address: address,
      );

      final currentPhoto =
          profileData?.profilePhoto ?? await SessionManager.getProfilePhoto();

      profileData = ProfileData(
        id: profileData?.id ?? 0,
        name: name,
        email: email,
        mobileNo: mobileNo,
        dob: profileData?.dob,
        gender: profileData?.gender,
        address: address,
        profilePhoto: currentPhoto,
      );

      final currentToken = await SessionManager.getToken();
      if (currentToken != null && currentToken.isNotEmpty) {
        await SessionManager.saveSession(
          token: currentToken,
          user: LoginUserModel(
            id: profileData?.id ?? 0,
            name: name,
            email: email,
            mobileNo: mobileNo,
          ),
        );
      }

      if (!response.success) {
        errorMessage = response.message;
      } else {
        await getProfile();
      }

      return response.success;
    } catch (e) {
      errorMessage = 'Something went wrong: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // UPDATE LOCAL PROFILE PHOTO & SESSION
  // ==========================================
  void updateLocalProfilePhoto(String photo) {
    if (profileData != null) {
      profileData = ProfileData(
        id: profileData!.id,
        name: profileData!.name,
        email: profileData!.email,
        mobileNo: profileData!.mobileNo,
        dob: profileData!.dob,
        gender: profileData!.gender,
        address: profileData!.address,
        profilePhoto: photo,
      );
    } else {
      profileData = ProfileData(
        id: 0,
        name: '',
        email: '',
        mobileNo: '',
        profilePhoto: photo,
      );
    }
    SessionManager.saveProfilePhoto(photo);
    notifyListeners();
  }

  // ==========================================
  // UPLOAD PROFILE PHOTO
  // ==========================================
  Future<bool> uploadProfilePhoto({
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    if (imageFile != null && !kIsWeb) {
      updateLocalProfilePhoto(imageFile.path);
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await _authService.uploadProfilePhoto(
        imageFile: imageFile,
        imageBytes: imageBytes,
        fileName: fileName,
      );

      if (response.success) {
        final serverPhoto = response.data?.profilePhoto;
        if (serverPhoto != null && serverPhoto.isNotEmpty) {
          await SessionManager.saveProfilePhoto(serverPhoto);
          updateLocalProfilePhoto(serverPhoto);
        } else {
          await getProfile();
        }
      } else {
        errorMessage = response.message;
      }

      return response.success;
    } catch (e) {
      errorMessage = 'Something went wrong: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // FETCH INDUSTRIES FROM BACKEND
  // ==========================================
  Future<List<String>> fetchIndustries() async {
    return await _authService.getIndustries();
  }
}