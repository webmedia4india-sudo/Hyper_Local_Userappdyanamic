import 'package:flutter/material.dart';

class JobApplicationModel {
  final int applicationId;
  final int userId;
  final int jobPostId;
  final int? resumeId;
  final String applicationStatus;
  final DateTime? appliedAt;
  final DateTime? updatedAt;

  // Joined Job Post fields
  final String companyName;
  final String? companyInitial;
  final String jobTitle;
  final String? jobCategory;
  final String? jobRole;
  final String? department;
  final String? employmentType;
  final String? jobLevel;
  final String? experienceRequired;
  final num? minSalary;
  final num? maxSalary;
  final String? salaryFrequency;
  final String? country;
  final String? state;
  final String? city;
  final String? location;
  final String? locality;
  final String? jobStatus;

  JobApplicationModel({
    required this.applicationId,
    required this.userId,
    required this.jobPostId,
    this.resumeId,
    required this.applicationStatus,
    this.appliedAt,
    this.updatedAt,
    required this.companyName,
    this.companyInitial,
    required this.jobTitle,
    this.jobCategory,
    this.jobRole,
    this.department,
    this.employmentType,
    this.jobLevel,
    this.experienceRequired,
    this.minSalary,
    this.maxSalary,
    this.salaryFrequency,
    this.country,
    this.state,
    this.city,
    this.location,
    this.locality,
    this.jobStatus,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    final appId = json['application_id'] is int
        ? json['application_id'] as int
        : (json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['application_id']?.toString() ?? json['id']?.toString() ?? '0') ?? 0);

    final uId = json['user_id'] is int
        ? json['user_id'] as int
        : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0;

    final jpId = json['job_post_id'] is int
        ? json['job_post_id'] as int
        : int.tryParse(json['job_post_id']?.toString() ?? '0') ?? 0;

    final resId = json['resume_id'] is int
        ? json['resume_id'] as int
        : int.tryParse(json['resume_id']?.toString() ?? '');

    final status = (json['application_status'] ?? json['status'] ?? 'applied').toString();

    DateTime? parsedAppliedAt;
    if (json['applied_at'] != null) {
      parsedAppliedAt = DateTime.tryParse(json['applied_at'].toString());
    } else if (json['created_at'] != null) {
      parsedAppliedAt = DateTime.tryParse(json['created_at'].toString());
    }

    DateTime? parsedUpdatedAt;
    if (json['updated_at'] != null) {
      parsedUpdatedAt = DateTime.tryParse(json['updated_at'].toString());
    }

    final compName = (json['company_name'] ?? json['company'] ?? 'Company').toString();
    final compInit = json['company_initial']?.toString() ??
        (compName.isNotEmpty ? compName.trim().substring(0, 1).toUpperCase() : 'C');

    final titleStr = (json['job_title'] ?? json['title'] ?? 'Job Position').toString();

    num? parseNum(dynamic val) {
      if (val is num) return val;
      if (val != null) return num.tryParse(val.toString());
      return null;
    }

    return JobApplicationModel(
      applicationId: appId,
      userId: uId,
      jobPostId: jpId,
      resumeId: resId,
      applicationStatus: status,
      appliedAt: parsedAppliedAt,
      updatedAt: parsedUpdatedAt,
      companyName: compName,
      companyInitial: compInit,
      jobTitle: titleStr,
      jobCategory: json['job_category']?.toString(),
      jobRole: json['job_role']?.toString(),
      department: json['department']?.toString(),
      employmentType: json['employment_type']?.toString(),
      jobLevel: json['job_level']?.toString(),
      experienceRequired: json['experience_required']?.toString(),
      minSalary: parseNum(json['min_salary'] ?? json['salary_min']),
      maxSalary: parseNum(json['max_salary'] ?? json['salary_max']),
      salaryFrequency: json['salary_frequency']?.toString(),
      country: json['country']?.toString(),
      state: json['state']?.toString(),
      city: json['city']?.toString(),
      location: json['location']?.toString(),
      locality: json['locality']?.toString(),
      jobStatus: json['job_status']?.toString(),
    );
  }

  String get displayLocation {
    final parts = [locality, city, state]
        .where((e) => e != null && e.trim().isNotEmpty)
        .toList();
    if (parts.isNotEmpty) return parts.join(', ');
    if (location != null && location!.trim().isNotEmpty) return location!;
    return 'Location N/A';
  }

  String get formattedSalary {
    final min = minSalary?.toInt() ?? 0;
    final max = maxSalary?.toInt() ?? 0;
    final freqRaw = (salaryFrequency != null && salaryFrequency!.isNotEmpty)
        ? salaryFrequency!.toLowerCase().replaceAll('per_', '')
        : 'month';
    final freq = ' /$freqRaw';

    if (min > 0 && max > 0) {
      return '₹${_formatNum(min)} - ₹${_formatNum(max)}$freq';
    } else if (min > 0) {
      return '₹${_formatNum(min)}+$freq';
    }
    return 'Competitive Salary';
  }

  static String _formatNum(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
      (Match m) => '${m[1]},',
    );
  }

  String get formattedAppliedDate {
    if (appliedAt == null) return 'Applied recently';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Applied ${appliedAt!.day} ${months[appliedAt!.month - 1]} ${appliedAt!.year}';
  }

  String get statusLabel {
    switch (applicationStatus.toLowerCase().trim()) {
      case 'applied':
        return 'Applied';
      case 'under_review':
        return 'Under Review';
      case 'shortlisted':
        return 'Shortlisted';
      case 'interview':
        return 'Interview';
      case 'selected':
        return 'Selected';
      case 'rejected':
        return 'Rejected';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return applicationStatus.replaceAll('_', ' ');
    }
  }

  Color get statusColor {
    switch (applicationStatus.toLowerCase().trim()) {
      case 'applied':
        return const Color(0xFF3B82F6); // Blue
      case 'under_review':
        return const Color(0xFFF59E0B); // Amber / Orange
      case 'shortlisted':
        return const Color(0xFF10B981); // Emerald Green
      case 'interview':
        return const Color(0xFF8B5CF6); // Purple
      case 'selected':
        return const Color(0xFF047857); // Dark Forest Green
      case 'rejected':
        return const Color(0xFFEF4444); // Red
      case 'withdrawn':
        return const Color(0xFF6B7280); // Grey
      default:
        return const Color(0xFF3B82F6);
    }
  }

  bool get canWithdraw {
    final s = applicationStatus.toLowerCase().trim();
    return s != 'selected' && s != 'rejected' && s != 'withdrawn';
  }

  String get logoLetter {
    if (companyInitial != null && companyInitial!.trim().isNotEmpty) {
      return companyInitial!.trim().substring(0, 1).toUpperCase();
    }
    if (companyName.trim().isNotEmpty) {
      return companyName.trim().substring(0, 1).toUpperCase();
    }
    return 'C';
  }

  Color get logoColor {
    const colors = [
      Color(0xFF4285F4),
      Color(0xFF00A4EF),
      Color(0xFFFF9900),
      Color(0xFF1F70C1),
      Color(0xFFFF0000),
      Color(0xFFE11D48),
      Color(0xFF00A1E0),
      Color(0xFFF80000),
    ];
    final hash = companyName.codeUnits.fold(0, (prev, elem) => prev + elem);
    return colors[hash % colors.length];
  }
}
