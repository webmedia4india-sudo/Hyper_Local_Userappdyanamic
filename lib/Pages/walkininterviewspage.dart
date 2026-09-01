import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class WalkinInterviewsPage extends StatelessWidget {
  final List<Map<String, String>> interviews;

  const WalkinInterviewsPage({
    super.key,
    this.interviews = const [
      {
        "company": "Hotel Blue Pearl",
        "department": "Government Road",
        "date": "18 May 2024",
        "time": "10:00 AM - 4:00 PM",
        "position": "Waiter, Steward",
        "location": "Andheri, Mumbai",
        "distance": "1.8 km",
      },
      {
        "company": "Reliance Digital",
        "department": "",
        "date": "19 May 2024",
        "time": "10:00 AM - 2:00 PM",
        "position": "Sales Executive",
        "location": "Borivali, Mumbai",
        "distance": "2.5 km",
      },
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
          "Walk-in Interviews",
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: interviews.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _interviewCard(interviews[index]),
                );
              },
            ),
          ),

          // ── VIEW ALL BUTTON ────────────────────
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: AppColors.buttonText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SINGLE INTERVIEW CARD ────────────────────
  Widget _interviewCard(Map<String, String> item) {
    final String department = item["department"] ?? "";

    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company name
          Text(
            item["company"] ?? "",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          if (department.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              department,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: 12),

          _infoRow("Date:", item["date"] ?? ""),
          const SizedBox(height: 6),
          _infoRow("Time:", item["time"] ?? ""),
          const SizedBox(height: 6),
          _infoRow("Position:", item["position"] ?? ""),
          const SizedBox(height: 6),

          // Location row with distance aligned right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _infoRow("Location:", item["location"] ?? "")),
              Text(
                item["distance"] ?? "",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── LABEL : VALUE ROW ────────────────────
  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label ",
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}