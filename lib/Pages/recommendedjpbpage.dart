import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applicationtrackerpage.dart';
import 'package:hyper_local/Pages/homepage.dart';
import 'package:hyper_local/Pages/jobdescriptipnpage.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';
import 'package:hyper_local/Pages/profilepage.dart';
import '../utils/app_colors.dart';

class RecommendedJobPage extends StatefulWidget {
  const RecommendedJobPage({super.key});

  @override
  State<RecommendedJobPage> createState() => _RecommendedJobPageState();
}

class _RecommendedJobPageState extends State<RecommendedJobPage> {
  int _selectedIndex = 2; // "Jobs" tab active since we're already on this page

  // ── SEARCH STATE ────────────────────────────────────────
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // ── STATIC JOB DATA ────────────────────────────────────
  static final List<Map<String, dynamic>> _jobs = [
    {
      "title": "Frontend Developer",
      "company": "Infosys",
      "distance": "3.2 km",
      "rating": 4.4,
      "salary": "₹35,000 - ₹50,000",
      "logoText": "F",
      "logoColor": const Color(0xFF007CC3),
      "status": "Active",
    },
    {
      "title": "Backend Developer",
      "company": "TCS",
      "distance": "2.9 km",
      "rating": 4.2,
      "salary": "₹38,000 - ₹55,000",
      "logoText": "B",
      "logoColor": AppColors.primary,
      "status": "Active",
    },
    {
      "title": "Flutter Developer",
      "company": "Zoho Corporation",
      "distance": "1.8 km",
      "rating": 4.6,
      "salary": "₹40,000 - ₹60,000",
      "logoText": "F",
      "logoColor": const Color(0xFFE23744),
      "status": "Active",
    },
    {
      "title": "Full Stack Developer",
      "company": "Wipro",
      "distance": "4.1 km",
      "rating": 4.1,
      "salary": "₹45,000 - ₹65,000",
      "logoText": "F",
      "logoColor": AppColors.success,
      "status": "Active",
    },
  ];

  // ── FILTERED LIST BASED ON SEARCH QUERY ────────────────
  List<Map<String, dynamic>> get _filteredJobs {
    if (_searchQuery.trim().isEmpty) return _jobs;
    final query = _searchQuery.toLowerCase();
    return _jobs.where((job) {
      final title = (job["title"] as String).toLowerCase();
      final company = (job["company"] as String).toLowerCase();
      return title.contains(query) || company.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = "";
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredJobs = _filteredJobs;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (_isSearching) {
              _stopSearch();
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icon(
            _isSearching ? Icons.arrow_back : Icons.arrow_back,
            color: AppColors.buttonText,
          ),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(
                  color: AppColors.buttonText,
                  fontSize: 15.5,
                ),
                cursorColor: AppColors.buttonText,
                decoration: InputDecoration(
                  hintText: "Search by job title, company...",
                  hintStyle: TextStyle(
                    color: AppColors.buttonText.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              )
            : const Text(
                "Recommended Jobs",
                style: TextStyle(
                  color: AppColors.buttonText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          if (_isSearching && _searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  _searchQuery = "";
                  _searchController.clear();
                });
              },
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.buttonText,
              ),
            )
          else
            IconButton(
              onPressed: _isSearching ? _stopSearch : _startSearch,
              icon: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                color: AppColors.buttonText,
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          // Heading
          Text(
            _isSearching && _searchQuery.isNotEmpty
                ? "${filteredJobs.length} Results Found"
                : "220+ Jobs Found",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Near Mumbai (10 km)",
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Job cards or empty state
          if (filteredJobs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No jobs found",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Try searching with a different keyword",
                    style: TextStyle(fontSize: 12.5, color: AppColors.textHint),
                  ),
                ],
              ),
            )
          else
            ...filteredJobs.map(
              (job) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _jobCard(context, job),
              ),
            ),
          const SizedBox(height: 70),
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

  // ── SINGLE JOB CARD (NOW FULLY TAPPABLE) ────────────────────────────────────
  Widget _jobCard(BuildContext context, Map<String, dynamic> job) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobDescriptionPage(
                companyName: job["company"] as String,
                jobTitle: job["title"] as String,
                companyFullName: "${job["company"]} Pvt. Ltd.",
                rating: job["rating"] as double,
                distance: job["distance"] as String,
                salary: job["salary"] as String,
                logoText: job["logoText"] as String,
                logoColor: job["logoColor"] as Color,
              ),
            ),
          );
        },
        child: Container(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: job["logoColor"] as Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    job["logoText"] as String,
                    style: const TextStyle(
                      color: AppColors.buttonText,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title / company / distance / salary
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job["title"] as String,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          job["company"] as String,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.textHint,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          job["distance"] as String,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "${job["rating"]}",
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      job["salary"] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Status pill + trailing menu
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job["status"] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ],
          ),
        ),
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
            // Icon scales up smoothly when selected
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

            // Label fades/expands in only when selected — classic
            // "pill" bottom-nav animation
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