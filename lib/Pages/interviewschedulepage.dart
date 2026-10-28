import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hyper_local/utils/app_colors.dart';
import 'package:hyper_local/Pages/calendarpage.dart' hide AppColors;
import 'package:hyper_local/Pages/recommendedjpbpage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hyper_local/models/job/job_interview_model.dart';
import 'package:hyper_local/services/job_interview_service.dart';

class InterviewSchedulePage extends StatefulWidget {
  final String role;
  final String company;
  final String logoText;
  final Color logoColor;
  final String date;
  final String month;
  final String time;
  final String daysLeftLabel;
  final String interviewType;
  final String officeName;
  final String officeAddress;
  final int? initialInterviewId;

  const InterviewSchedulePage({
    super.key,
    this.role = "React Developer",
    this.company = "TCS Pvt. Ltd.",
    this.logoText = "T",
    this.logoColor = const Color(0xFF1E3A8A),
    this.date = "16",
    this.month = "May 2026",
    this.time = "11:00 AM",
    this.daysLeftLabel = "4 Days left",
    this.interviewType = "Video",
    this.officeName = "TCS Banyan Park Office",
    this.officeAddress = "Andheri East, Mumbai",
    this.initialInterviewId,
  });

  @override
  State<InterviewSchedulePage> createState() => _InterviewSchedulePageState();
}

class _InterviewSchedulePageState extends State<InterviewSchedulePage> {
  final JobInterviewService _interviewService = JobInterviewService();

  // ── TAB STATE ──
  int _selectedTab = 0; // 0: Upcoming, 1: Completed, 2: Cancelled, 3: Reschedule requested
  final List<String> _tabs = [
    "Upcoming",
    "Completed",
    "Cancelled",
    "Reschedule requested"
  ];

  int _activeInterviewIdx = 0;

  // ── REAL BACKEND DATA STATE ──
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _interviews = [];
  bool _isSubmittingResponse = false;

  @override
  void initState() {
    super.initState();
    _fetchInterviews();
  }

  Future<void> _fetchInterviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _interviewService.getMyInterviews();
      if (!mounted) return;

      setState(() {
        _interviews = list.map((m) => _modelToMap(m)).toList();
        _isLoading = false;
        if (widget.initialInterviewId != null) {
          final foundIdx = _interviews.indexWhere(
            (it) => it["id"] == widget.initialInterviewId,
          );
          if (foundIdx != -1) {
            _activeInterviewIdx = foundIdx;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _modelToMap(JobInterviewModel m) {
    String tabStatus = "Upcoming";
    if (m.isCompleted) {
      tabStatus = "Completed";
    } else if (m.isCancelled) {
      tabStatus = "Cancelled";
    } else if (m.interviewStatus == 'rescheduled') {
      tabStatus = "Reschedule requested";
    } else {
      tabStatus = "Upcoming";
    }

    return {
      "id": m.id,
      "application_id": m.applicationId,
      "role": m.jobTitle,
      "company": m.companyName,
      "logoText": m.logoText,
      "logoColor": m.logoColor,
      "date": m.formattedDay,
      "month": m.formattedMonthYear,
      "time": m.formattedTime,
      "daysLeftLabel": m.daysLeftLabel,
      "interviewType": m.displayMode,
      "interviewMode": m.interviewMode,
      "interviewer": m.displayInterviewer,
      "officeName": m.displayOfficeName,
      "officeAddress": m.displayOfficeAddress,
      "meetingLink": m.interviewLink ?? "",
      "instructions": (m.interviewRemark != null && m.interviewRemark!.trim().isNotEmpty)
          ? m.interviewRemark!.trim()
          : "Please be ready 5 minutes before scheduled time with relevant documents.",
      "documents": const ["Degree Certificate", "Resume PDF", "Identity Proof"],
      "status": tabStatus,
      "response_status": m.responseStatus,
      "candidate_response_remark": m.candidateResponseRemark,
      "outcome": m.outcome,
      "cancellationReason": m.interviewRemark,
      "rawModel": m,
    };
  }

  // ── CANDIDATE ACCEPT / REJECT HANDLER ──
  Future<void> _handleRespond(
    Map<String, dynamic> item,
    String responseStatus, [
    String? remark,
  ]) async {
    final int? id = item["id"] as int?;
    if (id == null || id <= 0) return;

    setState(() => _isSubmittingResponse = true);
    try {
      await _interviewService.respondToInterview(
        interviewId: id,
        responseStatus: responseStatus,
        remark: remark,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            responseStatus == 'accepted'
                ? "Interview accepted successfully!"
                : "Interview invitation rejected.",
          ),
          backgroundColor:
              responseStatus == 'accepted' ? Colors.green[600] : Colors.red,
        ),
      );
      await _fetchInterviews();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update response: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmittingResponse = false);
    }
  }

  void _showRejectDialog(Map<String, dynamic> item) {
    final controller = TextEditingController(text: "Schedule conflict");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Reject Interview Invitation",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Are you sure you want to decline this interview invitation?",
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "Reason (optional)",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                _handleRespond(item, 'rejected', controller.text.trim());
              },
              child: const Text("Confirm Reject"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentFilter = _tabs[_selectedTab];
    final List<Map<String, dynamic>> filteredList = _interviews.where((item) {
      return item["status"].toString().toLowerCase() ==
          currentFilter.toLowerCase();
    }).toList();

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
          "Interview Desk",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInterviews,
        color: AppColors.primary,
        child: Column(
          children: [
            // ── HORIZONTAL CATEGORIES BAR ──
            Container(
              color: AppColors.background,
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final tab = _tabs[idx];
                  final isSelected = _selectedTab == idx;
                  return ChoiceChip(
                    label: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.scaffoldBackground,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedTab = idx;
                          _activeInterviewIdx = 0;
                        });
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // ── MAIN CONTENT AREA ──
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : (_errorMessage != null && _interviews.isEmpty)
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    size: 40, color: Colors.red),
                                const SizedBox(height: 10),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 13, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _fetchInterviews,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                  child: const Text("Retry",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : filteredList.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.45,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.event_note_rounded,
                                            size: 48,
                                            color: Colors.grey.withOpacity(0.5)),
                                        const SizedBox(height: 12),
                                        Text(
                                          "No ${currentFilter.toLowerCase()} interviews found.",
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          "Pull down to check for new invitations",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textHint,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics()),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              children: [
                                if (filteredList.length > 1) ...[
                                  const Text(
                                    "Select Interview:",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    height: 80,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: filteredList.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(width: 10),
                                      itemBuilder: (context, idx) {
                                        final item = filteredList[idx];
                                        final isSelected =
                                            _activeInterviewIdx == idx;
                                        return InkWell(
                                          onTap: () => setState(
                                              () => _activeInterviewIdx = idx),
                                          child: Container(
                                            width: 160,
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary
                                                      .withOpacity(0.08)
                                                  : AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.border,
                                                width: 1.2,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor:
                                                      item["logoColor"] as Color,
                                                  child: Text(
                                                    item["logoText"] as String,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        item["role"] as String,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 11.5,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        item["company"] as String,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 9.5,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],

                                _buildInterviewDetailView(filteredList[
                                    _activeInterviewIdx >= filteredList.length
                                        ? 0
                                        : _activeInterviewIdx]),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // ── DETAILS VIEW LAYOUT ──
  Widget _buildInterviewDetailView(Map<String, dynamic> item) {
    final String type = item["interviewType"] as String;
    final String role = item["role"] as String;
    final String company = item["company"] as String;
    final String responseStatus =
        (item["response_status"] ?? "pending").toString().toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── MAIN INTERVIEW CARD ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${item["status"]} Interview",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: item["status"] == "Cancelled"
                          ? Colors.red
                          : AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title Row
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item["logoColor"] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        item["logoText"] as String,
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
                          role,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          company,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Date/Time Boxes
              Row(
                children: [
                  Expanded(
                    child: _infoBox(
                      icon: Icons.calendar_today_rounded,
                      mainText: item["date"] as String,
                      subText: item["month"] as String,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoBox(
                      icon: Icons.access_time_filled_rounded,
                      mainText: item["time"] as String,
                      subText: item["daysLeftLabel"] as String,
                    ),
                  ),
                ],
              ),

              if (item["status"] == "Cancelled") ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Reason: ${item["cancellationReason"] ?? "Cancelled by employer"}",
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Specifications
              _detailRow(Icons.person_pin_rounded, "Interviewer Name",
                  item["interviewer"] as String),
              const SizedBox(height: 10),

              // Offline Venue & Address (Only if NOT online)
              if (item["interviewMode"] != "online") ...[
                _detailRow(Icons.place_rounded, "Location / Office Venue",
                    item["officeName"] as String),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    item["officeAddress"] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Online Meeting Link (Only if online)
              if (item["interviewMode"] == "online" &&
                  (item["meetingLink"] as String).isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.link_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final link = (item["meetingLink"] as String).trim();
                          final uri = Uri.tryParse(link);
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87),
                            children: [
                              const TextSpan(
                                text: "Meeting Join Link: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: item["meetingLink"] as String,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── MANDATORY ACCEPT / REJECT WORKFLOW (STEP 6) ──
        if (responseStatus == "pending" && item["status"] != "Cancelled") ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Row(
              children: const [
                Icon(Icons.pending_actions_rounded,
                    color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Please respond to this interview invitation to confirm your availability.",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSubmittingResponse
                      ? null
                      : () => _handleRespond(
                            item,
                            "accepted",
                            "Accepted by candidate",
                          ),
                  icon: _isSubmittingResponse
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 18),
                  label: const Text(
                    "Accept",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSubmittingResponse
                      ? null
                      : () => _showRejectDialog(item),
                  icon: const Icon(Icons.cancel_rounded,
                      color: Colors.red, size: 18),
                  label: const Text(
                    "Reject",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        if (responseStatus == "accepted") ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Interview Accepted — You have confirmed attendance",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (responseStatus == "rejected") ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.cancel_rounded, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Interview Invitation Declined",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── DOCUMENTS REQUIRED PANEL ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Documents Required to Carry",
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (item["documents"] as List<String>).map((doc) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.otpBoxBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.file_present_rounded,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          doc,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Text(
                "Instructions:",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item["instructions"] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 20),

        // ── ACTIVE INTERVIEW ACTIONS ──
        if (item["status"] != "Cancelled") ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _onCancelPressed(item),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Cancel Interview",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _onReschedulePressed(item),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side:
                        const BorderSide(color: AppColors.primary, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Reschedule",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _onPrimaryActionPressed(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _getActionButtonLabelForType(type),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── OTHER GLOBAL ACTIONS ──
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RecommendedJobPage()),
                  );
                },
                icon: const Icon(Icons.work_outline_rounded,
                    size: 16, color: AppColors.textSecondary),
                label: const Text(
                  "View Other Jobs",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CalendarPage()),
                  );
                },
                icon: const Icon(Icons.calendar_month_outlined,
                    size: 16, color: AppColors.textSecondary),
                label: const Text(
                  "Add to Calendar",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ── REMINDER CUSTOM TILE BUILDER ──

  // ── HELPER UI BUILDERS ──
  Widget _infoBox({
    required IconData icon,
    required String mainText,
    required String subText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.otpBoxBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            mainText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subText,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              children: [
                TextSpan(
                  text: "$title: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: val),
              ],
            ),
          ),
        )
      ],
    );
  }

  String _getActionButtonLabelForType(String type) {
    if (type.toLowerCase().contains("video") || type.toLowerCase().contains("online")) {
      return "Join Video Interview";
    }
    if (type.toLowerCase().contains("phone")) return "Start Phone Interview";
    return "Get Directions to Office";
  }

  void _onCancelPressed(Map<String, dynamic> item) {
    final int? id = item["id"] as int?;
    if (id == null || id <= 0) return;

    String selectedReason = "Conflict with other interview schedule";
    bool isCancelling = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Cancel Interview Slot"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Are you sure you want to cancel? Please select a cancellation reason:",
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    decoration: const InputDecoration(labelText: "Reason"),
                    items: const [
                      DropdownMenuItem(
                        value: "Conflict with other interview schedule",
                        child: Text("Timing Conflict"),
                      ),
                      DropdownMenuItem(
                        value: "Found another job offer",
                        child: Text("Got another job"),
                      ),
                      DropdownMenuItem(
                        value: "Location is too far away",
                        child: Text("Distance Issue"),
                      ),
                      DropdownMenuItem(
                        value: "Emergency personal health issues",
                        child: Text("Personal Reason"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedReason = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isCancelling ? null : () => Navigator.pop(context),
                  child: const Text("Keep Slot"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isCancelling
                      ? null
                      : () async {
                          setDialogState(() => isCancelling = true);
                          try {
                            await _interviewService.cancelInterview(
                              interviewId: id,
                              reason: selectedReason,
                            );
                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Interview canceled successfully."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            await _fetchInterviews();
                          } catch (e) {
                            setDialogState(() => isCancelling = false);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to cancel interview: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isCancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Confirm Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onReschedulePressed(Map<String, dynamic> item) {
    final int? id = item["id"] as int?;
    if (id == null || id <= 0) return;

    DateTime proposedDate = DateTime.now().add(const Duration(days: 2));
    TimeOfDay proposedTime = const TimeOfDay(hour: 14, minute: 0);
    final reasonController = TextEditingController(text: "Timing conflict with another schedule");
    bool isRescheduling = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dateStr = "${proposedDate.year}-${proposedDate.month.toString().padLeft(2, '0')}-${proposedDate.day.toString().padLeft(2, '0')}";
            final hour = proposedTime.hour.toString().padLeft(2, '0');
            final minute = proposedTime.minute.toString().padLeft(2, '0');
            final timeStr = "$hour:$minute";

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Request Reschedule"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select proposed new date and time:"),
                    const SizedBox(height: 14),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                      title: const Text("Proposed Date", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      trailing: const Icon(Icons.edit_calendar_rounded, size: 20),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: proposedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 60)),
                        );
                        if (picked != null) {
                          setDialogState(() => proposedDate = picked);
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time_rounded, color: AppColors.primary),
                      title: const Text("Proposed Time", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      trailing: const Icon(Icons.arrow_drop_down, size: 24),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: proposedTime,
                        );
                        if (picked != null) {
                          setDialogState(() => proposedTime = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: "Reason for Reschedule",
                        hintText: "e.g. Health issue, exam, travel",
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isRescheduling ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isRescheduling
                      ? null
                      : () async {
                          setDialogState(() => isRescheduling = true);
                          try {
                            await _interviewService.rescheduleInterview(
                              interviewId: id,
                              proposedDate: dateStr,
                              proposedTime: timeStr,
                              remark: reasonController.text.trim(),
                              interviewMode: item["interviewMode"] as String? ?? 'offline',
                              venue: (item["officeAddress"] ?? item["officeName"] ?? 'Office Venue').toString(),
                              meetingLink: (item["meetingLink"] ?? '').toString(),
                            );
                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Reschedule requested successfully!"),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                            await _fetchInterviews();
                          } catch (e) {
                            setDialogState(() => isRescheduling = false);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to reschedule: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isRescheduling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Submit Reschedule"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onPrimaryActionPressed(Map<String, dynamic> item) async {
    final String type = item["interviewType"] as String;
    final String link = (item["meetingLink"] as String? ?? "").trim();

    if (type.toLowerCase().contains("video") ||
        item["interviewMode"] == "online") {
      if (link.startsWith("http://") || link.startsWith("https://")) {
        final uri = Uri.tryParse(link);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _VideoInterviewSimulatorView(
            role: item["role"] as String,
            company: item["company"] as String,
          ),
        ),
      );
    } else if (type.toLowerCase().contains("phone")) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Simulating Call Verification"),
          content: Text(
              "Dialing recruiter desk:\n${item["interviewer"]}\nCall link activated."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("End Call")),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("In-person GPS Directions"),
          content: Text(
              "Office: ${item["officeName"]}\nAddress: ${item["officeAddress"]}"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text("Opening navigation path on Map view...")),
                );
              },
              child: const Text("Start Route Navigation"),
            ),
          ],
        ),
      );
    }
  }
}

// ── VIDEO INTERVIEW SIMULATOR ──
class _VideoInterviewSimulatorView extends StatefulWidget {
  final String role;
  final String company;

  const _VideoInterviewSimulatorView(
      {required this.role, required this.company});

  @override
  State<_VideoInterviewSimulatorView> createState() =>
      _VideoInterviewSimulatorViewState();
}

class _VideoInterviewSimulatorViewState
    extends State<_VideoInterviewSimulatorView> {
  bool _micOn = true;
  bool _cameraOn = true;
  bool _frontCamera = true;
  bool _speakerOn = true;
  bool _aiAssistOn = true;
  bool _isJoined = false;

  int _confidenceScore = 85;
  String _sentiment = "Calm";
  String _speakingPace = "Normal";

  Timer? _timer;
  int _secondsElapsed = 0;

  final List<String> _sentiments = [
    "Calm",
    "Confident",
    "Articulate",
    "Thoughtful",
    "Stressing slightly"
  ];
  final List<String> _paces = [
    "Normal",
    "Engaging",
    "Slightly Fast",
    "Thoughtful Pause",
    "Optimal"
  ];

  void _startMeeting() {
    setState(() {
      _isJoined = true;
      _secondsElapsed = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
        if (_secondsElapsed % 4 == 0) {
          _confidenceScore = 80 + (_secondsElapsed % 19);
          _sentiment =
              _sentiments[(_secondsElapsed ~/ 4) % _sentiments.length];
          _speakingPace = _paces[(_secondsElapsed ~/ 3) % _paces.length];
        }
      });
    });
  }

  void _endMeeting() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: const [
              Icon(Icons.analytics_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text("AI Automated Summary",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Mock Session Summary Report:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                _summaryRow("Overall Confidence:", "$_confidenceScore%"),
                _summaryRow("Dominant Sentiment:", _sentiment),
                _summaryRow("Speaking Pace:", _speakingPace),
                _summaryRow("Recording State:", "Saved in Profile Archive"),
                const Divider(),
                const Text("Key Strengths:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.green)),
                const Text(
                    "• Answered state management question clearly.\n• Maintained excellent eye contact camera scan.\n• Good tone clarity control.",
                    style: TextStyle(fontSize: 11.5)),
                const SizedBox(height: 8),
                const Text("Actionable Feedback:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.orange)),
                const Text(
                    "• Speak slightly slower during background explanation.\n• Keep a brief pause after recruiter question.",
                    style: TextStyle(fontSize: 11.5)),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Finish & Save"),
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final int mins = totalSeconds ~/ 60;
    final int secs = totalSeconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _cameraOn
                  ? Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _frontCamera
                                  ? Icons.face_retouching_natural_rounded
                                  : Icons.camera_rear_rounded,
                              size: 100,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _frontCamera
                                  ? "Front Camera Active (Live View)"
                                  : "Back Camera Active (Live View)",
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: Text("Camera is turned off",
                            style: TextStyle(color: Colors.white54)),
                      ),
                    ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record_rounded,
                            color: Colors.red, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          _isJoined
                              ? "REC | ${_formatTime(_secondsElapsed)}"
                              : "REC (Ready)",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_rounded,
                            color: Colors.white, size: 13),
                        SizedBox(width: 4),
                        Text("Network: Good (32ms)",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isJoined && _aiAssistOn)
              Positioned(
                top: 70,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.blue.withOpacity(0.4), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt_rounded,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                              "AI Interview Speech Assist (Live Feedback)",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text("Score: $_confidenceScore%",
                              style: const TextStyle(
                                  color: Colors.lightGreenAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Speech Sentiment: $_sentiment",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                          Text("Pace: $_speakingPace",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (!_isJoined)
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Join ${widget.company} Interview",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Role: ${widget.role}",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _preJoinControl(
                            icon: _micOn
                                ? Icons.mic_rounded
                                : Icons.mic_off_rounded,
                            active: _micOn,
                            onTap: () => setState(() => _micOn = !_micOn),
                          ),
                          _preJoinControl(
                            icon: _cameraOn
                                ? Icons.videocam_rounded
                                : Icons.videocam_off_rounded,
                            active: _cameraOn,
                            onTap: () =>
                                setState(() => _cameraOn = !_cameraOn),
                          ),
                          _preJoinControl(
                            icon: _speakerOn
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            active: _speakerOn,
                            onTap: () =>
                                setState(() => _speakerOn = !_speakerOn),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _startMeeting,
                          child: const Text("Join Meeting Room",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                ),
              )
            else
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        InkWell(
                          onTap: () =>
                              setState(() => _aiAssistOn = !_aiAssistOn),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _aiAssistOn
                                  ? Colors.blue.withOpacity(0.8)
                                  : Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.bolt_rounded,
                                    color: Colors.white, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  _aiAssistOn
                                      ? "AI Assist On"
                                      : "AI Assist Off",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _meetControlBtn(
                            icon: _micOn
                                ? Icons.mic_rounded
                                : Icons.mic_off_rounded,
                            active: _micOn,
                            onTap: () => setState(() => _micOn = !_micOn),
                          ),
                          _meetControlBtn(
                            icon: _cameraOn
                                ? Icons.videocam_rounded
                                : Icons.videocam_off_rounded,
                            active: _cameraOn,
                            onTap: () =>
                                setState(() => _cameraOn = !_cameraOn),
                          ),
                          _meetControlBtn(
                            icon: Icons.flip_camera_ios_rounded,
                            active: _frontCamera,
                            onTap: () =>
                                setState(() => _frontCamera = !_frontCamera),
                          ),
                          _meetControlBtn(
                            icon: _speakerOn
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            active: _speakerOn,
                            onTap: () =>
                                setState(() => _speakerOn = !_speakerOn),
                          ),
                          _meetControlBtn(
                            icon: Icons.call_end_rounded,
                            active: false,
                            btnColor: Colors.red,
                            onTap: _endMeeting,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _preJoinControl(
      {required IconData icon, required bool active, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: active ? AppColors.primary : Colors.transparent),
        ),
        child: Icon(icon,
            color: active ? AppColors.primary : Colors.white70, size: 22),
      ),
    );
  }

  Widget _meetControlBtn(
      {required IconData icon,
      required bool active,
      required VoidCallback onTap,
      Color? btnColor}) {
    final Color background =
        btnColor ?? (active ? Colors.white : Colors.white12);
    final Color tint =
        btnColor != null ? Colors.white : (active ? Colors.black87 : Colors.white);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: tint, size: 20),
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}
