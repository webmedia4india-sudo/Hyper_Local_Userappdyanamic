import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applicationtimelinepage.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';
import 'package:hyper_local/Pages/homepage.dart';
import 'package:hyper_local/Pages/recommendedjpbpage.dart';
import 'package:hyper_local/Pages/profilepage.dart';
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

  // Updated tabs to support all statuses requested
  final List<String> _tabs = const [
    "All",
    "Applied",
    "Viewed",
    "Shortlisted",
    "Interview Scheduled",
    "Offer Released",
    "Selected",
    "Rejected",
    "Joined",
  ];

  // ── STATIC APPLICATIONS DATA (Technology companies) ────
  static final List<Map<String, dynamic>> _applications = [
    {
      "title": "Junior Software Developer",
      "company": "Google",
      "appliedOn": "12 May 2026",
      "status": "Applied",
      "statusColor": const Color(0xFF3B82F6), // Blue
      "logoText": "G",
      "logoColor": const Color(0xFF4285F4),
    },
    {
      "title": "Technical Support Engineer",
      "company": "Microsoft",
      "appliedOn": "11 May 2026",
      "status": "Viewed",
      "statusColor": const Color(0xFF8B5CF6), // Purple
      "logoText": "M",
      "logoColor": const Color(0xFF00A4EF),
    },
    {
      "title": "QA Analyst",
      "company": "Amazon",
      "appliedOn": "10 May 2026",
      "status": "Shortlisted",
      "statusColor": const Color(0xFF10B981), // Emerald
      "logoText": "A",
      "logoColor": const Color(0xFFFF9900),
    },
    {
      "title": "Associate Software Developer",
      "company": "IBM",
      "appliedOn": "09 May 2026",
      "status": "Interview Scheduled",
      "statusColor": const Color(0xFFD97706), // Orange
      "logoText": "I",
      "logoColor": const Color(0xFF1F70C1),
    },
    {
      "title": "React Frontend Developer",
      "company": "Adobe",
      "appliedOn": "08 May 2026",
      "status": "Offer Released",
      "statusColor": const Color(0xFFEC4899), // Pink
      "logoText": "A",
      "logoColor": const Color(0xFFFF0000),
    },
    {
      "title": "UI/UX Designer",
      "company": "Zoho Corporation",
      "appliedOn": "07 May 2026",
      "status": "Selected",
      "statusColor": const Color(0xFF059669), // Green
      "logoText": "Z",
      "logoColor": const Color(0xFFE11D48),
    },
    {
      "title": "Flutter Developer",
      "company": "Salesforce",
      "appliedOn": "06 May 2026",
      "status": "Rejected",
      "statusColor": const Color(0xFFEF4444), // Red
      "logoText": "S",
      "logoColor": const Color(0xFF00A1E0),
    },
    {
      "title": "Software QA Engineer",
      "company": "Oracle",
      "appliedOn": "05 May 2026",
      "status": "Joined",
      "statusColor": const Color(0xFF047857), // Forest Green
      "logoText": "O",
      "logoColor": const Color(0xFFF80000),
    }
  ];

  List<Map<String, dynamic>> get _filteredApplications {
    List<Map<String, dynamic>> list = _applications;

    // Tab based status filter
    if (_selectedTab != 0) {
      final tabName = _tabs[_selectedTab];
      list = list
          .where((app) =>
              app["status"].toString().toLowerCase() == tabName.toLowerCase())
          .toList();
    }

    // Search query filter (title or company)
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((app) {
        final title = app["title"].toString().toLowerCase();
        final company = app["company"].toString().toLowerCase();
        return title.contains(query) || company.contains(query);
      }).toList();
    }

    return list;
  }

  // Get next candidate action label based on rules
  String _getActionLabel(String status) {
    switch (status) {
      case "Applied":
        return "View application";
      case "Viewed":
        return "Wait for employer";
      case "Shortlisted":
        return "View update";
      case "Interview Scheduled":
        return "Join or get directions";
      case "Offer Released":
        return "Review offer";
      case "Selected":
        return "Complete joining";
      case "Rejected":
        return "View other jobs";
      case "Joined":
        return "Submit feedback";
      default:
        return "View Update";
    }
  }

  // Trigger candidate action according to rules
  void _onActionPressed(Map<String, dynamic> app) {
    final status = app["status"] as String;
    final title = app["title"] as String;
    final company = app["company"] as String;

    if (status == "Applied") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Application: $title"),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Submitted Credentials:", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Name: Gauri Salunkhe"),
                Text("Email: gauri@example.com"),
                Text("Status: Applied (Pending HR Review)"),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Close"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        },
      );
    } else if (status == "Viewed") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("HR at $company is currently reviewing your profile. Please check back later.")),
      );
    } else if (status == "Shortlisted") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Shortlist Update"),
            content: Text("Congrats! You cleared the initial document screening for $title at $company. Interview timings will update here soon."),
            actions: [
              TextButton(
                child: const Text("Got it"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        },
      );
    } else if (status == "Interview Scheduled") {
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Interview Portal Options"),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Joining virtual Google Meet room call...")),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.video_call_rounded, color: Colors.blue),
                    SizedBox(width: 12),
                    Text("Join Online Video Call"),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Opening navigation routing maps to office...")),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.directions_rounded, color: Colors.green),
                    SizedBox(width: 12),
                    Text("Get Directions to Office"),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } else if (status == "Offer Released") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Offer Letter - $company"),
            content: const Text("We are pleased to offer you the position. Base Salary: ₹55,000/month. Please review the terms and sign onboarding documents to accept."),
            actions: [
              TextButton(
                child: const Text("Decline"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Offer Letter accepted! Status updated to Selected.")),
                  );
                },
                child: const Text("Accept Offer"),
              )
            ],
          );
        },
      );
    } else if (status == "Selected") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Complete Joining Onboarding"),
            content: const Text("Please submit your bank details and PAN/Aadhar copy to the coordinator to complete onboarding process."),
            actions: [
              TextButton(
                child: const Text("Close"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        },
      );
    } else if (status == "Rejected") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RecommendedJobPage()),
      );
    } else if (status == "Joined") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Submit Hiring Feedback"),
            content: const Text("Please rate your onboarding experience. How satisfied were you with the HR coordinators?"),
            actions: [
              TextButton(
                child: const Text("Submit 5 Stars"),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Thank you for your valuable feedback!")),
                  );
                },
              )
            ],
          );
        },
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
      body: Column(
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
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      "No applications here yet.",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 76),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _applicationCard(filtered[index]),
                  ),
          ),
        ],
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
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
  Widget _applicationCard(Map<String, dynamic> app) {
    final status = app["status"] as String;
    final statusColor = app["statusColor"] as Color;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                  color: app["logoColor"] as Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    app["logoText"] as String,
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
                      app["title"] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      app["company"] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Applied on ${app["appliedOn"]}",
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
                        title: app["title"] as String,
                        company: app["company"] as String,
                        logoText: app["logoText"] as String,
                        logoColor: app["logoColor"] as Color,
                        appliedOn: app["appliedOn"] as String,
                        status: app["status"] as String,
                        statusColor: app["statusColor"] as Color,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
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
                "Next Step: ${status == 'Viewed' ? 'Wait for HR' : 'Action Required'}",
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () => _onActionPressed(app),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(80, 32),
                ),
                child: Text(
                  _getActionLabel(status),
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
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
                    color: GenZ.purple.withOpacity(0.25),
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
                  scale: 1 + (value * 0.15),
                  child: child,
                );
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? Colors.white : AppColors.unselected,
                  size: 23,
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 220),
                        opacity: isSelected ? 1 : 0,
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}