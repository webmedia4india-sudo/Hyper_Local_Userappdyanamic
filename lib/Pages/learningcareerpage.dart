import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/communicationpage.dart';
import 'package:hyper_local/Pages/interviewskillspage .dart';
import 'package:hyper_local/Pages/mockinterviewpage.dart';
import 'package:hyper_local/Pages/timemanagementpage.dart';
import '../utils/app_colors.dart';

class LearningCareerPage extends StatelessWidget {
  final String userName;
  final double featuredProgress; // 0.0 to 1.0
  final List<Map<String, dynamic>> popularCourses;

  const LearningCareerPage({
    super.key,
    this.userName = "Rahul",
    this.featuredProgress = 0.65,
    this.popularCourses = const [
      {
        "icon": Icons.record_voice_over_rounded,
        "iconBg": Color(0xFFE3F2FD),
        "iconColor": AppColors.primary,
        "title": "Interview Skills",
      },
      {
        "icon": Icons.psychology_alt_rounded,
        "iconBg": Color(0xFFFFF3E0),
        "iconColor": AppColors.warning,
        "title": "Mock Interview",
      },
      {
        "icon": Icons.chat_bubble_rounded,
        "iconBg": Color(0xFFE8F5E9),
        "iconColor": AppColors.success,
        "title": "Communication",
      },
      {
        "icon": Icons.access_time_filled_rounded,
        "iconBg": Color(0xFFF3E5F5),
        "iconColor": Color(0xFF9C27B0),
        "title": "Time Management",
      },
    ],
  });

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
          "Learning Home",
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
          // ── GREETING ────────────────────
          Text(
            "Hello $userName,",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "What do you want to learn today?",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          // ── FEATURED COURSE CARD ────────────────────
          Container(
            padding: const EdgeInsets.all(14),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Career Learning",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Resume Writing",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: featuredProgress,
                                minHeight: 6,
                                backgroundColor: AppColors.divider,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${(featuredProgress * 100).toInt()}%",
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── POPULAR COURSES HEADER ────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Popular Courses",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "View all",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── COURSE LIST ────────────────────
          ...List.generate(popularCourses.length, (index) {
            final course = popularCourses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _courseTile(context, course),
            );
          }),
        ],
      ),
    );
  }

  // ── SINGLE COURSE ROW ────────────────────
  Widget _courseTile(BuildContext context, Map<String, dynamic> course) {
    final String title = course["title"] as String;

    final Widget tileContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: course["iconBg"] as Color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              course["icon"] as IconData,
              size: 18,
              color: course["iconColor"] as Color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );

    // 👇 title नुसार योग्य page वर navigate होईल
    Widget? destinationPage;
    if (title == "Mock Interview") {
      destinationPage = const MockInterviewPage();
    } else if (title == "Interview Skills") {
      destinationPage = const InterviewSkillsPage();
    }
    else if (title == "Communication") {
      destinationPage = const CommunicationPage();
    }
    else if (title == "Time Management") {
      destinationPage = const TimeManagementPage();
    }

    if (destinationPage == null) return tileContent;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => destinationPage!,
          ),
        );
      },
      child: tileContent,
    );
  }
}