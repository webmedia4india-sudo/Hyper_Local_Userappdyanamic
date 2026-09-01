import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applicationformpage.dart';
import 'package:hyper_local/Pages/savedjobpage.dart';
import '../utils/app_colors.dart';

class JobDescriptionPage extends StatelessWidget {
  const JobDescriptionPage({
    super.key,
    this.companyName = "IBM",
    this.jobTitle = "Angular Developer",
    this.companyFullName = "IBM India Pvt. Ltd.",
    this.rating = 4.2,
    this.reviewCount = "3.5k reviews",
    this.distance = "1.2 km away",
    this.salary = "₹15,000 - ₹20,000",
    this.experience = "1-2 years",
    this.logoText = "I",
    this.logoColor = const Color(0xFF1F70C1),
    this.logoImageUrl,
    this.logoAssetPath,
    this.skills = const [
      "Angular",
      "TypeScript",
      "HTML",
      "CSS",
      "JavaScript",
      "Git",
    ],
    this.description =
        "We are looking for a skilled Angular Developer to join our team at IBM. "
        "You will be responsible for building and maintaining responsive web "
        "applications, translating UI/UX designs into high-quality code, and "
        "collaborating closely with backend developers and designers to deliver "
        "seamless user experiences. The ideal candidate has hands-on experience "
        "with Angular, TypeScript, and modern front-end tooling, along with a "
        "strong understanding of REST API integration and version control using "
        "Git. Flexible work arrangements are available, and employees receive "
        "competitive compensation along with performance-based growth "
        "opportunities and regular skill development programs.",
    this.totalVacancies = 12,
    this.remainingVacancies = 4,
    this.postedDate = "25 July 2026",
  });

  final String companyName;
  final String jobTitle;
  final String companyFullName;
  final double rating;
  final String reviewCount;
  final String distance;
  final String salary;
  final String experience;

  /// Fallback letter shown if no image is provided / image fails to load.
  final String logoText;

  /// Fallback background color behind the letter / used while image loads.
  final Color logoColor;

  /// Pass a network URL to show a real logo image (e.g. Zomato's logo).
  final String? logoImageUrl;

  /// Or pass a local asset path (e.g. "assets/logos/zomato.png").
  final String? logoAssetPath;

  /// Exact skills required for this job — pass whatever list applies.
  final List<String> skills;

  /// Job description text (kept in the 300-500 character range).
  final String description;

  /// Total number of openings for this job.
  final int totalVacancies;

  /// Number of openings still open (not yet filled).
  final int remainingVacancies;

  /// When this job was posted.
  final String postedDate;

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
          "Job Details",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.bookmark_border_rounded,
              color: AppColors.buttonText,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          // ── HEADER CARD: logo + company + title + rating/distance ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _companyLogo(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        jobTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        companyFullName,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 14,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "$rating ($reviewCount)",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.work_history_rounded,
                                size: 14,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                experience,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                distance,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── SALARY CARD ───────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: salary,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.buttonText,
                    ),
                  ),
                  const TextSpan(
                    text: " /month",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          // ── VACANCY DETAILS ────────────────────────────────
          const Text(
            "Vacancy Details",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _vacancyStat(
                  icon: Icons.groups_rounded,
                  label: "Total Vacancies",
                  value: "$totalVacancies",
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _vacancyStat(
                  icon: Icons.person_add_alt_1_rounded,
                  label: "Remaining",
                  value: "$remainingVacancies",
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _vacancyStat(
                  icon: Icons.calendar_today_rounded,
                  label: "Posted On",
                  value: postedDate,
                  color: const Color(0xFFEF6C00),
                  isDate: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // ── SKILLS REQUIRED ────────────────────────────────
          const Text(
            "Skills Required",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: skills.map((s) => _skillChip(s)).toList(),
          ),
          const SizedBox(height: 22),

          // ── JOB DESCRIPTION ───────────────────────────────
          const Text(
            "Job Description",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),

      // ── BOTTOM ACTION BAR: Save / Apply Now ───────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedJobPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bookmark_border_rounded, size: 18),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ApplicationFormPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Apply Now",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── COMPANY LOGO (real image if provided, else colored letter) ──
  Widget _companyLogo() {
    Widget child;

    if (logoAssetPath != null) {
      child = Image.asset(
        logoAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _logoLetterFallback(),
      );
    } else if (logoImageUrl != null) {
      child = Image.network(
        logoImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, widget, progress) {
          if (progress == null) return widget;
          return _logoLetterFallback();
        },
        errorBuilder: (_, _, _) => _logoLetterFallback(),
      );
    } else {
      child = _logoLetterFallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(width: 60, height: 60, color: logoColor, child: child),
    );
  }

  Widget _logoLetterFallback() {
    return Center(
      child: Text(
        logoText,
        style: const TextStyle(
          color: AppColors.buttonText,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  // ── VACANCY STAT TILE (total / remaining / posted date) ──
  Widget _vacancyStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isDate = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDate ? 11.5 : 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── SKILL CHIP (dynamic — renders whatever skills are passed in) ──
  Widget _skillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
