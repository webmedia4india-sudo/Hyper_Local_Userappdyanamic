class ProfileResponseModel {
  final bool success;
  final String message;
  final ProfileData? data;

  ProfileResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
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

    ProfileData? profileData;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      profileData = ProfileData.fromJson(json['data']);
    } else if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      profileData = ProfileData.fromJson(json['user']);
    } else if (json.containsKey('name') || json.containsKey('email')) {
      profileData = ProfileData.fromJson(json);
    }

    return ProfileResponseModel(
      success: isSuccess,
      message: json['message']?.toString() ?? '',
      data: profileData,
    );
  }
}

class ProfileData {
  final int id;
  final String name;
  final String email;
  final String mobileNo;
  final String? dob;
  final String? gender;
  final String? address;
  final String? profilePhoto;

  ProfileData({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNo,
    this.dob,
    this.gender,
    this.address,
    this.profilePhoto,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    int parsedId = 0;
    if (json['id'] != null) {
      parsedId = int.tryParse(json['id'].toString()) ?? 0;
    }

    final photo = json['profile_photo']?.toString() ??
        json['profilePhoto']?.toString() ??
        json['photo']?.toString() ??
        json['image']?.toString() ??
        json['avatar']?.toString();

    return ProfileData(
      id: parsedId,
      name: json['name']?.toString() ?? json['userName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobileNo: json['mobile_no']?.toString() ??
          json['mobile']?.toString() ??
          json['phone']?.toString() ??
          '',
      dob: json['DOB']?.toString() ?? json['dob']?.toString(),
      gender: json['Gender']?.toString() ?? json['gender']?.toString(),
      address: json['address']?.toString() ?? json['location']?.toString(),
      profilePhoto: photo,
    );
  }
}