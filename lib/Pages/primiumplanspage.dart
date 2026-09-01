import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PremiumPlansPage extends StatefulWidget {
  const PremiumPlansPage({super.key});

  @override
  State<PremiumPlansPage> createState() => _PremiumPlansPageState();
}

class _PremiumPlansPageState extends State<PremiumPlansPage> {
  int _selectedTab = 0; // 0: Job Seeker, 1: Employer
  int _selectedPlan = 0; // index of selected plan card

  final List<Map<String, dynamic>> _plans = [
    {
      "name": "Premium",
      "price": "₹299",
      "duration": "/month",
      "isPopular": true,
      "features": [
        "Unlimited Applications",
        "AI Resume Review",
        "Priority Support",
        "Premium Badge",
      ],
    },
    {
      "name": "Premium Plus",
      "price": "₹599",
      "duration": "/month",
      "isPopular": false,
      "features": [
        "All Premium Features",
        "Profile Highlight",
        "Early Access Jobs",
      ],
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
          "Premium Plans",
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── TOGGLE TABS ────────────────────
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.otpBoxBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _tabItem("Job Seeker", 0)),
                      Expanded(child: _tabItem("Employer", 1)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── PLAN CARDS ────────────────────
                ...List.generate(_plans.length, (index) {
                  final plan = _plans[index];
                  final isSelected = _selectedPlan == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _planCard(plan, isSelected, index),
                  );
                }),
              ],
            ),
          ),

          // ── BOTTOM GET PREMIUM BUTTON ────────────────────
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
                  "Get Premium",
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

  // ── TOGGLE TAB ITEM ────────────────────
  Widget _tabItem(String label, int index) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.background : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── PLAN CARD ────────────────────
  Widget _planCard(Map<String, dynamic> plan, bool isSelected, int index) {
    final bool isPopular = plan["isPopular"] as bool;
    final List<String> features = plan["features"] as List<String>;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
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
            // Header row: name + radio + popular badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan["name"] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isPopular)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Popular",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20,
                  color: isSelected ? AppColors.primary : AppColors.unselected,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  plan["price"] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  plan["duration"] as String,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Features list
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 15,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}