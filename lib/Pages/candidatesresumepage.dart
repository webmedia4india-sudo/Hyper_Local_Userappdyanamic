// C:\flutter-projects\hyper_local\lib\Pages\candidatesresumepage.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// ---------------- Resume Data Model ----------------
class EducationItem {
  final String degree;
  final String institution;
  final String year;

  EducationItem({
    required this.degree,
    required this.institution,
    required this.year,
  });
}

class WorkHistoryItem {
  final String title;
  final String company;
  final String duration;
  final String description;

  WorkHistoryItem({
    required this.title,
    required this.company,
    required this.duration,
    required this.description,
  });
}

class CandidateResumeData {
  final String name;
  final String jobTitle;
  final String location;
  final String address;
  final String phone;
  final String email;
  final String imageUrl;
  final String experience;
  final String noticePeriod;
  final String availability;
  final String expectedSalary;
  final int matchScore;
  final List<String> technology;
  final List<EducationItem> education;
  final List<WorkHistoryItem> workHistory;
  final String resumeFileName;

  CandidateResumeData({
    required this.name,
    required this.jobTitle,
    required this.location,
    required this.address,
    required this.phone,
    required this.email,
    required this.imageUrl,
    required this.experience,
    required this.noticePeriod,
    required this.availability,
    required this.expectedSalary,
    required this.matchScore,
    required this.technology,
    required this.education,
    required this.workHistory,
    required this.resumeFileName,
  });
}

// ---------------- Candidate Resume Page ----------------
class CandidateResumePage extends StatelessWidget {
  final CandidateResumeData candidate;

  const CandidateResumePage({super.key, required this.candidate});

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
          "Find Jobs",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 18),
          _buildQuickStats(),
          const SizedBox(height: 20),
          _buildSectionTitle("Contact Information", Icons.contact_page_outlined),
          const SizedBox(height: 10),
          _buildContactCard(context),
          const SizedBox(height: 20),
          _buildSectionTitle("Skills & Technology", Icons.code_rounded),
          const SizedBox(height: 10),
          _buildSkillsWrap(),
          const SizedBox(height: 20),
          _buildSectionTitle("Education", Icons.school_outlined),
          const SizedBox(height: 10),
          _buildEducationList(),
          const SizedBox(height: 20),
          _buildSectionTitle("Work Experience", Icons.work_outline_rounded),
          const SizedBox(height: 10),
          _buildWorkHistoryList(),
          const SizedBox(height: 20),
          _buildSectionTitle("Attached Resume", Icons.description_outlined),
          const SizedBox(height: 10),
          _buildResumeCard(),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  // ── Profile Header ──────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              candidate.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  candidate.jobTitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.lime),
                    const SizedBox(width: 4),
                    Text(
                      candidate.location,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, size: 13, color: AppColors.primaryDeep),
                      const SizedBox(width: 3),
                      Text(
                        "${candidate.matchScore}% Match",
                        style: const TextStyle(
                          color: AppColors.primaryDeep,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Stats Grid ─────────────────────────────────
  Widget _buildQuickStats() {
    final stats = [
      {"icon": Icons.work_history_outlined, "label": "Experience", "value": candidate.experience},
      {"icon": Icons.event_available_outlined, "label": "Notice Period", "value": candidate.noticePeriod},
      {"icon": Icons.schedule_outlined, "label": "Availability", "value": candidate.availability},
      {"icon": Icons.currency_rupee_rounded, "label": "Expected CTC", "value": candidate.expectedSalary},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat["icon"] as IconData, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat["label"] as String,
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stat["value"] as String,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Section Title Helper ─────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── Contact Card ──────────────────────────────────────
  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _contactRow(Icons.phone_outlined, "Phone", candidate.phone),
          const Divider(height: 20, color: AppColors.divider),
          _contactRow(Icons.email_outlined, "Email", candidate.email),
          const Divider(height: 20, color: AppColors.divider),
          _contactRow(Icons.home_outlined, "Address", candidate.address),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Skills Wrap ───────────────────────────────────────
  Widget _buildSkillsWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: candidate.technology.asMap().entries.map((entry) {
        final color = AppColors.accents[entry.key % AppColors.accents.length];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Text(
            entry.value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Education List ────────────────────────────────────
  Widget _buildEducationList() {
    return Column(
      children: candidate.education.map((edu) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school_rounded, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      edu.degree,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      edu.institution,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                edu.year,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Work History List (Timeline Style) ────────────────
  Widget _buildWorkHistoryList() {
    return Column(
      children: candidate.workHistory.asMap().entries.map((entry) {
        final isLast = entry.key == candidate.workHistory.length - 1;
        final item = entry.value;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.border,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${item.company} · ${item.duration}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Resume File Card ───────────────────────────────────
  Widget _buildResumeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.coral.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.coral, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              candidate.resumeFileName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: hook up resume open/download logic
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_red_eye_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    "View",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Action Bar ──────────────────────────────────
  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${candidate.name} - Rejected"),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.close_rounded, color: AppColors.error),
              label: const Text("Reject", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${candidate.name} - Shortlisted"),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.favorite_rounded, color: Colors.white),
              label: const Text("Shortlist", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}