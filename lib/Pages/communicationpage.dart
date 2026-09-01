import 'package:flutter/material.dart';
import '../utils/app_colors.dart'; // apne project madhe jya path la AppColors ahe tithun import kr

class CommunicationPage extends StatelessWidget {
  final double featuredProgress; // 0.0 to 1.0

  const CommunicationPage({
    super.key,
    this.featuredProgress = 0.4,
  });

  // Communication skill topics - title, description, icon, colors
  static const List<Map<String, dynamic>> _topics = [
    {
      "icon": Icons.hearing_rounded,
      "iconBg": Color(0xFFE3F2FD),
      "iconColor": AppColors.primary,
      "title": "Active Listening",
      "subtitle": "Understand more, respond better",
    },
    {
      "icon": Icons.campaign_rounded,
      "iconBg": Color(0xFFFFF3E0),
      "iconColor": AppColors.warning,
      "title": "Public Speaking",
      "subtitle": "Speak with clarity and confidence",
    },
    {
      "icon": Icons.mail_rounded,
      "iconBg": Color(0xFFE8F5E9),
      "iconColor": AppColors.success,
      "title": "Email Writing",
      "subtitle": "Write clear and professional emails",
    },
    {
      "icon": Icons.groups_rounded,
      "iconBg": Color(0xFFF3E5F5),
      "iconColor": Color(0xFF9C27B0),
      "title": "Small Talk & Networking",
      "subtitle": "Build connections with ease",
    },
    {
      "icon": Icons.co_present_rounded,
      "iconBg": Color(0xFFFFEBEE),
      "iconColor": AppColors.error,
      "title": "Presentation Skills",
      "subtitle": "Present ideas that leave an impact",
    },
    {
      "icon": Icons.forum_rounded,
      "iconBg": Color(0xFFE0F2F1),
      "iconColor": Color(0xFF00897B),
      "title": "Team Communication",
      "subtitle": "Collaborate effectively at work",
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
          "Communication",
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
            "Build stronger communication skills",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Lessons to help you speak, write & connect better",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          // ── FEATURED PROGRESS CARD ────────────────────
          Container(
            padding: const EdgeInsets.all(14),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Currently Learning",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Active Listening",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: featuredProgress,
                                minHeight: 6,
                                backgroundColor: AppColors.divider,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${(featuredProgress * 100).toInt()}%",
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "All Topics",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

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