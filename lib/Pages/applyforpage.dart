import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applicationsuccesspage.dart';
import '../utils/app_colors.dart';

/// Apply For Job page — matches reference design:
/// colored AppBar, job title + company, "Select Resume" card
/// (filename + updated date + Change link), "Add a Cover Letter"
/// textarea, and a bottom "Submit Application" button.
class ApplyForPage extends StatefulWidget {
  const ApplyForPage({
    super.key,
    this.jobTitle = "Abgular Devloper",
    this.companyFullName = "Wicon Pvt. Ltd.",
    this.resumeFileName = "Rahul_Resume.pdf",
    this.resumeUpdatedOn = "Updated on 13 May 2024",
  });

  final String jobTitle;
  final String companyFullName;
  final String resumeFileName;
  final String resumeUpdatedOn;

  @override
  State<ApplyForPage> createState() => _ApplyForPageState();
}

class _ApplyForPageState extends State<ApplyForPage> {
  final TextEditingController _coverLetterController = TextEditingController();

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
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
          "Apply for Job",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        children: [
          // ── HEADING ──────────────────────────────────────
          const Text(
            "Apply for",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.jobTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.companyFullName,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 22),

          // ── SELECT RESUME ─────────────────────────────────
          const Text(
            "Select Resume",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
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
                      Text(
                        widget.resumeFileName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.resumeUpdatedOn,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    "Change",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── ADD COVER LETTER ───────────────────────────────
          Row(
            children: [
              const Text(
                "Add a Cover Letter",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "(Recommended)",
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                TextField(
                  controller: _coverLetterController,
                  maxLines: 5,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Write something about yourself...",
                    hintStyle: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textHint,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(14, 14, 40, 14),
                    border: InputBorder.none,
                  ),
                ),
                const Positioned(
                  right: 12,
                  top: 12,
                  child: Icon(
                    Icons.edit_note_rounded,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 90),
        ],
      ),

      // ── BOTTOM SUBMIT BUTTON ───────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ApplicationSuccessPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.buttonText,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Submit Application",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
