import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class TimeManagementPage extends StatefulWidget {
  const TimeManagementPage({super.key});

  @override
  State<TimeManagementPage> createState() => _TimeManagementPageState();
}

class _TimeManagementPageState extends State<TimeManagementPage> {
  // ── TODAY'S SCHEDULE ──────────────────────────────────
  final schedule = [
    {
      "time": "9:00 AM",
      "task": "Morning Shift - Delivery",
      "status": "done",
      "icon": Icons.delivery_dining_rounded,
    },
    {
      "time": "1:00 PM",
      "task": "Lunch Break",
      "status": "done",
      "icon": Icons.restaurant_rounded,
    },
    {
      "time": "3:00 PM",
      "task": "Job Interview - Reliance Digital",
      "status": "upcoming",
      "icon": Icons.groups_rounded,
    },
    {
      "time": "6:00 PM",
      "task": "Skill Course - Excel Basics",
      "status": "upcoming",
      "icon": Icons.school_rounded,
    },
    {
      "time": "8:00 PM",
      "task": "Evening Delivery Shift",
      "status": "pending",
      "icon": Icons.two_wheeler_rounded,
    },
  ];

  // ── TIME MANAGEMENT TIPS ──────────────────────────────
  final tips = [
    {
      "title": "Plan your shifts a day early",
      "icon": Icons.event_note_rounded,
    },
    {
      "title": "Block focus time for skill learning",
      "icon": Icons.psychology_rounded,
    },
    {
      "title": "Track hours to avoid burnout",
      "icon": Icons.timer_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final doneCount = schedule.where((s) => s["status"] == "done").length;

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
          "Time Management",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── OVERVIEW BANNER ────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.mainGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$doneCount of ${schedule.length} tasks completed today",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Stay on track with your daily plan",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ── TODAY'S SCHEDULE HEADER ────────────────────
            const Text(
              "Today's Schedule",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 14),

            // ── SCHEDULE TIMELINE ──────────────────────────
            ...List.generate(schedule.length, (index) {
              final item = schedule[index];
              final isLast = index == schedule.length - 1;
              return _scheduleTile(
                time: item["time"] as String,
                task: item["task"] as String,
                status: item["status"] as String,
                icon: item["icon"] as IconData,
                isLast: isLast,
              );
            }),

            const SizedBox(height: 22),

            // ── TIPS HEADER ─────────────────────────────────
            const Text(
              "Time Management Tips",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 14),

            // ── TIPS LIST ───────────────────────────────────
            ...tips.map((tip) => _tipCard(
                  title: tip["title"] as String,
                  icon: tip["icon"] as IconData,
                )),
          ],
        ),
      ),
    );
  }

  // ── SCHEDULE TILE HELPER (timeline style) ───────────────
  Widget _scheduleTile({
    required String time,
    required String task,
    required String status,
    required IconData icon,
    required bool isLast,
  }) {
    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case "done":
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case "upcoming":
        statusColor = AppColors.primary;
        statusIcon = Icons.radio_button_checked_rounded;
        break;
      default:
        statusColor = AppColors.textHint;
        statusIcon = Icons.radio_button_unchecked_rounded;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + connector line
          Column(
            children: [
              Icon(statusIcon, color: statusColor, size: 18),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.divider,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Task card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TIP CARD HELPER ──────────────────────────────────────
  Widget _tipCard({required String title, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}