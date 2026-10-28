import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/job_service.dart';
import 'workfromhomedetailspage.dart';

class WorkFromHomePage extends StatefulWidget {
  const WorkFromHomePage({super.key});

  @override
  State<WorkFromHomePage> createState() => _WorkFromHomePageState();
}

class _WorkFromHomePageState extends State<WorkFromHomePage> {
  int _selectedFilter = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _dynamicJobs = [];

  final filters = ["All", "Full Time", "Part Time", "Freelance"];

  @override
  void initState() {
    super.initState();
    _fetchWFHJobs();
  }

  Future<void> _fetchWFHJobs() async {
    setState(() => _isLoading = true);
    try {
      final allJobs = await JobService().getJobs();
      final wfhList = allJobs.where((j) {
        final emp = (j.employmentType ?? '').toLowerCase().trim();
        final title = j.title.toLowerCase();
        return j.isWFH ||
            emp.contains('work from home') ||
            emp.contains('wfh') ||
            emp.contains('remote') ||
            title.contains('work from home') ||
            title.contains('wfh');
      }).toList();

      if (wfhList.isNotEmpty) {
        final accentColors = [
          const Color(0xFFFF9900),
          const Color(0xFF8E24AA),
          const Color(0xFF0F62FE),
          const Color(0xFF00C4CC),
          const Color(0xFF26A69A),
        ];

        final parsed = <Map<String, dynamic>>[];
        for (int i = 0; i < wfhList.length; i++) {
          final job = wfhList[i];
          final compName = job.companyName.trim().isNotEmpty ? job.companyName.trim() : "Company";
          final initial = compName.isNotEmpty ? compName.substring(0, 1).toUpperCase() : "J";

          parsed.add({
            "id": job.id,
            "title": job.title.trim().isNotEmpty ? job.title.trim() : "Work From Home Opening",
            "company": compName,
            "type": job.employmentType ?? "Work From Home",
            "salary": job.formattedSalary.isNotEmpty ? job.formattedSalary : "Competitive",
            "logoText": initial,
            "logoColor": accentColors[i % accentColors.length],
            "raw": job.toJson(),
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
      debugPrint("WorkFromHomePage fetch error: $e");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeJobs = _dynamicJobs;
    final filteredJobs = _selectedFilter == 0
        ? activeJobs
        : activeJobs
            .where((job) => (job["type"] ?? "").toString().toLowerCase().contains(filters[_selectedFilter].toLowerCase()))
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
          "Work From Home",
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
                      Icons.home_rounded,
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
                          "${filteredJobs.length} WFH jobs available",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Work from the comfort of your home",
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

            // ── FILTER CHIPS ──────────────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
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
                        filters[index],
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
                      child: CircularProgressIndicator(),
                    )
                  : filteredJobs.isEmpty
                      ? const Center(
                          child: Text(
                            "No Work From Home Jobs Found",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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
                            return _wfhJobCard(
                              context: context,
                              title: (job["title"] ?? "Work From Home Opening").toString(),
                              company: (job["company"] ?? "Company").toString(),
                              type: (job["type"] ?? "Work From Home").toString(),
                              salary: (job["salary"] ?? "Competitive").toString(),
                              logoText: (job["logoText"] ?? "W").toString(),
                              logoColor: (job["logoColor"] is Color) ? job["logoColor"] as Color : AppColors.primary,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── WFH JOB CARD HELPER ─────────────────────────────────
  Widget _wfhJobCard({
    required BuildContext context,
    required String title,
    required String company,
    required String type,
    required String salary,
    required String logoText,
    required Color logoColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkFromHomeDetailsPage(
              title: title,
              company: company,
              type: type,
              salary: salary,
              logoText: logoText,
              logoColor: logoColor,
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
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.currency_rupee_rounded,
                        size: 13,
                        color: AppColors.warning,
                      ),
                      Text(
                        salary.replaceAll("₹", ""),
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