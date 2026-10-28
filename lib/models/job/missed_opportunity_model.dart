import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class MissedOpportunityModel {
  final int id;
  final String title;
  final String companyName;
  final String? companyFullName;
  final int minSalary;
  final int maxSalary;
  final String? acceptApplicationsUntil;
  final int savedByUser;
  final int alreadyApplied;
  final String? applicationStatus;
  final String? missedReason;
  final int totalVacancies;
  final int filledVacancies;
  final int remainingVacancies;
  final String? eligibleAt;
  final bool isVacanciesFilled;
  final bool isDeadlineExpired;
  final String? createdAt;

  MissedOpportunityModel({
    required this.id,
    required this.title,
    required this.companyName,
    this.companyFullName,
    this.minSalary = 0,
    this.maxSalary = 0,
    this.acceptApplicationsUntil,
    this.savedByUser = 0,
    this.alreadyApplied = 0,
    this.applicationStatus,
    this.missedReason,
    this.createdAt,
    this.totalVacancies = 1,
    this.filledVacancies = 0,
    this.remainingVacancies = 1,
    this.eligibleAt,
    this.isVacanciesFilled = false,
    this.isDeadlineExpired = false,
  });

  factory MissedOpportunityModel.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    final t = (json['job_title'] ?? json['title'] ?? 'Job Opportunity').toString();
    final c = (json['company_name'] ?? json['company'] ?? 'Company').toString();
    final cFull = json['company_full_name']?.toString() ?? (c.isNotEmpty ? "$c Pvt. Ltd." : "");

    final minSal = json['min_salary'] is num
        ? (json['min_salary'] as num).toInt()
        : int.tryParse(json['min_salary']?.toString() ?? json['salary_min']?.toString() ?? '0') ?? 0;

    final maxSal = json['max_salary'] is num
        ? (json['max_salary'] as num).toInt()
        : int.tryParse(json['max_salary']?.toString() ?? json['salary_max']?.toString() ?? '0') ?? 0;

    final saved = json['saved_by_user'] is num
        ? (json['saved_by_user'] as num).toInt()
        : int.tryParse(json['saved_by_user']?.toString() ?? '0') ?? 0;

    final applied = json['already_applied'] is num
        ? (json['already_applied'] as num).toInt()
        : int.tryParse(json['already_applied']?.toString() ?? '0') ?? 0;

    final totVac = json['total_vacancies'] is num
        ? (json['total_vacancies'] as num).toInt()
        : (json['number_of_vacancies'] is num
            ? (json['number_of_vacancies'] as num).toInt()
            : int.tryParse(json['total_vacancies']?.toString() ?? json['number_of_vacancies']?.toString() ?? '1') ?? 1);

    final filledVac = json['filled_vacancies'] is num
        ? (json['filled_vacancies'] as num).toInt()
        : int.tryParse(json['filled_vacancies']?.toString() ?? '0') ?? 0;

    final remVac = json['remaining_vacancies'] is num
        ? (json['remaining_vacancies'] as num).toInt()
        : (json['calculated_remaining_vacancies'] is num
            ? (json['calculated_remaining_vacancies'] as num).toInt()
            : int.tryParse(json['remaining_vacancies']?.toString() ?? json['calculated_remaining_vacancies']?.toString() ?? '') ?? (totVac - filledVac).clamp(0, totVac));

    final isVacFilled = json['is_vacancies_filled'] == 1 ||
        json['is_vacancies_filled'] == true ||
        (totVac > 0 && filledVac >= totVac);

    final isDeadExp = json['is_deadline_expired'] == 1 ||
        json['is_deadline_expired'] == true;

    return MissedOpportunityModel(
      id: idVal,
      title: t,
      companyName: c,
      companyFullName: cFull,
      minSalary: minSal,
      maxSalary: maxSal,
      acceptApplicationsUntil: json['accept_applications_until']?.toString(),
      savedByUser: saved,
      alreadyApplied: applied,
      applicationStatus: json['application_status']?.toString(),
      missedReason: json['missed_reason']?.toString(),
      createdAt: json['created_at']?.toString(),
      totalVacancies: totVac,
      filledVacancies: filledVac,
      remainingVacancies: remVac,
      eligibleAt: json['eligible_at']?.toString(),
      isVacanciesFilled: isVacFilled,
      isDeadlineExpired: isDeadExp,
    );
  }

  /// Evaluates whether this job is still within its 5-calendar-day retention period.
  bool get isWithinRetentionPeriod {
    final dateStr = eligibleAt ?? acceptApplicationsUntil;
    if (dateStr == null || dateStr.trim().isEmpty) return true;
    try {
      final eligibilityDate = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final eligibleDay = DateTime(eligibilityDate.year, eligibilityDate.month, eligibilityDate.day);
      final diffDays = today.difference(eligibleDay).inDays;
      if (diffDays < 0) return true; // future deadline or eligibility
      return diffDays <= 5;
    } catch (_) {
      return true;
    }
  }

  String get formattedSalary {
    if (minSalary > 0 && maxSalary > 0) {
      return '₹${_formatNum(minSalary)} - ₹${_formatNum(maxSalary)}';
    } else if (minSalary > 0) {
      return '₹${_formatNum(minSalary)}+';
    }
    return 'Competitive Salary';
  }

  static String _formatNum(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
      (Match m) => '${m[1]},',
    );
  }

  String get formattedPostedDate {
    if (createdAt == null || createdAt!.isEmpty) return 'Recently';
    try {
      final dt = DateTime.parse(createdAt!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return createdAt!;
    }
  }

  String get formattedClosedDate {
    final dateStr = eligibleAt ?? acceptApplicationsUntil;
    if (dateStr == null || dateStr.isEmpty) return 'Expired';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String get formattedReason {
    switch (missedReason) {
      case 'vacancies_filled':
        return 'All $totalVacancies vacancies have been filled.';
      case 'saved_and_vacancies_filled':
        return 'Saved by you, but all $totalVacancies positions have been filled.';
      case 'saved_and_deadline_expired':
        return 'Saved by you, but the application deadline has passed.';
      case 'saved_not_applied':
        return 'Saved in your list, but application deadline expired.';
      case 'deadline_expired':
        return 'Application deadline has passed for this position.';
      default:
        if (isVacanciesFilled || (totalVacancies > 0 && filledVacancies >= totalVacancies)) {
          return 'All $totalVacancies positions have been filled.';
        }
        return 'This opportunity is no longer accepting applications.';
    }
  }

  String get logoLetter {
    if (companyName.trim().isNotEmpty) {
      return companyName.trim().substring(0, 1).toUpperCase();
    }
    return '?';
  }

  Color get logoColor {
    const colors = [
      AppColors.primary,
      AppColors.coral,
      AppColors.mint,
      AppColors.pink,
      Color(0xFF9D4EDD),
      Color(0xFF007CC3),
    ];
    final hash = companyName.codeUnits.fold(0, (prev, elem) => prev + elem);
    return colors[hash % colors.length];
  }
}
