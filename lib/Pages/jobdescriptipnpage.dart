import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applicationtrackerpage.dart';
import 'package:hyper_local/services/job_application_service.dart';
import 'package:hyper_local/services/saved_job_service.dart';
import 'package:hyper_local/utils/session_manager.dart';
import '../utils/app_colors.dart';

class JobDescriptionPage extends StatefulWidget {
  final int jobPostId;
  final String companyName;
  final String jobTitle;
  final String companyFullName;
  final double rating;
  final String reviewCount;
  final String distance;
  final String salary;
  final String experience;
  final String logoText;
  final Color logoColor;
  final String? logoImageUrl;
  final String? logoAssetPath;
  final List<String> skills;
  final String description;
  final int totalVacancies;
  final int remainingVacancies;
  final String postedDate;

  const JobDescriptionPage({
    super.key,
    this.jobPostId = 1,
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

  @override
  State<JobDescriptionPage> createState() => _JobDescriptionPageState();
}

class _JobDescriptionPageState extends State<JobDescriptionPage> {
  bool _isApplying = false;
  bool _isApplied = false;
  bool _isSaved = false;
  bool _isSavingJob = false;

  @override
  void initState() {
    super.initState();
    _checkIfJobIsSaved();
  }

  Future<void> _checkIfJobIsSaved() async {
    try {
      final userDetails = await SessionManager.getUserDetails();
      final userId = (userDetails['id'] is int)
          ? userDetails['id'] as int
          : int.tryParse(userDetails['id']?.toString() ?? '0') ?? 0;
      if (userId > 0 && jobPostId > 0) {
        final savedJobs = await SavedJobService().getSavedJobsByUser(userId);
        final isSaved = savedJobs.any((sj) => sj.jobPostId == jobPostId || sj.jobPost.id == jobPostId);
        if (mounted) {
          setState(() {
            _isSaved = isSaved;
          });
        }
      }
    } catch (e) {
      debugPrint("Error checking saved job state: $e");
    }
  }

  Future<void> _toggleSaveJob() async {
    if (_isSavingJob) return;

    setState(() => _isSavingJob = true);

    try {
      final userDetails = await SessionManager.getUserDetails();
      final userId = (userDetails['id'] is int)
          ? userDetails['id'] as int
          : int.tryParse(userDetails['id']?.toString() ?? '0') ?? 0;

      if (userId == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please log in first to save jobs."),
            backgroundColor: AppColors.warning,
          ),
        );
        setState(() => _isSavingJob = false);
        return;
      }

      final targetJobId = jobPostId > 0 ? jobPostId : 1;

      if (_isSaved) {
        final res = await SavedJobService().deleteSavedJob(
          userId: userId,
          jobPostId: targetJobId,
        );
        if (!mounted) return;
        if (res['success'] == true) {
          setState(() {
            _isSaved = false;
            _isSavingJob = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Job removed from saved jobs"),
              backgroundColor: AppColors.primary,
            ),
          );
        } else {
          setState(() => _isSavingJob = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message']?.toString() ?? "Failed to unsave job"),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else {
        final res = await SavedJobService().saveJob(
          userId: userId,
          jobPostId: targetJobId,
        );
        if (!mounted) return;
        final isSuccess = res['success'] == true;
        final isAlreadySaved = res['message']?.toString().contains('already saved') == true;

        if (isSuccess || isAlreadySaved) {
          setState(() {
            _isSaved = true;
            _isSavingJob = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isAlreadySaved ? "Job is already saved." : "Job saved successfully!"),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          setState(() => _isSavingJob = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message']?.toString() ?? "Failed to save job"),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingJob = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving job: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  int get jobPostId => widget.jobPostId;
  String get companyName => widget.companyName;
  String get jobTitle => widget.jobTitle;
  String get companyFullName => widget.companyFullName;
  double get rating => widget.rating;
  String get reviewCount => widget.reviewCount;
  String get distance => widget.distance;
  String get salary => widget.salary;
  String get experience => widget.experience;
  String get logoText => widget.logoText;
  Color get logoColor => widget.logoColor;
  String? get logoImageUrl => widget.logoImageUrl;
  String? get logoAssetPath => widget.logoAssetPath;
  List<String> get skills => widget.skills;
  String get description => widget.description;
  int get totalVacancies => widget.totalVacancies;
  int get remainingVacancies => widget.remainingVacancies;
  String get postedDate => widget.postedDate;

  Future<void> _handleApply() async {
    if (_isApplying || _isApplied) return;

    setState(() => _isApplying = true);

    try {
      final userDetails = await SessionManager.getUserDetails();
      final userId = (userDetails['id'] is int)
          ? userDetails['id'] as int
          : int.tryParse(userDetails['id']?.toString() ?? '0') ?? 0;

      if (userId == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please log in first to apply."),
            backgroundColor: AppColors.warning,
          ),
        );
        setState(() => _isApplying = false);
        return;
      }

      final isEligible = await JobApplicationService().validateResumeCompletion(context);
      if (!isEligible) {
        if (mounted) setState(() => _isApplying = false);
        return;
      }

      final response = await JobApplicationService().applyForJob(
        userId: userId,
        jobPostId: jobPostId > 0 ? jobPostId : 1,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          _isApplied = true;
          _isApplying = false;
        });
        _showSuccessDialog();
      } else {
        setState(() => _isApplying = false);
        final msg = response['message']?.toString() ??
            "Failed to submit application. Please try again.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isApplying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error submitting application: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Success",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return Transform.scale(
          scale: curved.value,
          child: Opacity(
            opacity: anim.value.clamp(0.0, 1.0),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Application Submitted!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your application for $jobTitle at $companyName has been submitted successfully.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "Done",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ApplicationTrackerPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "Track Status",
                              style: TextStyle(
                                color: AppColors.buttonText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
          "Job Details",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleSaveJob,
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
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
                  onPressed: _isSavingJob ? null : _toggleSaveJob,
                  icon: _isSavingJob
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 18,
                          color: _isSaved ? AppColors.primary : AppColors.textPrimary,
                        ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isSaved ? AppColors.primary : AppColors.textPrimary,
                    side: BorderSide(
                      color: _isSaved ? AppColors.primary : AppColors.border,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: Text(
                    _isSaved ? "Saved" : "Save",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: _isSaved ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isApplying ? null : _handleApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isApplied
                        ? AppColors.success
                        : AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isApplying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppColors.buttonText,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isApplied) ...[
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: AppColors.buttonText,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              _isApplied ? "Applied" : "Apply Now",
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
