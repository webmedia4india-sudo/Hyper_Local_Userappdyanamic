
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hyper_local/utils/app_colors.dart';
import 'package:hyper_local/Pages/calendarpage.dart' hide AppColors;
import 'package:hyper_local/Pages/recommendedjpbpage.dart';

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
  });

  @override
  State<InterviewSchedulePage> createState() => _InterviewSchedulePageState();
}

class _InterviewSchedulePageState extends State<InterviewSchedulePage> {
  // ── TAB STATE ──
  int _selectedTab = 0; // 0: Upcoming, 1: Completed, 2: Cancelled, 3: Reschedule requested
  final List<String> _tabs = [
    "Upcoming",
    "Completed",
    "Cancelled",
    "Reschedule requested"
  ];

  int _activeInterviewIdx = 0;

  // ── REMINDERS CONFIG TIMINGS ──
  bool _remind24h = true;
  double _remind24hVal = 24.0; // Hours
  bool _remind2h = true;
  double _remind2hVal = 2.0; // Hours
  bool _remind30m = true;
  double _remind30mVal = 30.0; // Minutes

  // ── PREPARATION CHECKLIST ──
  final List<bool> _checklistChecked = [false, false, false];

  // ── MOCK DATA LIST FOR ALL SPECIFIED IT COMPANY TYPES ──
  late final List<Map<String, dynamic>> _interviews = [
    {
      "role": "React Developer",
      "company": "TCS Pvt. Ltd.",
      "logoText": "T",
      "logoColor": const Color(0xFF1E3A8A),
      "date": "16",
      "month": "May 2026",
      "time": "11:00 AM",
      "daysLeftLabel": "4 Days left",
      "interviewType": "Video",
      "interviewer": "Rahul Sharma (Tech Lead)",
      "officeName": "TCS Banyan Park Hub",
      "officeAddress": "Andheri East, Mumbai",
      "meetingLink": "https://meet.hyperlocal.jobs/tcs-react-assessment-392",
      "instructions": "Ensure you are in a quiet room with strong WiFi. Keep your camera turned on throughout the assessment.",
      "documents": ["Degree Certificate", "Resume PDF", "Aadhar Card"],
      "status": "Upcoming",
    },
    {
      "role": "Flutter Developer",
      "company": "Wipro Technologies",
      "logoText": "W",
      "logoColor": const Color(0xFF6D28D9),
      "date": "10",
      "month": "May 2026",
      "time": "02:00 PM",
      "daysLeftLabel": "Completed",
      "interviewType": "Phone",
      "interviewer": "Sneha Gupta (HR Manager)",
      "officeName": "Wipro Development Center",
      "officeAddress": "Vikhroli West, Mumbai",
      "meetingLink": "Telephonic Coding Round Verification",
      "instructions": "Be ready to answer questions about state management, hooks, and lifecycle events.",
      "documents": ["Experience Letter", "Resume PDF"],
      "status": "Completed",
    },
    {
      "role": "Software QA Engineer",
      "company": "Cognizant Solutions",
      "logoText": "C",
      "logoColor": const Color(0xFF3B82F6),
      "date": "08",
      "month": "May 2026",
      "time": "11:30 AM",
      "daysLeftLabel": "Cancelled",
      "interviewType": "In-person",
      "interviewer": "Amit Desai (Senior QA Analyst)",
      "officeName": "Cognizant Technology Hub",
      "officeAddress": "Kanjurmarg West, Mumbai",
      "meetingLink": "Physical Verification Venue",
      "instructions": "Report at the reception desk 15 minutes before the slot.",
      "documents": ["Identity Card", "Degree Certificates"],
      "status": "Cancelled",
      "cancellationReason": "Position filled internally by WFH candidate desk.",
    },
    {
      "role": "UI/UX Designer",
      "company": "Zoho Corporation",
      "logoText": "Z",
      "logoColor": const Color(0xFFE11D48),
      "date": "20",
      "month": "May 2026",
      "time": "10:00 AM",
      "daysLeftLabel": "Reschedule requested",
      "interviewType": "Walk-in",
      "interviewer": "Karan Malhotra (Lead Designer)",
      "officeName": "Zoho Estancia Office",
      "officeAddress": "Ghatkopar East, Mumbai",
      "meetingLink": "Physical Design Studio Spot",
      "instructions": "Report with your digital portfolio presentation slides.",
      "documents": ["Adhar Card", "Portfolio Copy", "Resume"],
      "status": "Reschedule requested",
    }
  ];

  @override
  Widget build(BuildContext context) {
    final String currentFilter = _tabs[_selectedTab];
    final List<Map<String, dynamic>> filteredList = _interviews.where((item) {
      return item["status"].toString().toLowerCase() == currentFilter.toLowerCase();
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
      body: Column(
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

          // ── MAIN CONTENT LIST/DETAIL AREA ──
          Expanded(
            child: filteredList.isEmpty
                ? const Center(
                    child: Text(
                      "No interviews match this category.",
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  )
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      if (filteredList.length > 1) ...[
                        const Text("Select Interview:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredList.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 10),
                            itemBuilder: (context, idx) {
                              final item = filteredList[idx];
                              final isSelected = _activeInterviewIdx == idx;
                              return InkWell(
                                onTap: () => setState(() => _activeInterviewIdx = idx),
                                child: Container(
                                  width: 160,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 1.2),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: item["logoColor"],
                                        child: Text(item["logoText"], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(item["role"], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                            Text(item["company"], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      _buildInterviewDetailView(filteredList[_activeInterviewIdx >= filteredList.length ? 0 : _activeInterviewIdx]),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // Details view layout
  Widget _buildInterviewDetailView(Map<String, dynamic> item) {
    final String type = item["interviewType"] as String;
    final String role = item["role"] as String;
    final String company = item["company"] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── UPCOMING INTERVIEW CARD ────────────────────
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
              )
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
                      color: item["status"] == "Cancelled" ? Colors.red : AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  )
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
                      const Icon(Icons.info_outline_rounded, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Reason: ${item["cancellationReason"] ?? "N/A"}",
                          style: const TextStyle(fontSize: 11.5, color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Specifications
              _detailRow(Icons.person_pin_rounded, "Interviewer Name", item["interviewer"] as String),
              const SizedBox(height: 10),
              _detailRow(Icons.place_rounded, "Location / Office Venue", item["officeName"] as String),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(item["officeAddress"] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              const SizedBox(height: 10),
              _detailRow(Icons.link_rounded, "Meeting Join Link", item["meetingLink"] as String),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── CONFIGURABLE NOTIFICATIONS PANEL ──
        Container(
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
                "Configurable Notification Reminders",
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              
              // 24 Hours Alert
              _reminderSliderTile(
                label: "Pre-Interview Reminder",
                enabled: _remind24h,
                val: _remind24hVal,
                minVal: 1,
                maxVal: 48,
                unit: "hours",
                onSwitchChanged: (val) => setState(() => _remind24h = val),
                onSliderChanged: (val) => setState(() => _remind24hVal = val),
              ),
              const Divider(height: 18),

              // 2 Hours Alert
              _reminderSliderTile(
                label: "Departure Travel Reminder",
                enabled: _remind2h,
                val: _remind2hVal,
                minVal: 1,
                maxVal: 12,
                unit: "hours",
                onSwitchChanged: (val) => setState(() => _remind2h = val),
                onSliderChanged: (val) => setState(() => _remind2hVal = val),
              ),
              const Divider(height: 18),

              // 30 Minutes Alert
              _reminderSliderTile(
                label: "Immediate Setup Reminder",
                enabled: _remind30m,
                val: _remind30mVal,
                minVal: 5,
                maxVal: 90,
                unit: "minutes",
                onSwitchChanged: (val) => setState(() => _remind30m = val),
                onSliderChanged: (val) => setState(() => _remind30mVal = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

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
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (item["documents"] as List<String>).map((doc) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.otpBoxBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.file_present_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(doc, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Text(
                "Instructions:",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                item["instructions"] as String,
                style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.35),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── PREPARATION CHECKLIST ──
        Container(
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
                "Preparations Checklist",
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              ...List.generate(_checklistChecked.length, (idx) {
                final List<String> checklistText = [
                  "Checked stable internet connection or office address directions",
                  "Prepared physical/digital copy of all required documents",
                  "Ensured clean formal dress code alignment",
                ];
                return CheckboxListTile(
                  value: _checklistChecked[idx],
                  title: Text(
                    checklistText[idx],
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _checklistChecked[idx] ? Colors.grey : AppColors.textPrimary,
                      decoration: _checklistChecked[idx] ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _checklistChecked[idx] = val ?? false;
                    });
                  },
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── RECRUITER CONTACT CARD ──
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: const Text("HR", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Priya Sharma", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 2),
                    Text("Interview Coordinator Desk", style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call_rounded, color: Colors.green, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Calling hiring officer Priya Sharma...")),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Opening chat dialog conversation room...")),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Cancel Interview", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13.5)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _onReschedulePressed(item),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Reschedule", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13.5)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                _getActionButtonLabelForType(type),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                    MaterialPageRoute(builder: (context) => const RecommendedJobPage()),
                  );
                },
                icon: const Icon(Icons.work_outline_rounded, size: 16, color: AppColors.textSecondary),
                label: const Text("View Other Jobs", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalendarPage()),
                  );
                },
                icon: const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.textSecondary),
                label: const Text("Add to Calendar", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  Widget _reminderSliderTile({
    required String label,
    required bool enabled,
    required double val,
    required double minVal,
    required double maxVal,
    required String unit,
    required ValueChanged<bool> onSwitchChanged,
    required ValueChanged<double> onSliderChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Switch(
              value: enabled,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
              onChanged: onSwitchChanged,
            ),
          ],
        ),
        if (enabled) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: val,
                  min: minVal,
                  max: maxVal,
                  activeColor: AppColors.primary,
                  inactiveColor: Colors.grey[300],
                  onChanged: onSliderChanged,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 76,
                alignment: Alignment.centerRight,
                child: Text(
                  "${val.toInt()} $unit",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }

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
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
                TextSpan(text: "$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: val),
              ],
            ),
          ),
        )
      ],
    );
  }

  String _getActionButtonLabelForType(String type) {
    if (type.toLowerCase() == "video") return "Join Video Interview";
    if (type.toLowerCase() == "phone") return "Start Phone Interview";
    return "Get Directions to Office";
  }

  void _onCancelPressed(Map<String, dynamic> item) {
    String selectedReason = "Conflict with other interview schedule";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Cancel InterviewSlot"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Are you sure you want to cancel? Please select a cancellation reason:"),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: selectedReason,
                decoration: const InputDecoration(labelText: "Reason"),
                items: const [
                  DropdownMenuItem(value: "Conflict with other interview schedule", child: Text("Timing Conflict")),
                  DropdownMenuItem(value: "Found another job offer", child: Text("Got another job")),
                  DropdownMenuItem(value: "Location is too far away", child: Text("Distance Issue")),
                  DropdownMenuItem(value: "Emergency personal health issues", child: Text("Personal Reason")),
                ],
                onChanged: (val) {
                  if (val != null) selectedReason = val;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Keep Slot"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  item["status"] = "Cancelled";
                  item["cancellationReason"] = selectedReason;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Interview canceled successfully.")),
                );
              },
              child: const Text("Confirm Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _onReschedulePressed(Map<String, dynamic> item) {
    String newDate = "18 May";
    String newTime = "02:00 PM";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Request Reschedule"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: newDate,
                decoration: const InputDecoration(labelText: "Proposed Date"),
                onChanged: (val) => newDate = val,
              ),
              TextFormField(
                initialValue: newTime,
                decoration: const InputDecoration(labelText: "Proposed Time"),
                onChanged: (val) => newTime = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  item["status"] = "Reschedule requested";
                  item["date"] = newDate;
                  item["time"] = newTime;
                  item["daysLeftLabel"] = "Reschedule Requested";
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reschedule proposal submitted.")),
                );
              },
              child: const Text("Request Reschedule"),
            ),
          ],
        );
      },
    );
  }

  void _onPrimaryActionPressed(Map<String, dynamic> item) {
    final String type = item["interviewType"] as String;
    if (type.toLowerCase() == "video") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _VideoInterviewSimulatorView(
            role: item["role"] as String,
            company: item["company"] as String,
          ),
        ),
      );
    } else if (type.toLowerCase() == "phone") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Simulating Call Verification"),
          content: Text("Dialing recruiter desk:\n${item["interviewer"]}\nCall link activated."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("End Call")),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("In-person GPS Directions"),
          content: Text("Office: ${item["officeName"]}\nAddress: ${item["officeAddress"]}"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening navigation path on Map view...")));
              },
              child: const Text("Start Route Navigation"),
            ),
          ],
        ),
      );
    }
  }
}

class _VideoInterviewSimulatorView extends StatefulWidget {
  final String role;
  final String company;

  const _VideoInterviewSimulatorView({required this.role, required this.company});

  @override
  State<_VideoInterviewSimulatorView> createState() => _VideoInterviewSimulatorViewState();
}

class _VideoInterviewSimulatorViewState extends State<_VideoInterviewSimulatorView> {
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

  final List<String> _sentiments = ["Calm", "Confident", "Articulate", "Thoughtful", "Stressing slightly"];
  final List<String> _paces = ["Normal", "Engaging", "Slightly Fast", "Thoughtful Pause", "Optimal"];

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
          _sentiment = _sentiments[(_secondsElapsed ~/ 4) % _sentiments.length];
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.analytics_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text("AI Automated Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Mock Session Summary Report:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                _summaryRow("Overall Confidence:", "$_confidenceScore%"),
                _summaryRow("Dominant Sentiment:", _sentiment),
                _summaryRow("Speaking Pace:", _speakingPace),
                _summaryRow("Recording State:", "Saved in Profile Archive"),
                const Divider(),
                const Text("Key Strengths:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                const Text("• Answered state management question clearly.\n• Maintained excellent eye contact camera scan.\n• Good tone clarity control.", style: TextStyle(fontSize: 11.5)),
                const SizedBox(height: 8),
                const Text("Actionable Feedback:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
                const Text("• Speak slightly slower during background explanation.\n• Keep a brief pause after recruiter question.", style: TextStyle(fontSize: 11.5)),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
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
                              _frontCamera ? Icons.face_retouching_natural_rounded : Icons.camera_rear_rounded,
                              size: 100,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _frontCamera ? "Front Camera Active (Live View)" : "Back Camera Active (Live View)",
                              style: const TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: Text("Camera is turned off", style: TextStyle(color: Colors.white54)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record_rounded, color: Colors.red, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          _isJoined ? "REC | ${_formatTime(_secondsElapsed)}" : "REC (Ready)",
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_rounded, color: Colors.white, size: 13),
                        SizedBox(width: 4),
                        Text("Network: Good (32ms)", style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
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
                    border: Border.all(color: Colors.blue.withOpacity(0.4), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 6),
                          const Text("AI Interview Speech Assist (Live Feedback)", style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text("Score: $_confidenceScore%", style: const TextStyle(color: Colors.lightGreenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Speech Sentiment: $_sentiment", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          Text("Pace: $_speakingPace", style: const TextStyle(color: Colors.white70, fontSize: 11)),
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
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Role: ${widget.role}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _preJoinControl(
                            icon: _micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                            active: _micOn,
                            onTap: () => setState(() => _micOn = !_micOn),
                          ),
                          _preJoinControl(
                            icon: _cameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                            active: _cameraOn,
                            onTap: () => setState(() => _cameraOn = !_cameraOn),
                          ),
                          _preJoinControl(
                            icon: _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                            active: _speakerOn,
                            onTap: () => setState(() => _speakerOn = !_speakerOn),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _startMeeting,
                          child: const Text("Join Meeting Room", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
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
                          onTap: () => setState(() => _aiAssistOn = !_aiAssistOn),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _aiAssistOn ? Colors.blue.withOpacity(0.8) : Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.bolt_rounded, color: Colors.white, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  _aiAssistOn ? "AI Assist On" : "AI Assist Off",
                                  style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _meetControlBtn(
                            icon: _micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                            active: _micOn,
                            onTap: () => setState(() => _micOn = !_micOn),
                          ),
                          _meetControlBtn(
                            icon: _cameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                            active: _cameraOn,
                            onTap: () => setState(() => _cameraOn = !_cameraOn),
                          ),
                          _meetControlBtn(
                            icon: Icons.flip_camera_ios_rounded,
                            active: _frontCamera,
                            onTap: () => setState(() => _frontCamera = !_frontCamera),
                          ),
                          _meetControlBtn(
                            icon: _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                            active: _speakerOn,
                            onTap: () => setState(() => _speakerOn = !_speakerOn),
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

  Widget _preJoinControl({required IconData icon, required bool active, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.primary : Colors.transparent),
        ),
        child: Icon(icon, color: active ? AppColors.primary : Colors.white70, size: 22),
      ),
    );
  }

  Widget _meetControlBtn({required IconData icon, required bool active, required VoidCallback onTap, Color? btnColor}) {
    final Color background = btnColor ?? (active ? Colors.white : Colors.white12);
    final Color tint = btnColor != null ? Colors.white : (active ? Colors.black87 : Colors.white);
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
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}
