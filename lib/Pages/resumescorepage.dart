import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/resumepreviewpage.dart';
import 'dart:math' as math;
import '../utils/app_colors.dart';

class ResumeScorePage extends StatelessWidget {
  final int score;
  final int maxScore;
  final List<String> improvementTips;

  const ResumeScorePage({
    super.key,
    this.score = 85,
    this.maxScore = 100,
    this.improvementTips = const [
      "Add more skills",
      "Add work experience",
      "Add more achievements",
      "Update resume summary",
    ],
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
          "AI Resume Score",
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
          // ── SCORE CARD ────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
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
              children: [
                // Circular score arc
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _ScoreArcPainter(
                      progress: score / maxScore,
                      progressColor: AppColors.success,
                      backgroundColor: AppColors.divider,
                    ),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "$score",
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: "/$maxScore",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Great! Your resume looks good.",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── IMPROVE SCORE SECTION ────────────────────
          const Text(
            "Improve your score",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: List.generate(improvementTips.length, (index) {
                final isLast = index == improvementTips.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.radio_button_unchecked,
                            size: 20,
                            color: AppColors.unselected,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              improvementTips[index],
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        indent: 48,
                        color: AppColors.divider,
                      ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 24),

          // ── IMPROVE NOW BUTTON ────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResumePreviewPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Improve Now",
                style: TextStyle(
                  color: AppColors.buttonText,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CUSTOM PAINTER FOR CIRCULAR SCORE ARC ────────────────────
class _ScoreArcPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color progressColor;
  final Color backgroundColor;

  _ScoreArcPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Background full circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc — starts from top (-90°)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
