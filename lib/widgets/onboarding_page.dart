import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyper_local/Screen/languagepage.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final double titleFontSize;
  final double subtitleFontSize;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.titleFontSize = 24,
    this.subtitleFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 10),
        child: Column(
          children: [
            /// Top row: Logo (left) + Skip Button (right) — same line
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/new_onboarding_logo.png',
                  height: 28,
                  fit: BoxFit.contain,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LanguagePage()),
                    );
                  },
                  child: Text(
                    "Skip",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Image
            Expanded(flex: 5, child: Image.asset(image, fit: BoxFit.contain)),

            const SizedBox(height: 25),

            /// Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w500, // bold hatla, lighter w500
                color: Colors.black87, // pure black hatla, thoda light
              ),
            ),

            const SizedBox(height: 16),

            /// Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.w400, // normal weight
                  height: 1.6,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}