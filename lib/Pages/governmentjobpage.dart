import 'package:flutter/material.dart';
import 'package:hyper_local/utils/app_colors.dart';

class GovernmentJobPage extends StatefulWidget {
  const GovernmentJobPage({super.key});

  @override
  State<GovernmentJobPage> createState() => _GovernmentJobPageState();
}

class _GovernmentJobPageState extends State<GovernmentJobPage> {
  String _selectedFilter = "All";

  final filters = ["All", "Railway", "Banking", "SSC", "Police", "State"];

  final govJobs = [
    {
      "title": "Junior Engineer",
      "department": "Indian Railways",
      "location": "Mumbai, Maharashtra",
      "salary": "₹35,400 - ₹1,12,400",
      "lastDate": "15 Aug 2026",
      "logoText": "IR",
      "logoColor": const Color(0xFF1565C0),
      "category": "Railway",
    },
    {
      "title": "Probationary Officer",
      "department": "State Bank of India",
      "location": "Pune, Maharashtra",
      "salary": "₹48,480 - ₹85,920",
      "lastDate": "22 Aug 2026",
      "logoText": "SBI",
      "logoColor": const Color(0xFF00695C),
      "category": "Banking",
    },
    {
      "title": "Combined Graduate Level",
      "department": "Staff Selection Commission",
      "location": "All India",
      "salary": "₹25,500 - ₹81,100",
      "lastDate": "05 Sep 2026",
      "logoText": "SSC",
      "logoColor": const Color(0xFFEF6C00),
      "category": "SSC",
    },
    {
      "title": "Sub Inspector",
      "department": "Maharashtra Police",
      "location": "Nagpur, Maharashtra",
      "salary": "₹29,200 - ₹92,300",
      "lastDate": "30 Aug 2026",
      "logoText": "MP",
      "logoColor": const Color(0xFF6A1B9A),
      "category": "Police",
    },
    {
      "title": "Talathi",
      "department": "Maharashtra State Govt",
      "location": "Nashik, Maharashtra",
      "salary": "₹19,900 - ₹63,200",
      "lastDate": "10 Sep 2026",
      "logoText": "MH",
      "logoColor": const Color(0xFF2E7D32),
      "category": "State",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredJobs = _selectedFilter == "All"
        ? govJobs
        : govJobs.where((job) => job["category"] == _selectedFilter).toList();

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
          "Government Jobs",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── TOP GRADIENT SECTION WITH SEARCH ──────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            decoration: const BoxDecoration(
              gradient: AppColors.mainGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Find your Sarkari Naukri",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${govJobs.length} active vacancies near you",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),

                // Search bar
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: AppColors.textHint,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search department, post...",
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 13.5,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── FILTER CHIPS ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        filter,
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
          ),

          // ── JOB LIST ───────────────────────────────────
          Expanded(
            child: filteredJobs.isEmpty
                ? const Center(
                    child: Text(
                      "No jobs found",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filteredJobs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      return _govJobCard(
                        title: job["title"] as String,
                        department: job["department"] as String,
                        location: job["location"] as String,
                        salary: job["salary"] as String,
                        lastDate: job["lastDate"] as String,
                        logoText: job["logoText"] as String,
                        logoColor: job["logoColor"] as Color,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── GOVERNMENT JOB CARD HELPER ─────────────────────────
  Widget _govJobCard({
    required String title,
    required String department,
    required String location,
    required String salary,
    required String lastDate,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      fontSize: 14,
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
                      department,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: AppColors.mapPinRed,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
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
                  padding: const EdgeInsets.all(5),
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

          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.currency_rupee_rounded,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  Text(
                    salary.replaceAll("₹", ""),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.event_rounded,
                    size: 13,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "Last date: $lastDate",
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.buttonText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "View Details",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}