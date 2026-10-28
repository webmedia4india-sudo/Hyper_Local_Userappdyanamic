import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applicationtimelinepage.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';
import 'package:hyper_local/Pages/homepage.dart';
import 'package:hyper_local/Pages/recommendedjpbpage.dart';
import 'package:hyper_local/Pages/profilepage.dart';
import 'package:hyper_local/models/job/job_application_model.dart';
import 'package:hyper_local/services/job_application_service.dart';
import 'package:hyper_local/utils/session_manager.dart';
import '../utils/app_colors.dart';

class ApplicationTrackerPage extends StatefulWidget {
  const ApplicationTrackerPage({super.key});

  @override
  State<ApplicationTrackerPage> createState() =>
      _ApplicationTrackerPageState();
}

class _ApplicationTrackerPageState extends State<ApplicationTrackerPage> {
  int _selectedTab = 0;

  // Bottom nav: "History" tab (index 3) active since we're on this page
  int _selectedIndex = 3;

  // ── SEARCH CONTROLLER & QUERY ───────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Dynamic Applications Data from Backend API
  List<JobApplicationModel> _apiApplications = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Status tabs matching backend API statuses
  final List<String> _tabs = const [
    "All",
    "Applied",
    "Under Review",
    "Shortlisted",
    "Interview",
    "Selected",
    "Rejected",
    "Withdrawn",
  ];

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userDetails = await SessionManager.getUserDetails();
      final userId = (userDetails['id'] is int)
          ? userDetails['id'] as int
          : int.tryParse(userDetails['id']?.toString() ?? '0') ?? 0;

      if (userId == 0) {
        if (mounted) {
          setState(() {
            _apiApplications = [];
            _isLoading = false;
            _errorMessage = "Please log in to view your job applications.";
          });
        }
        return;
      }

      final apps = await JobApplicationService().getUserApplications(userId);

      if (mounted) {
        setState(() {
          _apiApplications = apps;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching applications: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load applications. Please try again.";
        });
      }
    }
  }

  List<JobApplicationModel> get _filteredApplications {
    List<JobApplicationModel> list = _apiApplications;

    // Tab based status filter
    if (_selectedTab != 0) {
      final tabName = _tabs[_selectedTab].toLowerCase().replaceAll(' ', '_');
      list = list.where((app) {
        final st = app.applicationStatus.toLowerCase().trim();
        if (tabName == 'under_review') return st == 'under_review' || st == 'viewed';
        if (tabName == 'interview') return st == 'interview' || st.contains('interview');
        return st == tabName;
      }).toList();
    }

    // Search query filter (title or company)
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((app) {
        final title = app.jobTitle.toLowerCase();
        final company = app.companyName.toLowerCase();
        return title.contains(query) || company.contains(query);
      }).toList();
    }

    return list;
  }

  // Get next candidate action label based on rules
  String _getActionLabel(String status) {
    switch (status.toLowerCase().trim()) {
      case 'applied':
        return "View Details";
      case 'under_review':
      case 'viewed':
        return "Under Review";
      case 'shortlisted':
        return "View Status";
      case 'interview':
        return "Join Interview";
      case 'selected':
        return "Complete Joining";
      case 'rejected':
        return "Browse Jobs";
      case 'withdrawn':
        return "Withdrawn";
      default:
        return "View Status";
    }
  }

  // Trigger candidate action according to rules
  void _onActionPressed(JobApplicationModel app) {
    final status = app.applicationStatus.toLowerCase().trim();

    if (status == 'rejected') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RecommendedJobPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApplicationTimelinePage(
            applicationId: app.applicationId,
            title: app.jobTitle,
            company: app.companyName,
            logoText: app.logoLetter,
            logoColor: app.logoColor,
            appliedOn: app.formattedAppliedDate,
            status: app.statusLabel,
            statusColor: app.statusColor,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredApplications;

    return Scaffold(
      extendBody: true,
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
          "Applications",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchApplications,
        color: AppColors.primary,
        child: Column(
          children: [
            const SizedBox(height: 6),

            // ── SEARCH BAR ───────────────────────────────────
            _searchBar(),

            const SizedBox(height: 8),

            // ── TAB ROW WITH UNDERLINE (HORIZONTALLY SCROLLABLE) ──
            _tabRow(),

            const SizedBox(height: 8),

            // ── APPLICATIONS LIST ────────────────────────────
            Expanded(
              child: _buildBody(filtered),
            ),
          ],
        ),
      ),

      // ── BOTTOM NAVIGATION BAR (FLOATING STYLE WITH GLASSMORPHISM OPACITY) ──
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _bottomNavItem(
                        Icons.layers_rounded,
                        "Cards",
                        0,
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                      _bottomNavItem(
                        Icons.space_dashboard_rounded,
                        "Dashboard",
                        1,
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardPage(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                      _bottomNavItem(
                        Icons.work_outline_rounded,
                        "Jobs",
                        2,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RecommendedJobPage(),
                            ),
                          );
                        },
                      ),
                      _bottomNavItem(
                        Icons.description_outlined,
                        "History",
                        3,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ApplicationTrackerPage(),
                            ),
                          );
                        },
                      ),
                      _bottomNavItem(
                        Icons.person_outline_rounded,
                        "Profile",
                        4,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<JobApplicationModel> filtered) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchApplications,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Retry", style: TextStyle(color: AppColors.buttonText)),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchQuery.trim().isNotEmpty) ...[
                    const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    const Text(
                      "No matching applications found",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Try searching with a different job title or company",
                      style: TextStyle(fontSize: 12.5, color: AppColors.textHint),
                    ),
                  ] else ...[
                    const Icon(Icons.assignment_outlined, size: 48, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    const Text(
                      "No applications here yet.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Jobs you apply for will appear in this tracker",
                      style: TextStyle(fontSize: 12.5, color: AppColors.textHint),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 76),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _applicationCard(filtered[index]),
    );
  }

  // ── SEARCH BAR WIDGET ─────────────────────────────────────
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: "Search by job title or company",
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 18),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = "";
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          ),
        ),
      ),
    );
  }

  // ── SCROLLABLE TAB ROW WITH ACTIVE INDICATOR ──
  Widget _tabRow() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _selectedTab == index;
            return Padding(
              padding: const EdgeInsets.only(right: 22),
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedTab = index;
                }),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      height: 2.5,
                      width: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── SINGLE APPLICATION CARD WITH ACTION RULES BUTTON ──
  Widget _applicationCard(JobApplicationModel app) {
    final status = app.statusLabel;
    final statusColor = app.statusColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              // Company logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: app.logoColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    app.logoLetter,
                    style: const TextStyle(
                      color: AppColors.buttonText,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title / company / applied date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.jobTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      app.companyName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      app.formattedAppliedDate,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge — tap opens the Application Timeline page
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplicationTimelinePage(
                        applicationId: app.applicationId,
                        title: app.jobTitle,
                        company: app.companyName,
                        logoText: app.logoLetter,
                        logoColor: app.logoColor,
                        appliedOn: app.formattedAppliedDate,
                        status: app.statusLabel,
                        statusColor: app.statusColor,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 20, color: AppColors.divider),

          // Next Action Button matching status rules
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Status: $status",
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () => _onActionPressed(app),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: const Size(80, 32),
                ),
                child: Text(
                  _getActionLabel(app.applicationStatus),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // ── BOTTOM NAV ITEM HELPER (FULLY ANIMATED WITH HEADER GRADIENT ON ACTIVE) ──
  Widget _bottomNavItem(
    IconData icon,
    String label,
    int index, {
    VoidCallback? onTap,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _selectedIndex = index);
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? GenZ.headerGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: GenZ.purple.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 1.0 + (value * 0.15),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                );
              },
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}