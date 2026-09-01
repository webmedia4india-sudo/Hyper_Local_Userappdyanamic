import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';

import '../utils/app_colors.dart';

class ApplicationSuccessPage extends StatelessWidget {
  const ApplicationSuccessPage({
    super.key,
    this.jobTitle = "Delivery Partner",
    this.onViewApplication,
    this.onBackToHome,
    this.illustrationAssetPath,
  });

  final String jobTitle;
  final VoidCallback? onViewApplication;
  final VoidCallback? onBackToHome;

  final String? illustrationAssetPath;

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
          "Application Success",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // ── ILLUSTRATION + SUCCESS BADGE ─────────────────
              _illustration(),

              const SizedBox(height: 28),

              // ── SUCCESS TEXT ──────────────────────────────────
              const Text(
                "Application Submitted!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                "Your application for $jobTitle has been submitted successfully.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
              ),

              const Spacer(),

              // ── ACTION BUTTONS ────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onViewApplication ?? () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    "View Application",
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onBackToHome ??
                      () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardPage(),
                          ),
                          (route) => false,
                        );
                      },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── ILLUSTRATION WITH GREEN CHECK BADGE ───────────────
  Widget _illustration() {
    Widget base;

    if (illustrationAssetPath != null) {
      base = Image.asset(
        illustrationAssetPath!,
        height: 170,
        errorBuilder: (_, _, _) => _fallbackIllustration(),
      );
    } else {
      base = _fallbackIllustration();
    }

    return SizedBox(
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          base,
          Positioned(
            top: 8,
            right: 40,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 3),
                boxShadow: [
                  BoxShadow(color: AppColors.success.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.buttonText, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ── SIMPLE BUILT-IN FALLBACK ILLUSTRATION (no image needed) ──
  Widget _fallbackIllustration() {
    return Container(
      width: 150,
      height: 170,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 56),
        ),
      ),
    );
  }
}