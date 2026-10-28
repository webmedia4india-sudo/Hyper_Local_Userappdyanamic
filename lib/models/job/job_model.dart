import 'package:flutter/material.dart';

class JobModel {
  final int id;
  final String title;
  final String companyName;
  final String? companyInitial;
  final String? jobTypeId;
  final String? employmentType;
  final bool isPartTime;
  final bool isWFH;
  final bool isPremium;
  final bool isUrgentHiring;
  final bool isWalkInInterview;
  final bool isFeatured;
  final bool topSearchPlacement;
  final bool homepagePlacement;
  final bool nearbyCandidateNotification;
  final String? location;
  final double distanceKm;
  final int salaryMin;
  final int salaryMax;
  final double rating;
  final int reviewsCount;
  final String? experienceRequired;
  final int totalVacancies;
  final int remainingVacancies;
  final String? postedOn;
  final String? description;
  final List<String> skills;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  JobModel({
    required this.id,
    required this.title,
    required this.companyName,
    this.companyInitial,
    this.jobTypeId,
    this.employmentType,
    this.isPartTime = false,
    this.isWFH = false,
    this.isPremium = false,
    this.isUrgentHiring = false,
    this.isWalkInInterview = false,
    this.isFeatured = false,
    this.topSearchPlacement = false,
    this.homepagePlacement = false,
    this.nearbyCandidateNotification = false,
    this.location,
    this.distanceKm = 0.0,
    required this.salaryMin,
    required this.salaryMax,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.experienceRequired,
    this.totalVacancies = 0,
    this.remainingVacancies = 0,
    this.postedOn,
    this.description,
    this.skills = const [],
    this.status = 'Active',
    this.createdAt,
    this.updatedAt,
    this.cityId,
    this.cityName,
    this.stateId,
    this.stateName,
  });

  final int? cityId;
  final String? cityName;
  final int? stateId;
  final String? stateName;

  factory JobModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedSkills = [];
    if (json['skills'] is List) {
      parsedSkills = (json['skills'] as List)
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (json['skills'] is String) {
      final s = json['skills'] as String;
      if (s.trim().startsWith('[') && s.trim().endsWith(']')) {
        try {
          parsedSkills = s
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .replaceAll("'", '')
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } catch (_) {}
      } else {
        parsedSkills = s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }

    final idVal = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    final salMin = json['min_salary'] is num
        ? (json['min_salary'] as num).toInt()
        : (json['salary_min'] is num
            ? (json['salary_min'] as num).toInt()
            : (double.tryParse(json['min_salary']?.toString() ?? json['salary_min']?.toString() ?? '0')?.toInt() ?? 0));

    final salMax = json['max_salary'] is num
        ? (json['max_salary'] as num).toInt()
        : (json['salary_max'] is num
            ? (json['salary_max'] as num).toInt()
            : (double.tryParse(json['max_salary']?.toString() ?? json['salary_max']?.toString() ?? '0')?.toInt() ?? 0));

    final dist = json['distance_km'] is num
        ? (json['distance_km'] as num).toDouble()
        : double.tryParse(json['distance_km']?.toString() ?? '0.0') ?? 0.0;

    final rat = json['rating'] is num
        ? (json['rating'] as num).toDouble()
        : double.tryParse(json['rating']?.toString() ?? '4.5') ?? 4.5;

    final rev = json['reviews_count'] is num
        ? (json['reviews_count'] as num).toInt()
        : int.tryParse(json['reviews_count']?.toString() ?? '0') ?? 0;

    final totVac = json['number_of_vacancies'] is num
        ? (json['number_of_vacancies'] as num).toInt()
        : (json['total_vacancies'] is num
            ? (json['total_vacancies'] as num).toInt()
            : int.tryParse(json['number_of_vacancies']?.toString() ?? json['total_vacancies']?.toString() ?? '1') ?? 1);

    final remVac = json['remaining_vacancies'] is num
        ? (json['remaining_vacancies'] as num).toInt()
        : int.tryParse(json['remaining_vacancies']?.toString() ?? '') ?? totVac;

    final titleStr = (json['job_title'] ?? json['title'] ?? '').toString();
    final compName = (json['company_name'] ?? json['company'] ?? (json['job_category'] ?? 'Company')).toString();
    final compInit = (json['company_initial'] ??
        (compName.isNotEmpty ? compName.trim().substring(0, 1).toUpperCase() : null))?.toString();
    final jobType = (json['employment_type'] ?? json['job_category'] ?? json['job_type_id'])?.toString();
    final empType = json['employment_type']?.toString();
    final bool isPartTimeVal = (empType != null && empType.toLowerCase().contains('part')) ||
        (jobType != null && jobType.toLowerCase().contains('part')) ||
        json['isPartTime'] == true ||
        json['is_part_time'] == true;
    final bool isWFHVal = (empType != null &&
            (empType.toLowerCase().contains('work from home') ||
             empType.toLowerCase().contains('wfh') ||
             empType.toLowerCase().contains('remote'))) ||
        (jobType != null &&
            (jobType.toLowerCase().contains('work from home') ||
             jobType.toLowerCase().contains('wfh') ||
             jobType.toLowerCase().contains('remote'))) ||
        (titleStr.toLowerCase().contains('work from home') ||
         titleStr.toLowerCase().contains('wfh')) ||
        json['isWFH'] == true ||
        json['is_wfh'] == true;
    final bool isPremVal = json['is_premium'] == 1 || json['is_premium'] == true || json['is_premium'] == '1' || json['isPremium'] == true;
    final bool isUrgVal = json['is_urgent_hiring'] == 1 || json['is_urgent_hiring'] == true || json['is_urgent_hiring'] == '1' || json['isUrgentHiring'] == true || json['isUrgent'] == true;
    final dynamic walkInRaw = json['is_walk_in_interview'] ?? json['isWalkInInterview'] ?? json['isWalkIn'];
    final bool isWalkVal = walkInRaw == 1 ||
        walkInRaw == true ||
        walkInRaw == '1' ||
        walkInRaw.toString().trim() == '1' ||
        walkInRaw.toString().trim().toLowerCase() == 'true';
    final bool isFeatVal = json['is_featured'] == 1 || json['is_featured'] == true || json['is_featured'] == '1' || json['isFeatured'] == true;
    final bool topSearchVal = json['top_search_placement'] == 1 || json['top_search_placement'] == true || json['top_search_placement'] == '1' || json['topSearchPlacement'] == true;
    final bool homePlacementVal = json['homepage_placement'] == 1 || json['homepage_placement'] == true || json['homepage_placement'] == '1' || json['homepagePlacement'] == true;
    final bool nearbyCandidateVal = json['nearby_candidate_notification'] == 1 || json['nearby_candidate_notification'] == true || json['nearby_candidate_notification'] == '1' || json['nearbyCandidateNotification'] == true;
    final loc = (json['location'] ?? json['city'] ?? json['locality'])?.toString();
    final desc = (json['description'] ?? json['job_summary'])?.toString();
    final st = (json['status'] ?? 'Active').toString();

    return JobModel(
      id: idVal,
      title: titleStr.isNotEmpty ? titleStr : 'Job Opening',
      companyName: compName,
      companyInitial: compInit,
      jobTypeId: jobType,
      employmentType: empType ?? jobType,
      isPartTime: isPartTimeVal,
      isWFH: isWFHVal,
      isPremium: isPremVal,
      isUrgentHiring: isUrgVal,
      isWalkInInterview: isWalkVal,
      isFeatured: isFeatVal,
      topSearchPlacement: topSearchVal,
      homepagePlacement: homePlacementVal,
      nearbyCandidateNotification: nearbyCandidateVal,
      location: loc,
      distanceKm: dist,
      salaryMin: salMin,
      salaryMax: salMax,
      rating: rat,
      reviewsCount: rev,
      experienceRequired: json['experience_required']?.toString(),
      totalVacancies: totVac,
      remainingVacancies: remVac,
      postedOn: json['posted_on']?.toString(),
      description: desc,
      skills: parsedSkills,
      status: st,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      cityId: json['city_id'] != null
          ? (json['city_id'] is num ? (json['city_id'] as num).toInt() : int.tryParse(json['city_id'].toString()))
          : (json['cityId'] != null ? int.tryParse(json['cityId'].toString()) : null),
      cityName: (json['city_name'] ?? json['cityName'] ?? json['city'])?.toString(),
      stateId: json['state_id'] != null
          ? (json['state_id'] is num ? (json['state_id'] as num).toInt() : int.tryParse(json['state_id'].toString()))
          : (json['stateId'] != null ? int.tryParse(json['stateId'].toString()) : null),
      stateName: (json['state_name'] ?? json['stateName'] ?? json['state'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company_name': companyName,
      'company_initial': companyInitial,
      'job_type_id': jobTypeId,
      'employment_type': employmentType,
      'is_part_time': isPartTime,
      'is_wfh': isWFH,
      'is_premium': isPremium,
      'is_urgent_hiring': isUrgentHiring,
      'is_walk_in_interview': isWalkInInterview,
      'is_featured': isFeatured,
      'top_search_placement': topSearchPlacement,
      'homepage_placement': homepagePlacement,
      'nearby_candidate_notification': nearbyCandidateNotification,
      'location': location,
      'distance_km': distanceKm,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'rating': rating,
      'reviews_count': reviewsCount,
      'experience_required': experienceRequired,
      'total_vacancies': totalVacancies,
      'remaining_vacancies': remainingVacancies,
      'posted_on': postedOn,
      'description': description,
      'skills': skills,
      'status': status,
      'city_id': cityId,
      'city_name': cityName,
      'state_id': stateId,
      'state_name': stateName,
    };
  }

  // ── UI HELPERS ──────────────────────────────────────────

  String get formattedSalary {
    if (salaryMin > 0 && salaryMax > 0) {
      return '₹${_formatNum(salaryMin)} - ₹${_formatNum(salaryMax)}';
    } else if (salaryMin > 0) {
      return '₹${_formatNum(salaryMin)}+';
    }
    return 'Competitive Salary';
  }

  static String _formatNum(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
      (Match m) => '${m[1]},',
    );
  }

  String get formattedDistance {
    if (distanceKm > 0) {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
    return 'Nearby';
  }

  double get displayRating => rating > 0 ? rating : 4.3;

  String get displayReviewCount => reviewsCount > 0 ? '$reviewsCount reviews' : '3.5k reviews';

  String get logoLetter {
    if (companyInitial != null && companyInitial!.trim().isNotEmpty) {
      return companyInitial!.trim().substring(0, 1).toUpperCase();
    }
    if (companyName.trim().isNotEmpty) {
      return companyName.trim().substring(0, 1).toUpperCase();
    }
    return 'J';
  }

  Color get logoColor {
    const colors = [
      Color(0xFF007CC3), // Infosys Blue
      Color(0xFF001090), // Royal Blue
      Color(0xFFE23744), // Crimson
      Color(0xFF00897B), // Teal
      Color(0xFFFC8019), // Orange
      Color(0xFF8E24AA), // Purple
      Color(0xFF2E7D32), // Green
      Color(0xFF1F70C1), // IBM Blue
    ];
    final hash = companyName.codeUnits.fold(0, (prev, elem) => prev + elem);
    return colors[hash % colors.length];
  }

  String get formattedPostedDate {
    if (postedOn == null || postedOn!.isEmpty) return 'Recently';
    try {
      final dt = DateTime.parse(postedOn!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return postedOn!;
    }
  }
}
