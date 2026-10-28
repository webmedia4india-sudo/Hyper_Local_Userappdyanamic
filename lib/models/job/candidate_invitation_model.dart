class CandidateInvitationModel {
  final int id;
  final int employerId;
  final int candidateId;
  final int jobPostId;
  final String? message;
  final String? interviewDate;
  final String? interviewTime;
  final int? interviewDurationMinutes;
  final String? interviewMode; // online or offline
  final String? interviewType; // technical, hr, managerial, other
  final String? interviewLink;
  final String? interviewLocation;
  final String? interviewInstructions;
  final String invitationStatus; // pending, accepted, rejected
  final String? interviewStatus;
  final String? sentAt;
  final String? respondedAt;

  // Joined fields
  final String companyName;
  final String? companyLogo;
  final String jobTitle;
  final String? jobCategory;
  final String? jobRole;
  final String? department;
  final String? employmentType;
  final dynamic minSalary;
  final dynamic maxSalary;
  final String? location;
  final String? locality;
  final String? fullAddress;

  CandidateInvitationModel({
    required this.id,
    required this.employerId,
    required this.candidateId,
    required this.jobPostId,
    this.message,
    this.interviewDate,
    this.interviewTime,
    this.interviewDurationMinutes,
    this.interviewMode,
    this.interviewType,
    this.interviewLink,
    this.interviewLocation,
    this.interviewInstructions,
    required this.invitationStatus,
    this.interviewStatus,
    this.sentAt,
    this.respondedAt,
    required this.companyName,
    this.companyLogo,
    required this.jobTitle,
    this.jobCategory,
    this.jobRole,
    this.department,
    this.employmentType,
    this.minSalary,
    this.maxSalary,
    this.location,
    this.locality,
    this.fullAddress,
  });

  factory CandidateInvitationModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    final invId = parseInt(json['invitation_id'] ?? json['id']);

    return CandidateInvitationModel(
      id: invId,
      employerId: parseInt(json['employer_id']),
      candidateId: parseInt(json['candidate_id']),
      jobPostId: parseInt(json['job_post_id'] ?? json['job_id']),
      message: json['message']?.toString(),
      interviewDate: json['interview_date']?.toString(),
      interviewTime: json['interview_time']?.toString(),
      interviewDurationMinutes: json['interview_duration_minutes'] != null
          ? parseInt(json['interview_duration_minutes'])
          : null,
      interviewMode: json['interview_mode']?.toString(),
      interviewType: json['interview_type']?.toString(),
      interviewLink: json['interview_link']?.toString(),
      interviewLocation: json['interview_location']?.toString(),
      interviewInstructions: json['interview_instructions']?.toString(),
      invitationStatus:
          json['invitation_status']?.toString().toLowerCase() ?? 'pending',
      interviewStatus: json['interview_status']?.toString(),
      sentAt: json['sent_at']?.toString(),
      respondedAt: json['responded_at']?.toString(),
      companyName: json['company_name']?.toString() ?? 'Company',
      companyLogo: json['company_logo']?.toString(),
      jobTitle: json['job_title']?.toString() ?? 'Position',
      jobCategory: json['job_category']?.toString(),
      jobRole: json['job_role']?.toString(),
      department: json['department']?.toString(),
      employmentType: json['employment_type']?.toString(),
      minSalary: json['min_salary'],
      maxSalary: json['max_salary'],
      location: json['location']?.toString(),
      locality: json['locality']?.toString(),
      fullAddress: json['full_address']?.toString(),
    );
  }

  bool get isNew => invitationStatus == 'pending';
  bool get isAccepted => invitationStatus == 'accepted';
  bool get isDeclined =>
      invitationStatus == 'rejected' || invitationStatus == 'declined';

  String get displayLocation {
    final locs = [locality, location, fullAddress, interviewLocation]
        .where((s) => s != null && s.trim().isNotEmpty && s != 'null')
        .toList();
    return locs.isNotEmpty ? locs.first! : 'Location not specified';
  }

  String get displaySalary {
    if (minSalary != null && maxSalary != null) {
      return '₹$minSalary - ₹$maxSalary / month';
    } else if (minSalary != null) {
      return '₹$minSalary / month';
    } else if (maxSalary != null) {
      return 'Up to ₹$maxSalary / month';
    }
    return 'Salary Negotiable';
  }

  String get formattedInterviewDateTime {
    if (interviewDate == null || interviewDate!.isEmpty) return '';
    try {
      final date = DateTime.tryParse(interviewDate!);
      String dateStr = interviewDate!;
      if (date != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        dateStr = '${date.day} ${months[date.month - 1]} ${date.year}';
      }
      if (interviewTime != null && interviewTime!.isNotEmpty) {
        return '$dateStr at $interviewTime';
      }
      return dateStr;
    } catch (_) {
      return interviewDate!;
    }
  }

  String get formattedSentTime {
    if (sentAt == null || sentAt!.isEmpty) return 'Recently';
    try {
      final dt = DateTime.tryParse(sentAt!);
      if (dt == null) return sentAt!;
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) {
        return diff.inMinutes <= 1 ? "Just now" : "${diff.inMinutes} mins ago";
      } else if (diff.inHours < 24) {
        return '${diff.inHours} hours ago';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      }
    } catch (_) {
      return 'Recently';
    }
  }
}
