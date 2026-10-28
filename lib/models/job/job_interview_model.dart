import 'package:flutter/material.dart';

class JobInterviewModel {
  final int id;
  final int applicationId;
  final int employerId;
  final int userId;
  final int? jobPostId;
  final String interviewDate; // e.g. '2026-10-15'
  final String interviewTime; // e.g. '11:00:00' or '11:00'
  final String interviewMode; // 'online', 'offline', 'phone'
  final String? interviewLink;
  final String? interviewLocation;
  final String? interviewVenue;
  final String? interviewCity;
  final String? interviewerName;
  final String? interviewerDesignation;
  final String? interviewRemark;
  final String responseStatus; // 'pending', 'accepted', 'rejected'
  final String? candidateResponseRemark;
  final String interviewStatus; // 'scheduled', 'rescheduled', 'completed', 'cancelled'
  final String outcome; // 'pending', 'selected', 'not_selected', 'next_round'

  // Joined fields
  final String jobTitle;
  final String companyName;
  final String? candidateName;
  final String? candidateEmail;
  final String? candidatePhone;
  final String? applicationStatus;

  JobInterviewModel({
    required this.id,
    required this.applicationId,
    required this.employerId,
    required this.userId,
    this.jobPostId,
    required this.interviewDate,
    required this.interviewTime,
    required this.interviewMode,
    this.interviewLink,
    this.interviewLocation,
    this.interviewVenue,
    this.interviewCity,
    this.interviewerName,
    this.interviewerDesignation,
    this.interviewRemark,
    required this.responseStatus,
    this.candidateResponseRemark,
    required this.interviewStatus,
    required this.outcome,
    required this.jobTitle,
    required this.companyName,
    this.candidateName,
    this.candidateEmail,
    this.candidatePhone,
    this.applicationStatus,
  });

  factory JobInterviewModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    final id = parseInt(json['interview_id'] ?? json['id']);
    final applicationId = parseInt(json['application_id']);
    final employerId = parseInt(json['employer_id'] ?? json['job_employer_id']);
    final userId = parseInt(json['user_id']);
    final jobPostId = json['job_post_id'] != null ? parseInt(json['job_post_id']) : null;

    final dateStr = (json['interview_date'] ?? '').toString();
    // Sometimes MySQL returns ISO string e.g. 2026-10-15T00:00:00.000Z
    final cleanDate = dateStr.contains('T') ? dateStr.split('T')[0] : dateStr;

    return JobInterviewModel(
      id: id,
      applicationId: applicationId,
      employerId: employerId,
      userId: userId,
      jobPostId: jobPostId,
      interviewDate: cleanDate,
      interviewTime: (json['interview_time'] ?? '').toString(),
      interviewMode: (json['interview_mode'] ?? 'online').toString().toLowerCase(),
      interviewLink: json['interview_link']?.toString(),
      interviewLocation: json['interview_location']?.toString(),
      interviewVenue: json['interview_venue']?.toString(),
      interviewCity: json['interview_city']?.toString(),
      interviewerName: json['interviewer_name']?.toString(),
      interviewerDesignation: json['interviewer_designation']?.toString(),
      interviewRemark: json['interview_remark']?.toString(),
      responseStatus: (json['response_status'] ?? 'pending').toString().toLowerCase(),
      candidateResponseRemark: json['candidate_response_remark']?.toString(),
      interviewStatus: (json['interview_status'] ?? 'scheduled').toString().toLowerCase(),
      outcome: (json['outcome'] ?? 'pending').toString().toLowerCase(),
      jobTitle: (json['job_title'] ?? 'Interview').toString(),
      companyName: (json['company_name'] ?? 'Company').toString(),
      candidateName: json['candidate_name']?.toString(),
      candidateEmail: json['candidate_email']?.toString(),
      candidatePhone: json['candidate_phone']?.toString(),
      applicationStatus: json['application_status']?.toString(),
    );
  }

  // --- UI FORMATTING HELPERS ---

  DateTime? get parsedDateTime {
    if (interviewDate.isEmpty) return null;
    try {
      final parts = interviewDate.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);

        int hour = 9;
        int minute = 0;
        if (interviewTime.isNotEmpty) {
          final tParts = interviewTime.split(':');
          if (tParts.isNotEmpty) hour = int.tryParse(tParts[0]) ?? 9;
          if (tParts.length > 1) minute = int.tryParse(tParts[1]) ?? 0;
        }

        return DateTime(year, month, day, hour, minute);
      }
    } catch (_) {}
    return null;
  }

  String get formattedDay {
    final dt = parsedDateTime;
    if (dt != null) return dt.day.toString().padLeft(2, '0');
    return '15';
  }

  String get formattedMonthYear {
    final dt = parsedDateTime;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (dt != null && dt.month >= 1 && dt.month <= 12) {
      return '${months[dt.month - 1]} ${dt.year}';
    }
    return 'May 2026';
  }

  String get formattedTime {
    if (interviewTime.isEmpty) return '11:00 AM';
    try {
      final tParts = interviewTime.split(':');
      if (tParts.isNotEmpty) {
        int hour = int.tryParse(tParts[0]) ?? 0;
        int minute = tParts.length > 1 ? (int.tryParse(tParts[1]) ?? 0) : 0;
        final period = hour >= 12 ? 'PM' : 'AM';
        int displayHour = hour % 12;
        if (displayHour == 0) displayHour = 12;
        final minuteStr = minute.toString().padLeft(2, '0');
        return '${displayHour.toString().padLeft(2, '0')}:$minuteStr $period';
      }
    } catch (_) {}
    return interviewTime;
  }

  String get daysLeftLabel {
    final dt = parsedDateTime;
    if (interviewStatus == 'completed') return 'Completed';
    if (interviewStatus == 'cancelled') return 'Cancelled';
    if (interviewStatus == 'rescheduled') return 'Rescheduled';

    if (dt == null) return 'Upcoming';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final interviewDay = DateTime(dt.year, dt.month, dt.day);
    final diff = interviewDay.difference(today).inDays;

    if (diff < 0) return 'Passed';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return '$diff Days left';
  }

  String get displayMode {
    switch (interviewMode.toLowerCase()) {
      case 'online':
        return 'Video Call';
      case 'offline':
        return 'In-Person';
      case 'phone':
        return 'Phone Call';
      default:
        return 'In-Person';
    }
  }

  String get displayInterviewer {
    if (interviewerName != null && interviewerName!.trim().isNotEmpty) {
      if (interviewerDesignation != null && interviewerDesignation!.trim().isNotEmpty) {
        return '${interviewerName!.trim()} (${interviewerDesignation!.trim()})';
      }
      return interviewerName!.trim();
    }
    return 'Hiring Team';
  }

  String get displayOfficeName {
    if (interviewVenue != null && interviewVenue!.trim().isNotEmpty) {
      return interviewVenue!.trim();
    }
    if (interviewLocation != null && interviewLocation!.trim().isNotEmpty) {
      return interviewLocation!.trim();
    }
    return '$companyName Office';
  }

  String get displayOfficeAddress {
    if (interviewLocation != null && interviewLocation!.trim().isNotEmpty) {
      return interviewLocation!.trim();
    }
    if (interviewCity != null && interviewCity!.trim().isNotEmpty) {
      return interviewCity!.trim();
    }
    return 'Office Location';
  }

  String get logoText {
    final clean = companyName.trim();
    if (clean.isNotEmpty) return clean[0].toUpperCase();
    return 'C';
  }

  Color get logoColor {
    const colors = [
      Color(0xFF1E3A8A),
      Color(0xFF6D28D9),
      Color(0xFF3B82F6),
      Color(0xFFE11D48),
      Color(0xFF0D9488),
      Color(0xFFD97706),
    ];
    final hash = companyName.codeUnits.fold(0, (prev, elem) => prev + elem);
    return colors[hash % colors.length];
  }

  bool get isPending => responseStatus == 'pending';
  bool get isAccepted => responseStatus == 'accepted';
  bool get isRejected => responseStatus == 'rejected';

  bool get isUpcoming => interviewStatus == 'scheduled' || interviewStatus == 'rescheduled';
  bool get isCancelled => interviewStatus == 'cancelled';
  bool get isCompleted => interviewStatus == 'completed';
}
