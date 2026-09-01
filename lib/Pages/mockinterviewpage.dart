import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class MockInterviewPage extends StatelessWidget {
  const MockInterviewPage({super.key});

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
          "Mock Interview",
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
          // ── HEADER CARD ────────────────────
          Container(
            padding: const EdgeInsets.all(16),
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
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.record_voice_over_rounded,
                    color: AppColors.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Mock Interview",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Practice and improve your interview skills",
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

          const SizedBox(height: 20),

          // ── START MOCK INTERVIEW (Highlighted) ────────────────────
          _optionTile(
            label: "Start Mock Interview",
            isHighlighted: true,
            onTap: () {},
          ),
          const SizedBox(height: 12),

          // ── OTHER OPTIONS ────────────────────
          _optionTile(
            label: "AI Interview",
            isHighlighted: false,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _optionTile(
            label: "Industry Expert",
            isHighlighted: false,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _optionTile(
            label: "Technical Interview",
            isHighlighted: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ── SINGLE OPTION ROW ────────────────────
  Widget _optionTile({
    required String label,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    final Color iconColor = isHighlighted ? AppColors.primary : AppColors.success;
    final Color textColor = isHighlighted ? AppColors.primary : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted ? AppColors.primary.withOpacity(0.4) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_rounded,
              size: 20,
              color: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}