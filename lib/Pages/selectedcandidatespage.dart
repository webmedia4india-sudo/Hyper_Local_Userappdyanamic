// C:\flutter-projects\hyper_local\lib\Pages\selectedcandidatespage.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// ---------------- Model ----------------
enum CandidateDecision { shortlisted, rejected }

class ReviewedCandidate {
  final String name;
  final String jobTitle;
  final String imageUrl;
  final int matchScore;
  final CandidateDecision decision;
  final String reviewedOn;
  final List<String> technology;

  ReviewedCandidate({
    required this.name,
    required this.jobTitle,
    required this.imageUrl,
    required this.matchScore,
    required this.decision,
    required this.reviewedOn,
    required this.technology,
  });
}

// ---------------- Selected Candidates Page ----------------
class SelectedCandidatesPage extends StatefulWidget {
  const SelectedCandidatesPage({super.key});

  @override
  State<SelectedCandidatesPage> createState() => _SelectedCandidatesPageState();
}

class _SelectedCandidatesPageState extends State<SelectedCandidatesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── STATIC DATA (replace with real state/provider later) ──
  final List<ReviewedCandidate> _candidates = [
    ReviewedCandidate(
      name: "Rohit Sharma",
      jobTitle: "Flutter Developer",
      imageUrl:
          "https://ui-avatars.com/api/?name=Rohit+Sharma&background=1E3AE2&color=fff&size=400",
      matchScore: 92,
      decision: CandidateDecision.shortlisted,
      reviewedOn: "Today, 10:24 AM",
      technology: ["Flutter", "Dart", "Firebase"],
    ),
    ReviewedCandidate(
      name: "Priya Deshmukh",
      jobTitle: "Flutter Developer",
      imageUrl:
          "https://ui-avatars.com/api/?name=Priya+Deshmukh&background=F48FB1&color=fff&size=400",
      matchScore: 95,
      decision: CandidateDecision.shortlisted,
      reviewedOn: "Today, 9:50 AM",
      technology: ["Flutter", "Kotlin", "REST API"],
    ),
    ReviewedCandidate(
      name: "Amit Verma",
      jobTitle: "Frontend Developer",
      imageUrl:
          "https://ui-avatars.com/api/?name=Amit+Verma&background=FF8A75&color=fff&size=400",
      matchScore: 78,
      decision: CandidateDecision.rejected,
      reviewedOn: "Yesterday, 5:12 PM",
      technology: ["React", "JavaScript", "MongoDB"],
    ),
    ReviewedCandidate(
      name: "Sneha Patil",
      jobTitle: "Backend Developer",
      imageUrl:
          "https://ui-avatars.com/api/?name=Sneha+Patil&background=A6D608&color=1A1A1A&size=400",
      matchScore: 87,
      decision: CandidateDecision.rejected,
      reviewedOn: "Yesterday, 3:40 PM",
      technology: ["Angular", "Node.js", "MySQL"],
    ),
    ReviewedCandidate(
      name: "Karan Joshi",
      jobTitle: "Backend Developer",
      imageUrl:
          "https://ui-avatars.com/api/?name=Karan+Joshi&background=3DDC97&color=1A1A1A&size=400",
      matchScore: 83,
      decision: CandidateDecision.shortlisted,
      reviewedOn: "2 days ago",
      technology: ["Java", "Spring Boot", "AWS"],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ReviewedCandidate> get _shortlisted =>
      _candidates.where((c) => c.decision == CandidateDecision.shortlisted).toList();

  List<ReviewedCandidate> get _rejected =>
      _candidates.where((c) => c.decision == CandidateDecision.rejected).toList();

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
          "Candidates Status",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryStrip(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCandidateList(_shortlisted, CandidateDecision.shortlisted),
                _buildCandidateList(_rejected, CandidateDecision.rejected),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary Strip (counts) ─────────────────────────────
  Widget _buildSummaryStrip() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryStat(
              icon: Icons.check_circle_rounded,
              value: "${_shortlisted.length}",
              label: "Shortlisted",
            ),
          ),
          Container(width: 1, height: 36, color: Colors.white.withOpacity(0.25)),
          Expanded(
            child: _summaryStat(
              icon: Icons.cancel_rounded,
              value: "${_rejected.length}",
              label: "Rejected",
            ),
          ),
          Container(width: 1, height: 36, color: Colors.white.withOpacity(0.25)),
          Expanded(
            child: _summaryStat(
              icon: Icons.people_alt_rounded,
              value: "${_candidates.length}",
              label: "Total Reviewed",
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryStat({required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10.5, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ── Tab Bar ─────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 16),
                const SizedBox(width: 6),
                Text("Shortlisted (${_shortlisted.length})"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.highlight_off_rounded, size: 16),
                const SizedBox(width: 6),
                Text("Rejected (${_rejected.length})"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Candidate List (per tab) ────────────────────────────
  Widget _buildCandidateList(List<ReviewedCandidate> list, CandidateDecision decision) {
    if (list.isEmpty) {
      return _buildEmptyState(decision);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      itemCount: list.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildCandidateCard(list[index]),
      ),
    );
  }

  Widget _buildEmptyState(CandidateDecision decision) {
    final isShortlisted = decision == CandidateDecision.shortlisted;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isShortlisted ? AppColors.success : AppColors.error).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isShortlisted ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
                size: 44,
                color: isShortlisted ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isShortlisted ? "No candidates shortlisted yet" : "No candidates rejected yet",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Review candidates to see them listed here",
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Candidate Card ───────────────────────────────────────
  Widget _buildCandidateCard(ReviewedCandidate candidate) {
    final isShortlisted = candidate.decision == CandidateDecision.shortlisted;
    final statusColor = isShortlisted ? AppColors.success : AppColors.error;

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
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      candidate.imageUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 52,
                        height: 52,
                        color: AppColors.primaryLight.withOpacity(0.2),
                        child: const Icon(Icons.person, color: AppColors.primary),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                      child: Icon(
                        isShortlisted ? Icons.check_rounded : Icons.close_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      candidate.jobTitle,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate.reviewedOn,
                      style: const TextStyle(fontSize: 11, color: AppColors.textHint),
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
                    Icon(
                      isShortlisted ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isShortlisted ? "Shortlisted" : "Rejected",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                "${candidate.matchScore}% Match",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 2,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 6,
                  runSpacing: 6,
                  children: candidate.technology.take(3).map((tech) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tech,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}