import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  int _selectedFilter = 0;

  final filters = ["All", "Free", "Certificate", "In Progress"];

  // ── COURSES DATA ──────────────────────────────────────
  final courses = [
    {
      "title": "Communication Skills for Jobs",
      "provider": "Skill India",
      "duration": "2h 30m",
      "lessons": 12,
      "rating": 4.5,
      "progress": 0.6,
      "isFree": true,
      "hasCertificate": true,
      "icon": Icons.record_voice_over_rounded,
      "color": const Color(0xFF2979FF),
    },
    {
      "title": "Basic Computer & Excel",
      "provider": "NSDC",
      "duration": "4h 10m",
      "lessons": 20,
      "rating": 4.3,
      "progress": 0.25,
      "isFree": true,
      "hasCertificate": true,
      "icon": Icons.computer_rounded,
      "color": const Color(0xFF43A047),
    },
    {
      "title": "Resume Building Masterclass",
      "provider": "LearnHub",
      "duration": "1h 45m",
      "lessons": 8,
      "rating": 4.7,
      "progress": 0.0,
      "isFree": false,
      "hasCertificate": true,
      "icon": Icons.description_rounded,
      "color": const Color(0xFFFF7043),
    },
    {
      "title": "Customer Handling & Sales",
      "provider": "Skill India",
      "duration": "3h 00m",
      "lessons": 15,
      "rating": 4.2,
      "progress": 1.0,
      "isFree": true,
      "hasCertificate": false,
      "icon": Icons.support_agent_rounded,
      "color": const Color(0xFF8E24AA),
    },
    {
      "title": "Spoken English Basics",
      "provider": "British Council",
      "duration": "5h 20m",
      "lessons": 25,
      "rating": 4.6,
      "progress": 0.0,
      "isFree": false,
      "hasCertificate": true,
      "icon": Icons.translate_rounded,
      "color": const Color(0xFF26A69A),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCourses = courses.where((course) {
      switch (_selectedFilter) {
        case 1:
          return course["isFree"] == true;
        case 2:
          return course["hasCertificate"] == true;
        case 3:
          final progress = course["progress"] as double;
          return progress > 0 && progress < 1;
        default:
          return true;
      }
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
          "Learning & Education",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── TOP GRADIENT BANNER ───────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            decoration: const BoxDecoration(
              gradient: AppColors.mainGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${courses.length} Courses to boost your career",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Learn new skills, get certified, get hired",
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

          // ── FILTER CHIPS ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        filters[index],
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.buttonText
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── COURSE LIST ────────────────────────────────
          Expanded(
            child: filteredCourses.isEmpty
                ? const Center(
                    child: Text(
                      "No courses found",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filteredCourses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      return _courseCard(
                        title: course["title"] as String,
                        provider: course["provider"] as String,
                        duration: course["duration"] as String,
                        lessons: course["lessons"] as int,
                        rating: course["rating"] as double,
                        progress: course["progress"] as double,
                        isFree: course["isFree"] as bool,
                        hasCertificate: course["hasCertificate"] as bool,
                        icon: course["icon"] as IconData,
                        color: course["color"] as Color,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── COURSE CARD HELPER ─────────────────────────────────
  Widget _courseCard({
    required String title,
    required String provider,
    required String duration,
    required int lessons,
    required double rating,
    required double progress,
    required bool isFree,
    required bool hasCertificate,
    required IconData icon,
    required Color color,
  }) {
    final bool isCompleted = progress >= 1.0;
    final bool isStarted = progress > 0 && progress < 1.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      provider,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Completed",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                )
              else if (!isFree)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Paid",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Free",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textHint),
              const SizedBox(width: 3),
              Text(
                duration,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.menu_book_rounded, size: 13, color: AppColors.textHint),
              const SizedBox(width: 3),
              Text(
                "$lessons lessons",
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
              const SizedBox(width: 2),
              Text(
                "$rating",
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (hasCertificate) ...[
                const SizedBox(width: 12),
                const Icon(Icons.workspace_premium_rounded, size: 13, color: AppColors.primary),
                const SizedBox(width: 3),
                const Text(
                  "Certificate",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),

          if (isStarted || isCompleted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted
                    ? AppColors.success.withOpacity(0.12)
                    : AppColors.primary,
                foregroundColor:
                    isCompleted ? AppColors.success : AppColors.buttonText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isCompleted
                    ? "View Certificate"
                    : isStarted
                        ? "Continue Learning"
                        : "Start Course",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}