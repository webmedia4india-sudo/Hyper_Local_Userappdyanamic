import 'package:flutter/material.dart';
import '../utils/app_colors.dart'; // apne project madhe jya path la AppColors ahe tithun import kr

class InterviewSkillsPage extends StatelessWidget {
  const InterviewSkillsPage({super.key});

  // Interview skill topics - title, description, icon, colors
  static const List<Map<String, dynamic>> _topics = [
    {
      "icon": Icons.record_voice_over_rounded,
      "iconBg": Color(0xFFE3F2FD),
      "iconColor": AppColors.primary,
      "title": "Self Introduction",
      "subtitle": "Learn how to introduce yourself confidently",
    },
    {
      "icon": Icons.question_answer_rounded,
      "iconBg": Color(0xFFFFF3E0),
      "iconColor": AppColors.warning,
      "title": "Common Interview Questions",
      "subtitle": "Practice frequently asked questions",
    },
    {
      "icon": Icons.checkroom_rounded,
      "iconBg": Color(0xFFE8F5E9),
      "iconColor": AppColors.success,
      "title": "Dress Code & Presentation",
      "subtitle": "First impressions that matter",
    },
    {
      "icon": Icons.emoji_emotions_rounded,
      "iconBg": Color(0xFFF3E5F5),
      "iconColor": Color(0xFF9C27B0),
      "title": "Body Language",
      "subtitle": "Non-verbal cues that build trust",
    },
    {
      "icon": Icons.psychology_rounded,
      "iconBg": Color(0xFFFFEBEE),
      "iconColor": AppColors.error,
      "title": "Handling Tricky Questions",
      "subtitle": "Stay calm under pressure",
    },
    {
      "icon": Icons.attach_money_rounded,
      "iconBg": Color(0xFFE0F2F1),
      "iconColor": Color(0xFF00897B),
      "title": "Salary Negotiation",
      "subtitle": "Talk numbers the right way",
    },
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
          "Interview Skills",
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
          const Text(
            "Sharpen your interview skills",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Short lessons to help you crack any interview",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // ── TOPIC LIST ────────────────────
          ...List.generate(_topics.length, (index) {
            final topic = _topics[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _topicCard(topic),
            );
          }),
        ],
      ),
    );
  }

  Widget _topicCard(Map<String, dynamic> topic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: topic["iconBg"] as Color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              topic["icon"] as IconData,
              size: 22,
              color: topic["iconColor"] as Color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic["title"] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topic["subtitle"] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}