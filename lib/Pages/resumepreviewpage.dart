import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ResumePreviewPage extends StatelessWidget {
  final String name;
  final String designation;
  final String phone;
  final String email;
  final String location;
  final List<String> skills;
  final String expRole;
  final String expCompany;
  final String expDuration;
  final String expDescription;

  const ResumePreviewPage({
    super.key,
    this.name = "Rahul Sharma",
    this.designation = "Delivery Executive",
    this.phone = "+91 01234 56789",
    this.email = "rahulsharma@email.com",
    this.location = "Mumbai, Maharashtra",
    this.skills = const [
      "Delivery Management",
      "Customer Service",
      "Route Optimization",
      "Time Management",
    ],
    this.expRole = "Backend Devloper",
    this.expCompany = "IconPhase2",
    this.expDuration = "Jan 2022 – Present",
    this.expDescription =
        "Deliver orders to customers ensuring timely delivery and customer satisfaction.",
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
          "Resume Preview",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── RESUME CARD ────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Designation
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        designation,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── CONTACT SECTION ────────────────────
                      _sectionHeader("CONTACT"),
                      const SizedBox(height: 8),
                      _contactRow(Icons.call_outlined, phone),
                      const SizedBox(height: 4),
                      _contactRow(Icons.email_outlined, email),
                      const SizedBox(height: 4),
                      _contactRow(Icons.location_on_outlined, location),

                      const SizedBox(height: 18),

                      // ── SKILLS SECTION ────────────────────
                      _sectionHeader("SKILLS"),
                      const SizedBox(height: 8),
                      ...skills.map((skill) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              "•  $skill",
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          )),

                      const SizedBox(height: 18),

                      // ── EXPERIENCE SECTION ────────────────────
                      _sectionHeader("EXPERIENCE"),
                      const SizedBox(height: 8),
                      Text(
                        expRole,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$expCompany  |  $expDuration",
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        expDescription,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── BOTTOM ACTION BUTTONS ────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined,
                        size: 17, color: AppColors.primary),
                    label: const Text(
                      "Edit",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.download_outlined,
                        size: 17, color: AppColors.buttonText),
                    label: const Text(
                      "Download",
                      style: TextStyle(
                        color: AppColors.buttonText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER (CONTACT / SKILLS / EXPERIENCE) ────────────────────
  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  // ── CONTACT ROW WITH ICON ────────────────────
  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}