import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applicationtrackerpage.dart';
import '../utils/app_colors.dart';

/// Saved Jobs page — matches reference design:
/// colored AppBar, a "Saved Jobs / Recently Viewed" segmented tab
/// control, and a list of job cards with logo, title, company,
/// distance, rating, salary, a 3-dot menu, and a bookmark icon.
class SavedJobPage extends StatefulWidget {
  const SavedJobPage({super.key});

  @override
  State<SavedJobPage> createState() => _SavedJobPageState();
}

class _SavedJobPageState extends State<SavedJobPage> {
  int _selectedTab = 0; // 0 = Saved Jobs, 1 = Recently Viewed

  // ── SEARCH STATE ────────────────────────────────────────
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // ── STATIC SAVED JOBS (Developer roles) ─────────────────
  static final List<Map<String, dynamic>> _savedJobs = [
    {
      "title": "Frontend Developer",
      "company": "Infosys",
      "distance": "3.2 km",
      "rating": 4.4,
      "salary": "₹35,000 - ₹50,000",
      "logoText": "I",
      "logoColor": const Color(0xFF007CC3),
    },
    {
      "title": "Backend Developer",
      "company": "TCS",
      "distance": "2.9 km",
      "rating": 4.2,
      "salary": "₹38,000 - ₹55,000",
      "logoText": "T",
      "logoColor": const Color(0xFF0F62FE),
    },
    {
      "title": "Flutter Developer",
      "company": "Zoho Corporation",
      "distance": "1.8 km",
      "rating": 4.6,
      "salary": "₹40,000 - ₹60,000",
      "logoText": "Z",
      "logoColor": const Color(0xFFE23744),
    },
    {
      "title": "Full Stack Developer",
      "company": "Wipro",
      "distance": "4.1 km",
      "rating": 4.1,
      "salary": "₹45,000 - ₹65,000",
      "logoText": "W",
      "logoColor": const Color(0xFF341E5F),
    },
  ];

  // ── STATIC RECENTLY VIEWED JOBS (Developer roles) ──────
  static final List<Map<String, dynamic>> _recentlyViewedJobs = [
    {
      "title": "Angular Developer",
      "company": "Tech Mahindra",
      "distance": "2.3 km",
      "rating": 4.0,
      "salary": "₹32,000 - ₹48,000",
      "logoText": "T",
      "logoColor": const Color(0xFFD8262F),
    },
    {
      "title": "React Native Developer",
      "company": "HCL Technologies",
      "distance": "3.6 km",
      "rating": 4.3,
      "salary": "₹40,000 - ₹58,000",
      "logoText": "H",
      "logoColor": const Color(0xFF0057A6),
    },
    {
      "title": "Node.js Developer",
      "company": "Capgemini",
      "distance": "1.5 km",
      "rating": 4.2,
      "salary": "₹36,000 - ₹52,000",
      "logoText": "C",
      "logoColor": const Color(0xFF0070AD),
    },
  ];

  // ── FILTERED LIST BASED ON SEARCH QUERY ────────────────
  List<Map<String, dynamic>> get _filteredJobs {
    final baseJobs = _selectedTab == 0 ? _savedJobs : _recentlyViewedJobs;
    if (_searchQuery.trim().isEmpty) return baseJobs;
    final query = _searchQuery.toLowerCase();
    return baseJobs.where((job) {
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
    final jobs = _filteredJobs;

    return Scaffold(
      backgroundColor: AppColors.background,
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
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
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
                "Saved Jobs",
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
              icon: const Icon(Icons.close_rounded, color: AppColors.buttonText),
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
      body: Column(
        children: [
          const SizedBox(height: 16),

          // ── SEGMENTED TAB CONTROL ────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _segmentedTabs(),
          ),
          const SizedBox(height: 16),

          // ── JOB LIST ──────────────────────────────────────
          Expanded(
            child: jobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isSearching && _searchQuery.isNotEmpty) ...[
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
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textHint,
                            ),
                          ),
                        ] else
                          const Text(
                            "Nothing to show here yet.",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: jobs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _jobCard(jobs[index]),
                  ),
          ),
        ],
      ),
    );
  }

  // ── "Saved Jobs" / "Recently Viewed" SEGMENTED CONTROL ──
  Widget _segmentedTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.socialIconBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _tabButton("Saved Jobs", 0)),
          Expanded(child: _tabButton("Recently Viewed", 1)),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.background : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── SINGLE JOB CARD ────────────────────────────────────
  Widget _jobCard(Map<String, dynamic> job) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company logo — solid letter avatar (no network calls, so it
          // never fails/crashes due to internet or CORS issues)
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

          // Title / company / distance / rating / salary
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job["title"] as String,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  "${job["company"]} · ${job["distance"]}",
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 15, color: AppColors.warning),
                    const SizedBox(width: 2),
                    Text(
                      "${job["rating"]}",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job["salary"] as String,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3-dot menu + bookmark icon
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ApplicationTrackerPage(),
                    ),
                  );
                },
                child: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textHint),
              ),
              const SizedBox(height: 22),
              InkWell(
                onTap: () {},
                child: const Icon(Icons.bookmark_rounded, size: 18, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}