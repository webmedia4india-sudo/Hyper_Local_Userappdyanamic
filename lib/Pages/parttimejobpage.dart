import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/job_service.dart';
import 'jobdescriptipnpage.dart';

class PartTimeJobPage extends StatefulWidget {
  const PartTimeJobPage({super.key});

  @override
  State<PartTimeJobPage> createState() => _PartTimeJobPageState();
}

class _PartTimeJobPageState extends State<PartTimeJobPage> {
  int _selectedShift = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _dynamicJobs = [];

  final shifts = ["All", "Morning", "Evening", "Weekend"];

  // ── PART TIME JOBS FALLBACK ───────────────────────────
  final partTimeJobs = [
    {
      "id": 101,
      "title": "Store Assistant",
      "company": "D-Mart",
      "shift": "Morning",
      "rate": "₹350 - ₹450 /day",
      "logoText": "D",
      "logoColor": const Color(0xFF00897B),
      "rating": 4.3,
      "reviewCount": "1.2k reviews",
      "distance": "1.5 km",
      "experience": "Fresher / 0-1 yr",
      "skills": ["Customer Handling", "Inventory"],
      "description": "Store assistant for managing retail stock and helping customers.",
      "totalVacancies": 5,
      "remainingVacancies": 3,
      "postedDate": "Recently",
    },
    {
      "id": 102,
      "title": "Delivery Helper",
      "company": "Swiggy",
      "shift": "Evening",
      "rate": "₹120 - ₹180 /hr",
      "logoText": "S",
      "logoColor": const Color(0xFFFC8019),
      "rating": 4.1,
      "reviewCount": "3.8k reviews",
      "distance": "2.0 km",
      "experience": "Fresher",
      "skills": ["Driving", "Navigation"],
      "description": "Evening delivery support for food orders in nearby localities.",
      "totalVacancies": 10,
      "remainingVacancies": 7,
      "postedDate": "Recently",
    },
    {
      "id": 103,
      "title": "Event Staff",
      "company": "BookMyShow Events",
      "shift": "Weekend",
      "rate": "₹500 - ₹700 /day",
      "logoText": "B",
      "logoColor": const Color(0xFFE53935),
      "rating": 4.5,
      "reviewCount": "850 reviews",
      "distance": "3.2 km",
      "experience": "0-1 year",
      "skills": ["Event Management", "Communication"],
      "description": "Weekend ticketing and crowd management for local shows and events.",
      "totalVacancies": 4,
      "remainingVacancies": 2,
      "postedDate": "Recently",
    },
    {
      "id": 104,
      "title": "Tutor - Home Tuition",
      "company": "UrbanPro",
      "shift": "Evening",
      "rate": "₹200 - ₹400 /hr",
      "logoText": "U",
      "logoColor": const Color(0xFF3F51B5),
      "rating": 4.6,
      "reviewCount": "420 reviews",
      "distance": "1.8 km",
      "experience": "1-2 years",
      "skills": ["Teaching", "Math / Science"],
      "description": "Evening tuition classes for school students near your locality.",
      "totalVacancies": 2,
      "remainingVacancies": 1,
      "postedDate": "Recently",
    },
    {
      "id": 105,
      "title": "Cashier",
      "company": "Big Bazaar",
      "shift": "Morning",
      "rate": "₹300 - ₹380 /day",
      "logoText": "B",
      "logoColor": const Color(0xFF8E24AA),
      "rating": 4.2,
      "reviewCount": "2.1k reviews",
      "distance": "2.5 km",
      "experience": "Fresher / 1 yr",
      "skills": ["Billing", "POS Systems"],
      "description": "Morning shift cashier and counter billing assistant.",
      "totalVacancies": 3,
      "remainingVacancies": 2,
      "postedDate": "Recently",
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchPartTimeJobs();
  }

  Future<void> _fetchPartTimeJobs() async {
    setState(() => _isLoading = true);
    try {
      final allJobs = await JobService().getJobs();
      final partTimeList = allJobs.where((j) {
        final emp = (j.employmentType ?? '').toLowerCase().trim();
        final title = j.title.toLowerCase();
        return j.isPartTime || emp.contains('part') || title.contains('part-time');
      }).toList();

      if (partTimeList.isNotEmpty) {
        final accentColors = [
          const Color(0xFF00897B),
          const Color(0xFFFC8019),
          const Color(0xFFE53935),
          const Color(0xFF3F51B5),
          const Color(0xFF8E24AA),
        ];

        final parsed = <Map<String, dynamic>>[];
        for (int i = 0; i < partTimeList.length; i++) {
          final job = partTimeList[i];
          final compName = job.companyName.trim().isNotEmpty ? job.companyName.trim() : "Company";
          final initial = compName.isNotEmpty ? compName.substring(0, 1).toUpperCase() : "J";

          parsed.add({
            "id": job.id,
            "title": job.title.trim().isNotEmpty ? job.title.trim() : "Part-Time Opening",
            "company": compName,
            "companyFullName": compName,
            "shift": "Morning", // Default shift tag or derived from shift_type
            "rate": job.formattedSalary.isNotEmpty ? job.formattedSalary : "Competitive",
            "logoText": initial,
            "logoColor": accentColors[i % accentColors.length],
            "rating": job.displayRating,
            "reviewCount": job.displayReviewCount,
            "distance": job.formattedDistance,
            "experience": job.experienceRequired ?? "Fresher / 1 yr",
            "skills": job.skills.isNotEmpty ? job.skills : ["Communication"],
            "description": job.description ?? "Part-time job opportunity.",
            "totalVacancies": job.totalVacancies > 0 ? job.totalVacancies : 1,
            "remainingVacancies": job.remainingVacancies > 0 ? job.remainingVacancies : 1,
            "postedDate": job.formattedPostedDate,
          });
        }

        if (mounted) {
          setState(() {
            _dynamicJobs = parsed;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("PartTimeJobPage fetch error: $e");
    }

    if (mounted) {
      setState(() {
        _dynamicJobs = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeList = _dynamicJobs.isNotEmpty ? _dynamicJobs : partTimeJobs;
    final filteredJobs = _selectedShift == 0
        ? activeList
        : activeList
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
        child: RefreshIndicator(
          onRefresh: _fetchPartTimeJobs,
          color: AppColors.primary,
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
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : filteredJobs.isEmpty
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
                              return _partTimeJobCard(job);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PART TIME JOB CARD HELPER ───────────────────────────
  Widget _partTimeJobCard(Map<String, dynamic> job) {
    final String title = job["title"] as String;
    final String company = job["company"] as String;
    final String shift = job["shift"] as String;
    final String rate = job["rate"] as String;
    final String logoText = job["logoText"] as String;
    final Color logoColor = job["logoColor"] as Color;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        final jobIdVal = job["id"] is int
            ? job["id"] as int
            : int.tryParse(job["id"]?.toString() ?? '1') ?? 1;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDescriptionPage(
              jobPostId: jobIdVal,
              companyName: company,
              jobTitle: title,
              companyFullName: (job["companyFullName"] ?? company).toString(),
              rating: (job["rating"] is num) ? (job["rating"] as num).toDouble() : 4.2,
              reviewCount: (job["reviewCount"] ?? "3.5k reviews").toString(),
              distance: (job["distance"] ?? "Nearby").toString(),
              salary: rate,
              experience: (job["experience"] ?? "1-2 years").toString(),
              skills: (job["skills"] is List) ? List<String>.from(job["skills"]) : const ["Communication"],
              description: (job["description"] ?? "Part-time job opportunity.").toString(),
              logoText: logoText,
              logoColor: logoColor,
              totalVacancies: (job["totalVacancies"] is int) ? job["totalVacancies"] as int : 1,
              remainingVacancies: (job["remainingVacancies"] is int) ? job["remainingVacancies"] as int : 1,
              postedDate: (job["postedDate"] ?? "Recently").toString(),
            ),
          ),
        );
      },
      child: Container(
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
    ),
    );
  }
}