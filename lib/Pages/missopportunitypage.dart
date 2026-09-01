import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Data for a single missed job — pass a list of these to [MissOpportunityPage].
class MissedJobInfo {
  const MissedJobInfo({
    required this.companyName,
    required this.jobTitle,
    this.companyFullName = "",
    this.salary = "",
    this.logoText = "?",
    this.logoColor = AppColors.primary,
    this.logoImageUrl,
    this.logoAssetPath,
    this.postedDate = "",
    this.missedDate = "",
    this.reason = "This opportunity is no longer available.",
  });

  final String companyName;
  final String jobTitle;
  final String companyFullName;
  final String salary;
  final String logoText;
  final Color logoColor;
  final String? logoImageUrl;
  final String? logoAssetPath;
  final String postedDate;
  final String missedDate;
  final String reason;
}

class MissOpportunityPage extends StatelessWidget {
  MissOpportunityPage({
    super.key,
    List<MissedJobInfo>? missedJobs,
    this.onBrowseJobs,
    this.onJobTap,
  }) : missedJobs = missedJobs ?? _defaultMissedJobs;

  /// All the jobs the user missed out on.
  final List<MissedJobInfo> missedJobs;

  /// Called when the user taps "Browse Similar Jobs".
  final VoidCallback? onBrowseJobs;

  /// Called with the tapped job when a card is pressed.
  final void Function(MissedJobInfo job)? onJobTap;

  static final List<MissedJobInfo> _defaultMissedJobs = [
    const MissedJobInfo(
      companyName: "TechNova Solutions",
      jobTitle: "Angular Developer",
      companyFullName: "TechNova Solutions Pvt. Ltd.",
      salary: "₹35,000 - ₹45,000",
      logoText: "A",
      logoColor: AppColors.coral,
      postedDate: "18 July 2026",
      missedDate: "27 July 2026",
      reason: "All vacancies for this role have been filled.",
    ),
    const MissedJobInfo(
      companyName: "PixelCraft Studio",
      jobTitle: "Frontend Developer",
      companyFullName: "PixelCraft Studio LLP",
      salary: "₹30,000 - ₹40,000",
      logoText: "F",
      logoColor: AppColors.mint,
      postedDate: "15 July 2026",
      missedDate: "26 July 2026",
      reason: "Application deadline has passed.",
    ),
    const MissedJobInfo(
      companyName: "CoreStack Systems",
      jobTitle: "Backend Developer",
      companyFullName: "CoreStack Systems Pvt. Ltd.",
      salary: "₹40,000 - ₹55,000",
      logoText: "B",
      logoColor: AppColors.primary,
      postedDate: "12 July 2026",
      missedDate: "24 July 2026",
      reason: "All vacancies for this role have been filled.",
    ),
    const MissedJobInfo(
      companyName: "AppSpring Labs",
      jobTitle: "Flutter Developer",
      companyFullName: "AppSpring Labs Pvt. Ltd.",
      salary: "₹32,000 - ₹42,000",
      logoText: "F",
      logoColor: AppColors.pink,
      postedDate: "10 July 2026",
      missedDate: "22 July 2026",
      reason: "Application deadline has passed.",
    ),
  ];

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
          "Missed Opportunities",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        children: [
          // ── STATUS BANNER ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryLight, AppColors.accentsSoft[0]],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDeep.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.hourglass_disabled_rounded,
                    color: AppColors.primaryDark,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "You Missed These Opportunities",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${missedJobs.length} jobs you applied late for or missed out on",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── LIST OF MISSED JOB CARDS ───────────────────────
          ...missedJobs.map((job) => _missedJobCard(context, job)),
          const SizedBox(height: 8),

          // ── CTA: browse similar jobs ──────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onBrowseJobs,
              icon: const Icon(Icons.search_rounded, size: 20),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.buttonText,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              label: const Text(
                "Browse Similar Jobs",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SINGLE MISSED JOB CARD ─────────────────────────────────
  Widget _missedJobCard(BuildContext context, MissedJobInfo job) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onJobTap == null ? null : () => onJobTap!(job),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _companyLogo(job),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.companyName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.jobTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          if (job.companyFullName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              job.companyFullName,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (job.salary.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mintSoft,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${job.salary} /month",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _dateInfo(
                        icon: Icons.campaign_rounded,
                        iconColor: AppColors.primary,
                        label: "Posted On",
                        value: job.postedDate,
                      ),
                    ),
                    Expanded(
                      child: _dateInfo(
                        icon: Icons.event_busy_rounded,
                        iconColor: AppColors.coral,
                        label: "Closed On",
                        value: job.missedDate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  job.reason,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── DATE INFO CHIP (posted / closed) ──────────────────────
  Widget _dateInfo({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── COMPANY LOGO (real image if provided, else colored letter) ──
  Widget _companyLogo(MissedJobInfo job) {
    Widget child;

    if (job.logoAssetPath != null) {
      child = Image.asset(
        job.logoAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _logoLetterFallback(job.logoText),
      );
    } else if (job.logoImageUrl != null) {
      child = Image.network(
        job.logoImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, widget, progress) {
          if (progress == null) return widget;
          return _logoLetterFallback(job.logoText);
        },
        errorBuilder: (_, _, _) => _logoLetterFallback(job.logoText),
      );
    } else {
      child = _logoLetterFallback(job.logoText);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 54,
        height: 54,
        color: job.logoColor,
        child: child,
      ),
    );
  }

  Widget _logoLetterFallback(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.buttonText,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}