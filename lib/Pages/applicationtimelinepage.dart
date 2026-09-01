import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/interviewschedulepage.dart';
import '../utils/app_colors.dart';
class ApplicationTimelinePage extends StatelessWidget {
  final String title;
  final String company;
  final String logoText;
  final Color logoColor;
  final String appliedOn;
  final String status;
  final Color statusColor;

  const ApplicationTimelinePage({
    super.key,
    required this.title,
    required this.company,
    required this.logoText,
    required this.logoColor,
    required this.appliedOn,
    required this.status,
    required this.statusColor,
  });

  List<Map<String, dynamic>> get _stages {
    const allStages = [
      "Applied",
      "Under Review",
      "Shortlisted",
      "Interview Scheduled",
      "Result",
    ];

    int currentIndex = allStages.indexOf(status);
    if (currentIndex == -1) currentIndex = 0;

    return List.generate(allStages.length, (index) {
      return {
        "label": allStages[index],
        "isCompleted": index < currentIndex,
        "isCurrent": index == currentIndex,
      };
    });
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
      body: ListView(
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
                    color: logoColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      logoText,
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
                        title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
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
                      const SizedBox(height: 6),
                      Text(
                        "Applied on $appliedOn",
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
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

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

    // 👇 "Interview Scheduled" stage वर click करता येईल
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

    // 👇 GestureDetector इथे add केलंय
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InterviewSchedulePage(),
          ),
        );
      },
      child: tileContent,
    );
  }
}