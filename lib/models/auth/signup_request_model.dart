class SignupRequestModel {
  final String name;
  final String email;
  final String mobileNo;
  final String dob;
  final String gender;
  final String industry;
  final String currentRole;

  SignupRequestModel({
    required this.name,
    required this.email,
    required this.mobileNo,
    required this.dob,
    required this.gender,
    required this.industry,
    required this.currentRole,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "mobile_no": mobileNo,
      "DOB": dob,
      "Gender": gender,
      "industry": industry,
      "current_role": currentRole,
    };
  }
}

class SignupVerifyOtpRequestModel {
  final String name;
  final String email;
  final String mobileNo;
  final String dob;
  final String gender;
  final String industry;
  final String currentRole;
  final String otp;

  SignupVerifyOtpRequestModel({
    required this.name,
    required this.email,
    required this.mobileNo,
    required this.dob,
    required this.gender,
    required this.industry,
    required this.currentRole,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "mobile_no": mobileNo,
      "DOB": dob,
      "Gender": gender,
      "industry": industry,
      "current_role": currentRole,
      "otp": otp,
    };
  }
}

//login-api
class VerifyOtpRequestModel {
  final String mobileNo;
  final String otp;

  VerifyOtpRequestModel({required this.mobileNo, required this.otp});

  Map<String, dynamic> toJson() {
    return {
      "mobile_no": mobileNo,
      "otp": otp,
    };
  }
}

class LoginRequestModel {
  final String mobileNo;
  LoginRequestModel({required this.mobileNo});

  Map<String, dynamic> toJson() => {"mobile_no": mobileNo};
}