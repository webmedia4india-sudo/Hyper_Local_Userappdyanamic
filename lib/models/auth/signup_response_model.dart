class SignupResponseModel {
  final bool success;
  final String message;
  final String? token;
  final LoginUserModel? user;

  SignupResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] ?? json['success'];
    bool isSuccess = false;
    if (rawStatus == true ||
        rawStatus == 'true' ||
        rawStatus == 1 ||
        rawStatus == '1' ||
        rawStatus == 'success' ||
        rawStatus == 200 ||
        rawStatus == '200') {
      isSuccess = true;
    }

    final token = json['token']?.toString() ??
        (json['data'] is Map ? json['data']['token']?.toString() : null) ??
        json['accessToken']?.toString() ??
        json['access_token']?.toString() ??
        (json['data'] is Map ? json['data']['accessToken']?.toString() : null);

    final rawUser = json['user'] ??
        (json['data'] is Map && json['data']['user'] != null
            ? json['data']['user']
            : null) ??
        (json['data'] is Map && json['data'].containsKey('mobile_no')
            ? json['data']
            : null);

    return SignupResponseModel(
      success: isSuccess,
      message: json['message']?.toString() ?? '',
      token: token,
      user: rawUser is Map<String, dynamic>
          ? LoginUserModel.fromJson(rawUser)
          : null,
    );
  }
}

//login-api
// models/auth/login_response_model.dart
class LoginUserModel {
  final int id;
  final String? name;
  final String? email;
  final String mobileNo;

  LoginUserModel({
    required this.id,
    this.name,
    this.email,
    required this.mobileNo,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? json['userName']?.toString(),
      email: json['email']?.toString(),
      mobileNo: json['mobile_no']?.toString() ??
          json['mobile']?.toString() ??
          json['phone']?.toString() ??
          '',
    );
  }
}

class LoginResponseModel {
  final bool success;
  final String message;
  final String? token;
  final LoginUserModel? user;

  LoginResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] ?? json['success'];
    bool isSuccess = false;
    if (rawStatus == true ||
        rawStatus == 'true' ||
        rawStatus == 1 ||
        rawStatus == '1' ||
        rawStatus == 'success' ||
        rawStatus == 200 ||
        rawStatus == '200') {
      isSuccess = true;
    }

    final token = json['token']?.toString() ??
        (json['data'] is Map ? json['data']['token']?.toString() : null) ??
        json['accessToken']?.toString() ??
        json['access_token']?.toString() ??
        (json['data'] is Map ? json['data']['accessToken']?.toString() : null);

    final rawUser = json['user'] ??
        (json['data'] is Map && json['data']['user'] != null
            ? json['data']['user']
            : null) ??
        (json['data'] is Map && json['data'].containsKey('mobile_no')
            ? json['data']
            : null);

    return LoginResponseModel(
      success: isSuccess,
      message: json['message']?.toString() ?? '',
      token: token,
      user: rawUser is Map<String, dynamic>
          ? LoginUserModel.fromJson(rawUser)
          : null,
    );
  }
}