// C:\flutter-projects\hyper_local\lib\Pages\candidateapplicationpage.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// ---------------- Model ----------------
enum ApplicationStatus { pending, shortlisted, interview, rejected }

class JobApplication {
  final String jobTitle;
  final String company;
  final String location;
  final String salary;
  final String appliedOn;
  final String logoText;
  final Color logoColor;
  final ApplicationStatus status;

  JobApplication({
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.salary,
    required this.appliedOn,
    required this.logoText,
    required this.logoColor,
    required this.status,
  });
}

// ---------------- Candidate Application Page ----------------
class CandidateApplicationPage extends StatefulWidget {
  const CandidateApplicationPage({super.key});

  @override
  State<CandidateApplicationPage> createState() => _CandidateApplicationPageState();
}

class _CandidateApplicationPageState extends State<CandidateApplicationPage> {
  String _selectedFilter = "All";

  final List<String> _filters = ["All", "Pending", "Shortlisted", "Interview", "Rejected"];

  final List<JobApplication> _applications = [
    JobApplication(
      jobTitle: "Flutter Developer",
      company: "Zoho Corporation",
      location: "Chennai, TN",
      salary: "₹40,000 - ₹60,000",
      appliedOn: "2 days ago",
      logoText: "Z",
      logoColor: const Color(0xFFE23744),
      status: ApplicationStatus.interview,
    ),
    JobApplication(
      jobTitle: "Backend Developer",
      company: "TCS",
      location: "Mumbai, MH",
      salary: "₹38,000 - ₹55,000",
      appliedOn: "3 days ago",
      logoText: "T",
      logoColor: AppColors.primary,
      status: ApplicationStatus.shortlisted,
    ),
    JobApplication(
      jobTitle: "Frontend Developer",
      company: "Infosys",
      location: "Pune, MH",
      salary: "₹35,000 - ₹50,000",
      appliedOn: "5 days ago",
      logoText: "I",
      logoColor: const Color(0xFF007CC3),
      status: ApplicationStatus.pending,
    ),
    JobApplication(
      jobTitle: "Full Stack Developer",
      company: "Wipro",
      location: "Nagpur, MH",
      salary: "₹45,000 - ₹65,000",
      appliedOn: "1 week ago",
      logoText: "W",
      logoColor: AppColors.success,
      status: ApplicationStatus.rejected,
    ),
    JobApplication(
      jobTitle: "Mobile App Developer",
      company: "HCL Technologies",
      location: "Nashik, MH",
      salary: "₹42,000 - ₹58,000",
      appliedOn: "1 week ago",
      logoText: "H",
      logoColor: AppColors.coral,
      status: ApplicationStatus.pending,
    ),
  ];

  List<JobApplication> get _filteredApplications {
    if (_selectedFilter == "All") return _applications;
    final statusMap = {
      "Pending": ApplicationStatus.pending,
      "Shortlisted": ApplicationStatus.shortlisted,
      "Interview": ApplicationStatus.interview,
      "Rejected": ApplicationStatus.rejected,
    };
    return _applications.where((a) => a.status == statusMap[_selectedFilter]).toList();
  }

  int _countFor(String filter) {
    if (filter == "All") return _applications.length;
    final statusMap = {
      "Pending": ApplicationStatus.pending,
      "Shortlisted": ApplicationStatus.shortlisted,
      "Interview": ApplicationStatus.interview,
      "Rejected": ApplicationStatus.rejected,
    };
    return _applications.where((a) => a.status == statusMap[filter]).length;
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return AppColors.warning;
      case ApplicationStatus.shortlisted:
        return AppColors.primary;
      case ApplicationStatus.interview:
        return AppColors.lime == AppColors.lime ? const Color(0xFF3DDC97) : AppColors.mint;
      case ApplicationStatus.rejected:
        return AppColors.error;
    }
  }

  String _statusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return "Pending";
      case ApplicationStatus.shortlisted:
        return "Shortlisted";
      case ApplicationStatus.interview:
        return "Interview";
      case ApplicationStatus.rejected:
        return "Rejected";
    }
  }

  IconData _statusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Icons.hourglass_top_rounded;
      case ApplicationStatus.shortlisted:
        return Icons.check_circle_outline_rounded;
      case ApplicationStatus.interview:
        return Icons.event_available_rounded;
      case ApplicationStatus.rejected:
        return Icons.highlight_off_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredApplications;

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
          "My Applications",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 14),
          _buildFilterChips(),
          const SizedBox(height: 6),
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildApplicationCard(filteredList[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Filter Chips ─────────────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.25) : AppColors.scaffoldBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${_countFor(filter)}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Empty State ──────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description_outlined, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            "No applications found",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            "Jobs you apply to will show up here",
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Application Card ─────────────────────────────
  Widget _buildApplicationCard(JobApplication app) {
    final statusColor = _statusColor(app.status);

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: app.logoColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    app.logoText,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.jobTitle,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      app.company,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textHint),
                        const SizedBox(width: 2),
                        Text(
                          app.location,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(app.status), size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      _statusLabel(app.status),
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: statusColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                app.salary,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
              const Spacer(),
              const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                "Applied ${app.appliedOn}",
                style: const TextStyle(fontSize: 11.5, color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}