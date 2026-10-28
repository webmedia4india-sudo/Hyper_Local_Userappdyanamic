import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/interviewschedulepage.dart';
import 'package:hyper_local/models/job/job_interview_model.dart';
import 'package:hyper_local/services/job_interview_service.dart';
import '../utils/app_colors.dart';

class ApplicationTimelinePage extends StatefulWidget {
  final int? applicationId;
  final String title;
  final String company;
  final String logoText;
  final Color logoColor;
  final String appliedOn;
  final String status;
  final Color statusColor;

  const ApplicationTimelinePage({
    super.key,
    this.applicationId,
    required this.title,
    required this.company,
    required this.logoText,
    required this.logoColor,
    required this.appliedOn,
    required this.status,
    required this.statusColor,
  });

  @override
  State<ApplicationTimelinePage> createState() =>
      _ApplicationTimelinePageState();
}

class _ApplicationTimelinePageState extends State<ApplicationTimelinePage> {
  final JobInterviewService _interviewService = JobInterviewService();
  JobInterviewModel? _associatedInterview;
  bool _isLoadingInterview = false;

  @override
  void initState() {
    super.initState();
    _fetchInterviewDetails();
  }

  Future<void> _fetchInterviewDetails() async {
    if (widget.applicationId == null || widget.applicationId! <= 0) return;

    setState(() {
      _isLoadingInterview = true;
    });

    try {
      final interview = await _interviewService
          .getInterviewByApplicationId(widget.applicationId!);
      if (!mounted) return;
      setState(() {
        _associatedInterview = interview;
        _isLoadingInterview = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingInterview = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _stages {
    const allStages = [
      "Applied",
      "Under Review",
      "Shortlisted",
      "Interview Scheduled",
      "Result",
    ];

    final currentAppStatus = widget.status.toLowerCase().trim();
    final bool hasInterview = _associatedInterview != null &&
        (_associatedInterview!.isUpcoming ||
            _associatedInterview!.isCompleted ||
            _associatedInterview!.responseStatus != 'rejected');
    final bool hasResult = (_associatedInterview != null &&
            _associatedInterview!.outcome.isNotEmpty &&
            _associatedInterview!.outcome != 'pending') ||
        currentAppStatus == 'selected' ||
        currentAppStatus == 'rejected';

    int currentIndex = 0;
    if (hasResult) {
      currentIndex = 4; // Result
    } else if (hasInterview || currentAppStatus == 'interview') {
      currentIndex = 3; // Interview Scheduled
    } else if (currentAppStatus == 'shortlisted') {
      currentIndex = 2; // Shortlisted
    } else if (currentAppStatus == 'under_review' ||
        currentAppStatus == 'under review') {
      currentIndex = 1; // Under Review
    } else {
      currentIndex = 0; // Applied
    }

    return List.generate(allStages.length, (index) {
      return {
        "label": allStages[index],
        "isCompleted": index < currentIndex,
        "isCurrent": index == currentIndex,
      };
    });
  }

  Color _getResponseStatusColor(String responseStatus) {
    switch (responseStatus.toLowerCase()) {
      case 'accepted':
        return Colors.green[600]!;
      case 'rejected':
        return Colors.red[600]!;
      default:
        return Colors.orange[700]!;
    }
  }

  String _getResponseStatusLabel(String responseStatus) {
    switch (responseStatus.toLowerCase()) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending Response';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "Application Status",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInterviewDetails,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── JOB / COMPANY HEADER CARD ────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.logoColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        widget.logoText,
                        style: const TextStyle(
                          color: AppColors.buttonText,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.company,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Applied on ${widget.appliedOn}",
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.status,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: widget.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── SCHEDULED INTERVIEW SUMMARY CARD (If exists) ──
            if (_associatedInterview != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _getResponseStatusColor(
                            _associatedInterview!.responseStatus)
                        .withOpacity(0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.event_available_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "Interview Details",
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getResponseStatusColor(
                                    _associatedInterview!.responseStatus)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getResponseStatusLabel(
                                _associatedInterview!.responseStatus),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _getResponseStatusColor(
                                  _associatedInterview!.responseStatus),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined,
                            size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          "${_associatedInterview!.formattedDay} ${_associatedInterview!.formattedMonthYear} at ${_associatedInterview!.formattedTime}",
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _associatedInterview!.displayMode,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          _associatedInterview!.interviewMode == 'online'
                              ? Icons.link_rounded
                              : Icons.place_outlined,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _associatedInterview!.interviewMode == 'online'
                                ? (_associatedInterview!.interviewLink ??
                                    'Online Meeting')
                                : _associatedInterview!.displayOfficeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InterviewSchedulePage(),
                            ),
                          ).then((_) => _fetchInterviewDetails());
                        },
                        icon: const Icon(Icons.arrow_forward_rounded,
                            size: 16, color: Colors.white),
                        label: const Text(
                          "View in Interview Desk",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            const Text(
              "Application Timeline",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // ── VERTICAL STEPPER TIMELINE ────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: List.generate(_stages.length, (index) {
                  final stage = _stages[index];
                  final isLast = index == _stages.length - 1;
                  final label = stage["label"] as String;

                  return _timelineTile(
                    context: context,
                    label: label,
                    isCompleted: stage["isCompleted"] as bool,
                    isCurrent: stage["isCurrent"] as bool,
                    isLast: isLast,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SINGLE TIMELINE STEP (dot + connecting line + label) ─
  Widget _timelineTile({
    required BuildContext context,
    required String label,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    final Color dotColor = isCompleted || isCurrent
        ? AppColors.primary
        : AppColors.unselected;

    // "Interview Scheduled" stage opens the Interview Desk
    final bool isTappable = label == "Interview Scheduled";

    final Widget tileContent = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 14),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primary : AppColors.background,
                  border: Border.all(color: dotColor, width: 2),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 10, color: AppColors.buttonText)
                    : isCurrent
                        ? Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? AppColors.primary : AppColors.divider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCompleted || isCurrent
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (isTappable)
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (!isTappable) return tileContent;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InterviewSchedulePage(),
          ),
        ).then((_) => _fetchInterviewDetails());
      },
      child: tileContent,
    );
  }
}