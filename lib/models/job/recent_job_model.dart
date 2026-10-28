import 'package:flutter/material.dart';

class RecentJobModel {
  final int id;
  final String title;
  final String company;
  final String companyFullName;
  final String companyInitial;
  final String salary;
  final int minSalary;
  final int maxSalary;
  final String distance;
  final String experience;
  final double rating;
  final String reviewCount;
  final List<String> skills;
  final String description;
  final int totalVacancies;
  final int remainingVacancies;
  final String postedDate;
  final String? createdAt;
  final String? employmentType;
  final bool isPartTime;
  final bool isWFH;
  final bool isPremium;
  final bool isUrgentHiring;
  final bool isWalkInInterview;
  final bool isFeatured;
  final String badgeText;
  final Color logoColor;
  final String? logoUrl;
  final int? cityId;
  final String? cityName;
  final int? stateId;
  final String? stateName;
  final Map<String, dynamic> raw;

  RecentJobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.companyFullName,
    required this.companyInitial,
    required this.salary,
    required this.minSalary,
    required this.maxSalary,
    required this.distance,
    required this.experience,
    required this.rating,
    required this.reviewCount,
    required this.skills,
    required this.description,
    required this.totalVacancies,
    required this.remainingVacancies,
    required this.postedDate,
    this.createdAt,
    this.employmentType,
    this.isPartTime = false,
    this.isWFH = false,
    this.isPremium = false,
    this.isUrgentHiring = false,
    this.isWalkInInterview = false,
    this.isFeatured = false,
    this.badgeText = "JUST IN",
    required this.logoColor,
    this.logoUrl,
    this.cityId,
    this.cityName,
    this.stateId,
    this.stateName,
    required this.raw,
  });

  factory RecentJobModel.fromJson(Map<String, dynamic> json, [int index = 0]) {
    final int idVal = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    final String titleVal = (json['job_title'] ?? json['title'] ?? json['jobTitle'] ?? 'Job Opening')
        .toString()
        .trim();

    final String compVal = (json['company_name'] ?? json['company'] ?? json['companyName'] ?? json['job_category'] ?? 'Company')
        .toString()
        .trim();

    final String initial = compVal.isNotEmpty ? compVal.substring(0, 1).toUpperCase() : 'J';

    final int salMin = json['min_salary'] is num
        ? (json['min_salary'] as num).toInt()
        : (json['salary_min'] is num
            ? (json['salary_min'] as num).toInt()
            : (double.tryParse(json['min_salary']?.toString() ?? json['salary_min']?.toString() ?? '0')?.toInt() ?? 0));

    final int salMax = json['max_salary'] is num
        ? (json['max_salary'] as num).toInt()
        : (json['salary_max'] is num
            ? (json['salary_max'] as num).toInt()
            : (double.tryParse(json['max_salary']?.toString() ?? json['salary_max']?.toString() ?? '0')?.toInt() ?? 0));

    String salaryStr;
    if (json['salary'] != null && json['salary'].toString().trim().isNotEmpty) {
      salaryStr = json['salary'].toString().trim();
    } else if (salMin > 0 && salMax > 0) {
      salaryStr = "₹${_formatNumber(salMin)} - ₹${_formatNumber(salMax)}";
    } else if (salMin > 0) {
      salaryStr = "₹${_formatNumber(salMin)}+";
    } else {
      salaryStr = "Competitive Salary";
    }

    final double distVal = json['distance_km'] is num
        ? (json['distance_km'] as num).toDouble()
        : double.tryParse(json['distance_km']?.toString() ?? '0.0') ?? 0.0;
    final String distStr = distVal > 0 ? "${distVal.toStringAsFixed(1)} km" : "Nearby";

    final double ratVal = json['rating'] is num
        ? (json['rating'] as num).toDouble()
        : double.tryParse(json['rating']?.toString() ?? '4.2') ?? 4.2;

    final String revStr = (json['reviews_count'] != null && json['reviews_count'].toString() != '0')
        ? "${json['reviews_count']} reviews"
        : "3.5k reviews";

    final String expStr = (json['experience_required'] ?? json['experience'] ?? '1-2 years').toString();

    List<String> parsedSkills = [];
    if (json['skills'] is List) {
      parsedSkills = (json['skills'] as List)
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (json['skills'] is String) {
      final s = json['skills'] as String;
      parsedSkills = s
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .replaceAll("'", '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (parsedSkills.isEmpty) {
      parsedSkills = ["Communication", "Problem Solving"];
    }

    final String descStr = (json['description'] ?? json['job_summary'] ?? 'Recently posted job opening near you.').toString();

    final int totVac = json['number_of_vacancies'] is num
        ? (json['number_of_vacancies'] as num).toInt()
        : int.tryParse(json['number_of_vacancies']?.toString() ?? '1') ?? 1;

    final int remVac = json['remaining_vacancies'] is num
        ? (json['remaining_vacancies'] as num).toInt()
        : int.tryParse(json['remaining_vacancies']?.toString() ?? '') ?? totVac;

    String postedDateStr = 'Recently';
    final rawPosted = json['posted_on'] ?? json['created_at'];
    if (rawPosted != null && rawPosted.toString().isNotEmpty) {
      try {
        final dt = DateTime.parse(rawPosted.toString());
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        postedDateStr = "${dt.day} ${months[dt.month - 1]} ${dt.year}";
      } catch (_) {
        postedDateStr = rawPosted.toString();
      }
    }

    final List<Color> accentColors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF97316), // Orange
      const Color(0xFF8B5CF6), // Purple
    ];
    final Color colorVal = accentColors[index % accentColors.length];

    final String? logoUrlVal = (json['logo_url'] ?? json['logoUrl'] ?? json['company_logo'])?.toString();
    final String? empType = (json['employment_type'] ?? json['job_type_id'])?.toString();
    final bool isPartTimeVal = (empType != null && empType.toLowerCase().contains('part')) ||
        (titleVal.toLowerCase().contains('part-time')) ||
        (json['isPartTime'] == true) ||
        (json['is_part_time'] == true);
    final bool isWFHVal = (empType != null &&
            (empType.toLowerCase().contains('work from home') ||
             empType.toLowerCase().contains('wfh') ||
             empType.toLowerCase().contains('remote'))) ||
        (titleVal.toLowerCase().contains('work from home') ||
         titleVal.toLowerCase().contains('wfh')) ||
        (json['isWFH'] == true) ||
        (json['is_wfh'] == true);

    final bool isPremVal = json['is_premium'] == 1 || json['is_premium'] == true || json['is_premium'] == '1' || json['isPremium'] == true;
    final bool isUrgVal = json['is_urgent_hiring'] == 1 || json['is_urgent_hiring'] == true || json['is_urgent_hiring'] == '1' || json['isUrgentHiring'] == true || json['isUrgent'] == true;
    final dynamic walkInRaw = json['is_walk_in_interview'] ?? json['isWalkInInterview'] ?? json['isWalkIn'];
    final bool isWalkVal = walkInRaw == 1 ||
        walkInRaw == true ||
        walkInRaw == '1' ||
        walkInRaw.toString().trim() == '1' ||
        walkInRaw.toString().trim().toLowerCase() == 'true';
    final bool isFeatVal = json['is_featured'] == 1 || json['is_featured'] == true || json['is_featured'] == '1' || json['isFeatured'] == true;

    final int? cityIdVal = json['city_id'] != null
        ? (json['city_id'] is num
            ? (json['city_id'] as num).toInt()
            : int.tryParse(json['city_id'].toString()))
        : (json['cityId'] != null ? int.tryParse(json['cityId'].toString()) : null);
    final String? cityNameVal = (json['city_name'] ?? json['cityName'] ?? json['city'])?.toString();
    final int? stateIdVal = json['state_id'] != null
        ? (json['state_id'] is num
            ? (json['state_id'] as num).toInt()
            : int.tryParse(json['state_id'].toString()))
        : (json['stateId'] != null ? int.tryParse(json['stateId'].toString()) : null);
    final String? stateNameVal = (json['state_name'] ?? json['stateName'] ?? json['state'])?.toString();

    return RecentJobModel(
      id: idVal,
      title: titleVal.isNotEmpty ? titleVal : 'Job Opening',
      company: compVal.isNotEmpty ? compVal : 'Company',
      companyFullName: (json['company_full_name'] ?? compVal).toString(),
      companyInitial: initial,
      salary: salaryStr,
      minSalary: salMin,
      maxSalary: salMax,
      distance: distStr,
      experience: expStr,
      rating: ratVal,
      reviewCount: revStr,
      skills: parsedSkills,
      description: descStr,
      totalVacancies: totVac > 0 ? totVac : 1,
      remainingVacancies: remVac > 0 ? remVac : 1,
      postedDate: postedDateStr,
      createdAt: json['created_at']?.toString(),
      employmentType: empType,
      isPartTime: isPartTimeVal,
      isWFH: isWFHVal,
      isPremium: isPremVal,
      isUrgentHiring: isUrgVal,
      isWalkInInterview: isWalkVal,
      isFeatured: isFeatVal,
      badgeText: "JUST IN",
      logoColor: colorVal,
      logoUrl: logoUrlVal,
      cityId: cityIdVal,
      cityName: cityNameVal,
      stateId: stateIdVal,
      stateName: stateNameVal,
      raw: json,
    );
  }

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
      (Match m) => '${m[1]},',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "company": company,
      "companyFullName": companyFullName,
      "distance": distance,
      "salary": salary,
      "logoText": companyInitial,
      "logoColor": logoColor,
      "logoUrl": logoUrl ?? "",
      "rating": rating,
      "reviewCount": reviewCount,
      "experience": experience,
      "skills": skills,
      "description": description,
      "totalVacancies": totalVacancies,
      "remainingVacancies": remainingVacancies,
      "postedDate": postedDate,
      "createdAt": createdAt,
      "employmentType": employmentType,
      "isPartTime": isPartTime,
      "isWFH": isWFH,
      "isPremium": isPremium,
      "isUrgent": isUrgentHiring,
      "isUrgentHiring": isUrgentHiring,
      "isWalkIn": isWalkInInterview,
      "isWalkInInterview": isWalkInInterview,
      "is_walk_in_interview": isWalkInInterview ? 1 : 0,
      "isFeatured": isFeatured,
      "city_id": cityId,
      "cityId": cityId,
      "city_name": cityName,
      "cityName": cityName,
      "state_id": stateId,
      "state_name": stateName,
      "badgeText": badgeText,
      "raw": raw,
    };
  }
}
