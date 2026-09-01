import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PartTimeJobPage extends StatefulWidget {
  const PartTimeJobPage({super.key});

  @override
  State<PartTimeJobPage> createState() => _PartTimeJobPageState();
}

class _PartTimeJobPageState extends State<PartTimeJobPage> {
  int _selectedShift = 0;

  final shifts = ["All", "Morning", "Evening", "Weekend"];

  // ── PART TIME JOBS ────────────────────────────────────
  final partTimeJobs = [
    {
      "title": "Store Assistant",
      "company": "D-Mart",
      "shift": "Morning",
      "rate": "₹350 - ₹450 /day",
      "logoText": "D",
      "logoColor": const Color(0xFF00897B),
    },
    {
      "title": "Delivery Helper",
      "company": "Swiggy",
      "shift": "Evening",
      "rate": "₹120 - ₹180 /hr",
      "logoText": "S",
      "logoColor": const Color(0xFFFC8019),
    },
    {
      "title": "Event Staff",
      "company": "BookMyShow Events",
      "shift": "Weekend",
      "rate": "₹500 - ₹700 /day",
      "logoText": "B",
      "logoColor": const Color(0xFFE53935),
    },
    {
      "title": "Tutor - Home Tuition",
      "company": "UrbanPro",
      "shift": "Evening",
      "rate": "₹200 - ₹400 /hr",
      "logoText": "U",
      "logoColor": const Color(0xFF3F51B5),
    },
    {
      "title": "Cashier",
      "company": "Big Bazaar",
      "shift": "Morning",
      "rate": "₹300 - ₹380 /day",
      "logoText": "B",
      "logoColor": const Color(0xFF8E24AA),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredJobs = _selectedShift == 0
        ? partTimeJobs
        : partTimeJobs
            .where((job) => job["shift"] == shifts[_selectedShift])
            .toList();

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
          "Part Time Jobs",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── BANNER ────────────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.mainGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time_filled_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${filteredJobs.length} part time jobs available",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Flexible hours that fit your schedule",
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

            // ── SHIFT FILTER CHIPS ────────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: shifts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = _selectedShift == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedShift = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        shifts[index],
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.buttonText
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // ── JOB LIST ──────────────────────────────────
            Expanded(
              child: filteredJobs.isEmpty
                  ? const Center(
                      child: Text(
                        "No jobs found for this shift",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filteredJobs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final job = filteredJobs[index];
                        return _partTimeJobCard(
                          title: job["title"] as String,
                          company: job["company"] as String,
                          shift: job["shift"] as String,
                          rate: job["rate"] as String,
                          logoText: job["logoText"] as String,
                          logoColor: job["logoColor"] as Color,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PART TIME JOB CARD HELPER ───────────────────────────
  Widget _partTimeJobCard({
    required String title,
    required String company,
    required String shift,
    required String rate,
    required String logoText,
    required Color logoColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: logoColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                logoText,
                style: const TextStyle(
                  color: AppColors.buttonText,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 11,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            shift,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee_rounded,
                      size: 13,
                      color: AppColors.warning,
                    ),
                    Text(
                      rate.replaceAll("₹", ""),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.socialIconBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 16,
                color: AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}