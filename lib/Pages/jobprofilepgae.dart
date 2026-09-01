import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applyforpage.dart';
import '../utils/app_colors.dart';

class JobProfilePage extends StatelessWidget {
  const JobProfilePage({
    super.key,
    this.companyName = "Infosys",
    this.companyFullName = "Infosys Pvt. Ltd.",
    this.rating = 4.2,
    this.reviewCount = "1.5k reviews",
    this.about =
        "Infosys is a global IT services and consulting company providing technology, consulting and outsourcing services.",
    this.industry = "IT Services / Consulting",
    this.companySize = "1001-5000 employees",
    this.headquarters = "Bengaluru, Karnataka",
    this.logoText = "I",
    this.logoColor = const Color(0xFF007CC3),
    this.logoImageUrl,
    this.logoAssetPath,
  });
  final String companyName;
  final String companyFullName;
  final double rating;
  final String reviewCount;
  final String about;
  final String industry;
  final String companySize;
  final String headquarters;
  final String logoText;
  final Color logoColor;
  final String? logoImageUrl;
  final String? logoAssetPath;

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
          "Company Profile",
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
              Icons.ios_share_rounded,
              color: AppColors.buttonText,
              size: 20,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── LOGO + COMPANY INFO ─────────────────────
                Row(
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            companyFullName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
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
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Divider(height: 1, color: AppColors.divider),
                ),

                // ── ABOUT COMPANY ────────────────────────────
                const Text(
                  "About Company",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  about,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),

                // ── DETAIL ROWS ───────────────────────────────
                _detailRow("Industry", industry),
                const SizedBox(height: 14),
                _detailRow("Company Size", companySize),
                const SizedBox(height: 14),
                _detailRow("Headquarters", headquarters),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── VIEW ALL JOBS BUTTON ────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ApplyForPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "View All Jobs",
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── LABEL / VALUE ROW ─────────────────────────────────
  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
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
}
