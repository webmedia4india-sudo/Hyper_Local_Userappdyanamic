import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// ── THEME COLORS (matches AppColors blue palette) ──
class GenZ {
  static const Color purple = Color(0xFF1E3AE2);
  static const Color purpleDark = Color(0xFF1526A8);
  static const Color purpleDeep = Color(0xFF0D1B7A);
  static const Color lavender = Color(0xFF5C74F0);
  static const Color lavenderSoft = Color(0xFFDCE3FF);
  static const Color pink = Color(0xFFF48FB1);
  static const Color pinkSoft = Color(0xFFFFD6E7);
  static const Color coral = Color(0xFFFF8A75);
  static const Color coralSoft = Color(0xFFFFD9CF);
  static const Color mint = Color(0xFF3DDC97);
  static const Color mintSoft = Color(0xFFC8F7E6);
}

class JobNearMapPage extends StatefulWidget {
  const JobNearMapPage({super.key});

  @override
  State<JobNearMapPage> createState() => _JobNearMapPageState();
}

class _JobNearMapPageState extends State<JobNearMapPage> {
  // State variables for search, radius, heatmap, and filters
  int _selectedJobIndex = 0;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  double _maxTravelRadius = 8.0; // 5.3 Radius selection (default 8 km)
  bool _isHeatmapView = false; // 5.4 Local hiring heatmap mode toggle
  bool _isSearchingThisArea = false; // Search this area state indicator

  // Entry Animations State
  bool _animateCardIn = false;
  bool _animateHeaderIn = false;

  // Applied & Saved job IDs trackers (Business rules: cannot apply twice)
  final Set<String> _appliedJobIds = {};
  final Set<String> _savedJobIds = {};

  // Filters State (5.2 filters)
  String _filterExperience = "All";
  String _filterJobType = "All";
  double _filterMinSalary = 10000;
  bool _filterOnlyUrgent = false;
  bool _filterOnlyVerified = false;

  // Candidate coordinates (center of map)
  final double _candidateLat = 19.0760;
  final double _candidateLng = 72.8777;

  // Mock list of IT companies (containing all 5.1/7 required details & fields)
  final List<Map<String, dynamic>> nearbyJobs = [
    {
      "id": "tcs_powai",
      "title": "Associate Software Developer",
      "company": "TCS",
      "logoText": "T",
      "logoColor": const Color(0xFF1E3A8A),
      "salary": "₹35,000 - ₹50,000",
      "minSalaryVal": 35000,
      "experience": "0-1 yr",
      "employmentType": "Full-time",
      "location": "Powai, Mumbai",
      "postedTime": "2 hours ago",
      "isVerified": true,
      "isUrgent": true,
      "lat": 19.1176,
      "lng": 72.9060,
      "dx": 0.60,
      "dy": 0.38,
      // 7. Job details fields
      "description":
          "TCS is looking for an Associate Software Developer to help design, develop, and maintain software solutions. You will work within agile teams to deliver premium web and mobile applications.",
      "responsibilities": [
        "Write clean, scalable, and maintainable software code.",
        "Collaborate with senior developers and system architects.",
        "Perform testing and debugging to maintain product reliability.",
      ],
      "requiredSkills": ["Java", "SQL", "Git", "Flutter"],
      "qualification": "B.E. / B.Tech in CSE / IT",
      "incentives": "Annual performance bonus & healthcare benefits",
      "vacancies": 8,
      "shift": "Day Shift",
      "workingHours": "9:00 AM - 6:00 PM",
      "weeklyOff": "Saturday & Sunday",
      "benefits": "Free medical cover, cab service, gym access",
      "deadline": "August 15, 2026",
      "companyProfile":
          "Tata Consultancy Services is a global leader in IT services, consulting & business solutions.",
      "companySize": "500,000+ employees",
      "ratings": 4.2,
      "reviews": 12450,
      "isClosed": false,
      "isExpired": false,
    },
    {
      "id": "infosys_andheri",
      "title": "React Frontend Developer",
      "company": "Infosys",
      "logoText": "I",
      "logoColor": const Color(0xFF007ACC),
      "salary": "₹40,000 - ₹60,000",
      "minSalaryVal": 40000,
      "experience": "Fresher",
      "employmentType": "Full-time",
      "location": "Andheri East, Mumbai",
      "postedTime": "5 hours ago",
      "isVerified": true,
      "isUrgent": false,
      "lat": 19.1136,
      "lng": 72.8697,
      "dx": 0.32,
      "dy": 0.28,
      "description":
          "Join our frontend engineering team to build beautiful, fast, and responsive user interfaces for global enterprise platforms.",
      "responsibilities": [
        "Develop responsive UI components using React and Redux.",
        "Optimize web performance and ensure SEO best practices.",
        "Integrate RESTful APIs with frontend layout state.",
      ],
      "requiredSkills": ["React.js", "HTML5", "CSS3", "JavaScript"],
      "qualification": "BCA / MCA / B.Sc Computer Science",
      "incentives": "Project completion bonuses",
      "vacancies": 4,
      "shift": "Rotational Shift",
      "workingHours": "10:00 AM - 7:00 PM",
      "weeklyOff": "Sunday",
      "benefits": "Free training certifications, health insurance",
      "deadline": "August 10, 2026",
      "companyProfile":
          "Infosys is a global leader in next-generation digital services and consulting.",
      "companySize": "300,000+ employees",
      "ratings": 4.0,
      "reviews": 8920,
      "isClosed": false,
      "isExpired": false,
    },
    {
      "id": "zoho_kurla",
      "title": "UI/UX Designer",
      "company": "Zoho Corporation",
      "logoText": "Z",
      "logoColor": const Color(0xFFE11D48),
      "salary": "₹30,000 - ₹45,000",
      "minSalaryVal": 30000,
      "experience": "1-2 yrs",
      "employmentType": "Full-time",
      "location": "Kurla, Mumbai",
      "postedTime": "1 day ago",
      "isVerified": true,
      "isUrgent": true,
      "lat": 19.0728,
      "lng": 72.8826,
      "dx": 0.52,
      "dy": 0.56,
      "description":
          "We are seeking a talented UI/UX Designer to craft beautiful vector layouts, wireframes, and design interactive user flows for Zoho tools.",
      "responsibilities": [
        "Create wireframes, storyboards, and high-fidelity mockups.",
        "Conduct user research and structure intuitive navigations.",
        "Collaborate with developers to ensure pixel-perfect integration.",
      ],
      "requiredSkills": ["Figma", "Adobe XD", "Illustrator", "Prototyping"],
      "qualification": "Graduate in Design or Fine Arts",
      "incentives": "Performance-based rewards",
      "vacancies": 3,
      "shift": "Day Shift",
      "workingHours": "9:30 AM - 6:30 PM",
      "weeklyOff": "Saturday & Sunday",
      "benefits": "Subsidized food, health coverage, high-end laptops",
      "deadline": "August 20, 2026",
      "companyProfile":
          "Zoho offers a suite of cloud applications run on a private business ecosystem.",
      "companySize": "15,000+ employees",
      "ratings": 4.5,
      "reviews": 3120,
      "isClosed": false,
      "isExpired": false,
    },
    {
      "id": "wipro_ghatkopar",
      "title": "Flutter Developer",
      "company": "Wipro",
      "logoText": "W",
      "logoColor": const Color(0xFF6D28D9),
      "salary": "₹45,000 - ₹65,000",
      "minSalaryVal": 45000,
      "experience": "0-1 yr",
      "employmentType": "Contract",
      "location": "Ghatkopar, Mumbai",
      "postedTime": "3 hours ago",
      "isVerified": true,
      "isUrgent": false,
      "lat": 19.0864,
      "lng": 72.9081,
      "dx": 0.72,
      "dy": 0.48,
      "description":
          "Develop and maintain robust mobile applications for Android & iOS platforms using Flutter SDK.",
      "responsibilities": [
        "Write clean Flutter and Dart code components.",
        "Implement state management like Bloc, Provider or Riverpod.",
        "Optimize mobile application packages for app store submissions.",
      ],
      "requiredSkills": ["Flutter", "Dart", "REST API", "Firebase"],
      "qualification": "B.E. / BCA / Computer Science diploma",
      "incentives": "Contract extension bonuses",
      "vacancies": 2,
      "shift": "Flexible Shift",
      "workingHours": "9:00 AM - 6:00 PM",
      "weeklyOff": "Sunday",
      "benefits": "Remote work options, internet allowance",
      "deadline": "August 05, 2026",
      "companyProfile":
          "Wipro is a leading technology services and consulting company driving digital innovation.",
      "companySize": "250,000+ employees",
      "ratings": 3.9,
      "reviews": 11200,
      "isClosed": false,
      "isExpired": false,
    },
    {
      "id": "techm_bhandup",
      "title": "Python Backend Developer",
      "company": "Tech Mahindra",
      "logoText": "T",
      "logoColor": const Color(0xFFEA580C),
      "salary": "₹38,000 - ₹55,000",
      "minSalaryVal": 38000,
      "experience": "2+ yrs",
      "employmentType": "Full-time",
      "location": "Bhandup, Mumbai",
      "postedTime": "1 day ago",
      "isVerified": false,
      "isUrgent": false,
      "lat": 19.1490,
      "lng": 72.9370,
      "dx": 0.22,
      "dy": 0.18,
      "description":
          "Looking for a backend engineer proficient in Python web frameworks (Django/FastAPI) to handle server logic, databases, and APIs.",
      "responsibilities": [
        "Design scalable RESTful API endpoints.",
        "Manage SQL databases and optimize querying performance.",
        "Secure backend services with token-based authentications.",
      ],
      "requiredSkills": ["Python", "Django", "PostgreSQL", "Docker"],
      "qualification": "B.Tech / MCA",
      "incentives": "Variable pay options",
      "vacancies": 5,
      "shift": "Night Shift",
      "workingHours": "7:00 PM - 4:00 AM",
      "weeklyOff": "Saturday & Sunday",
      "benefits": "Night shift allowance, meal coupons, medical care",
      "deadline": "August 22, 2026",
      "companyProfile":
          "Tech Mahindra represents the digital transformation wing of the Mahindra Group.",
      "companySize": "145,000+ employees",
      "ratings": 3.8,
      "reviews": 6500,
      "isClosed": false,
      "isExpired": true, // Expired job test case
    },
    {
      "id": "cogni_vikhroli",
      "title": "Software QA Engineer",
      "company": "Cognizant",
      "logoText": "C",
      "logoColor": const Color(0xFF3B82F6),
      "salary": "₹32,000 - ₹48,000",
      "minSalaryVal": 32000,
      "experience": "Fresher",
      "employmentType": "Part-time",
      "location": "Vikhroli, Mumbai",
      "postedTime": "6 hours ago",
      "isVerified": true,
      "isUrgent": false,
      "lat": 19.1077,
      "lng": 72.9250,
      "dx": 0.42,
      "dy": 0.68,
      "description":
          "Test enterprise softwares and compile test case scenarios to discover software bugs before release.",
      "responsibilities": [
        "Write detailed manual and automated test script cases.",
        "Perform regression, system, and stress testing processes.",
        "Document software anomalies and monitor progress in Jira.",
      ],
      "requiredSkills": ["Selenium", "Java", "Testing", "Jira"],
      "qualification": "B.Sc / BCA",
      "incentives": "Overtime productivity bonuses",
      "vacancies": 1,
      "shift": "Evening Shift",
      "workingHours": "4:00 PM - 10:00 PM",
      "weeklyOff": "Sunday",
      "benefits": "Free shuttle, certification support",
      "deadline": "July 28, 2026",
      "companyProfile":
          "Cognizant helps clients modernize technology, reimagine processes & transform experiences.",
      "companySize": "340,000+ employees",
      "ratings": 4.1,
      "reviews": 9800,
      "isClosed": true, // Closed job test case
      "isExpired": false,
    },
  ];

  // Areas list for quick chips
  final List<String> popularAreas = [
    "Powai",
    "Andheri East",
    "Kurla",
    "Ghatkopar",
    "Bhandup",
    "Vikhroli",
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    // Start entry animations with sequential delay
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _animateHeaderIn = true);
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _animateCardIn = true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Haversine distance in km between candidate and job coordinates.
  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadiusKm = 6371;
    final dLat = _degToRad(lat2 - lat1);
    final dLng = _degToRad(lng2 - lng1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180);

  String _formatDistance(double km) {
    if (km < 1) {
      return "${(km * 1000).round()} m away";
    }
    return "${km.toStringAsFixed(1)} km away";
  }

  @override
  Widget build(BuildContext context) {
    // Filter jobs list based on travel radius, search queries, and filters sheet
    final filteredJobs = nearbyJobs.where((job) {
      final double distance = _distanceKm(
        _candidateLat,
        _candidateLng,
        job["lat"] as double,
        job["lng"] as double,
      );

      // Distance limit constraint (Radius Selection)
      if (distance > _maxTravelRadius) return false;

      // Text query match (Area wise search)
      final query = _searchQuery.trim().toLowerCase();
      if (query.isNotEmpty) {
        final location = job["location"].toString().toLowerCase();
        final company = job["company"].toString().toLowerCase();
        final title = job["title"].toString().toLowerCase();
        if (!location.contains(query) &&
            !company.contains(query) &&
            !title.contains(query)) {
          return false;
        }
      }

      // Filter settings match
      if (_filterExperience != "All" &&
          job["experience"] != _filterExperience) {
        return false;
      }
      if (_filterJobType != "All" && job["employmentType"] != _filterJobType) {
        return false;
      }
      if (job["minSalaryVal"] as int < _filterMinSalary) {
        return false;
      }
      if (_filterOnlyUrgent && job["isUrgent"] != true) {
        return false;
      }
      if (_filterOnlyVerified && job["isVerified"] != true) {
        return false;
      }

      return true;
    }).toList();

    // Reset selected index if bounds exceeded
    if (_selectedJobIndex >= filteredJobs.length) {
      _selectedJobIndex = 0;
    }

    final hasResults = filteredJobs.isNotEmpty;
    final job = hasResults ? filteredJobs[_selectedJobIndex] : null;
    final distanceKm = job != null
        ? _distanceKm(
            _candidateLat,
            _candidateLng,
            job["lat"] as double,
            job["lng"] as double,
          )
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: GenZ.purple,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [GenZ.purple, GenZ.purpleDark],
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "Jobs Near You Map",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Heatmap Switch Button
          IconButton(
            icon: Icon(
              _isHeatmapView
                  ? Icons.map_rounded
                  : Icons.local_fire_department_rounded,
              color: _isHeatmapView ? GenZ.coral : Colors.white,
            ),
            tooltip: "Heatmap View",
            onPressed: () {
              setState(() {
                _isHeatmapView = !_isHeatmapView;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isHeatmapView
                        ? "Heatmap View Active"
                        : "Standard Pin View Active",
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // ── FAKE MAP BACKGROUND ──
            Positioned.fill(
              child: _fakeMapBackground(
                drawHeatmap: _isHeatmapView,
                radiusKm: _maxTravelRadius,
              ),
            ),

            // ── CURRENT LOCATION INDICATOR ──
            const Center(child: _CurrentLocationIndicator()),

            // ── JOB PINS (standard pins showing company branding with bounce-in animations) ──
            if (hasResults && !_isHeatmapView)
              LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: List.generate(filteredJobs.length, (i) {
                      final j = filteredJobs[i];
                      final isSelected = i == _selectedJobIndex;
                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        left:
                            constraints.maxWidth * (j["dx"] as double) -
                            (isSelected ? 26 : 21),
                        top:
                            constraints.maxHeight * (j["dy"] as double) -
                            (isSelected ? 54 : 44),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: Duration(
                            milliseconds: 500 + (i * 120),
                          ), // Staggered entry animation!
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedJobIndex = i),
                            child: _PulsingMarkerHalo(
                              isSelected: isSelected,
                              color: j["logoColor"] as Color,
                              child: _mapPin(
                                isSelected: isSelected,
                                logoText: j["logoText"] as String,
                                logoColor: j["logoColor"] as Color,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),

            // ── HEATMAP LABELS / OVERLAYS ──
            if (_isHeatmapView)
              Positioned(
                top: 96,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.orange,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Hiring Heatmap (High Availability)",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── TOP FLOATING SEARCH & FILTER BAR (Animated Slide-in) ──────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 650),
              curve: Curves.fastOutSlowIn,
              top: _animateHeaderIn ? 16 : -150,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: GenZ.purple,
                        ),
                        hintText: "Search area, company, or job...",
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13.5,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = "");
                                },
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.tune_rounded,
                                color: GenZ.purple,
                              ),
                              onPressed: _showFiltersBottomSheet,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Area chips for quick filtering (Area-wise search)
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: popularAreas.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 6),
                      itemBuilder: (context, idx) {
                        final area = popularAreas[idx];
                        final bool isChipSelected =
                            _searchQuery.toLowerCase() == area.toLowerCase();
                        return ChoiceChip(
                          label: Text(
                            area,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isChipSelected
                                  ? Colors.white
                                  : GenZ.purpleDark,
                            ),
                          ),
                          selected: isChipSelected,
                          selectedColor: GenZ.purple,
                          backgroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isChipSelected
                                  ? Colors.transparent
                                  : GenZ.purple.withOpacity(0.2),
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _searchController.text = area;
                                _searchQuery = area;
                              } else {
                                _searchController.clear();
                                _searchQuery = "";
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── ZOOM CONTROLS & SEARCH THIS AREA & RADIUS ──
            Positioned(
              right: 16,
              bottom: hasResults ? 240 : 30,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search This Area Button
                  GestureDetector(
                    onTap: () {
                      setState(() => _isSearchingThisArea = true);
                      Future.delayed(const Duration(milliseconds: 800), () {
                        if (!mounted) return;
                        setState(() => _isSearchingThisArea = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Refreshed jobs in this viewport"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GenZ.purple.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isSearchingThisArea
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: GenZ.purple,
                                  ),
                                )
                              : const Icon(
                                  Icons.refresh_rounded,
                                  color: GenZ.purple,
                                  size: 14,
                                ),
                          const SizedBox(width: 4),
                          const Text(
                            "Search this area",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: GenZ.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Zoom In
                  FloatingActionButton.small(
                    heroTag: "zoomIn",
                    backgroundColor: Colors.white,
                    foregroundColor: GenZ.purpleDark,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Zooming In"),
                          duration: Duration(milliseconds: 400),
                        ),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 6),

                  // Zoom Out
                  FloatingActionButton.small(
                    heroTag: "zoomOut",
                    backgroundColor: Colors.white,
                    foregroundColor: GenZ.purpleDark,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Zooming Out"),
                          duration: Duration(milliseconds: 400),
                        ),
                      );
                    },
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 6),

                  // Radius Selection Slider trigger
                  FloatingActionButton.small(
                    heroTag: "radiusSet",
                    backgroundColor: Colors.white,
                    foregroundColor: GenZ.purpleDark,
                    onPressed: _showRadiusSliderSheet,
                    child: const Icon(Icons.radar_rounded),
                  ),
                  const SizedBox(height: 6),

                  // My Location reset
                  FloatingActionButton.small(
                    heroTag: "recenter",
                    backgroundColor: Colors.white,
                    foregroundColor: GenZ.purpleDark,
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = "";
                        _maxTravelRadius = 8.0;
                        _filterExperience = "All";
                        _filterJobType = "All";
                        _filterMinSalary = 10000;
                        _filterOnlyUrgent = false;
                        _filterOnlyVerified = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Map reset to current location (8 km radius)",
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Icon(Icons.my_location_rounded),
                  ),
                ],
              ),
            ),

            // ── BOTTOM PREVIEW JOB CARD (Animated Slide-in & Cross-fade transitions) ──
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.fastOutSlowIn,
              left: 16,
              right: 16,
              bottom: _animateCardIn && hasResults ? 16 : -220,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: hasResults && job != null
                    ? KeyedSubtree(
                        key: ValueKey<String>(job["id"] as String),
                        child: _jobBottomCard(job, distanceKm),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fakeMapBackground({
    required bool drawHeatmap,
    required double radiusKm,
  }) {
    return Container(
      color: const Color(0xFFEDF1F5),
      child: CustomPaint(
        painter: _FakeMapPainter(drawHeatmap: drawHeatmap, radiusKm: radiusKm),
        child: Container(),
      ),
    );
  }

  // Branded Custom Map Pin showing company letter and brand color
  Widget _mapPin({
    required bool isSelected,
    required String logoText,
    required Color logoColor,
  }) {
    final double size = isSelected ? 44 : 34;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isSelected ? GenZ.purpleDark : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : logoColor.withOpacity(0.8),
              width: isSelected ? 2.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: size - 8,
              height: size - 8,
              decoration: BoxDecoration(
                color: logoColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  logoText,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSelected ? 15 : 12,
                  ),
                ),
              ),
            ),
          ),
        ),
        Icon(
          Icons.arrow_drop_down_rounded,
          color: isSelected ? GenZ.purpleDark : Colors.white,
          size: 18,
        ),
      ],
    );
  }

  Widget _chip(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textHint.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: AppColors.textSecondary),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // 5.1/5.2 Job Preview Card
  Widget _jobBottomCard(Map<String, dynamic> job, double distanceKm) {
    final String jobId = job["id"] as String;
    final bool isSaved = _savedJobIds.contains(jobId);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: job["logoColor"] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    job["logoText"] as String,
                    style: const TextStyle(
                      color: AppColors.buttonText,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title / Company / Distance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            job["title"] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (job["isVerified"] as bool) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            size: 15,
                            color: GenZ.purple,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job["company"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                          color: GenZ.purple,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            "${_formatDistance(distanceKm)} • ${job["location"]}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Save button
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSaved) {
                      _savedJobIds.remove(jobId);
                    } else {
                      _savedJobIds.add(jobId);
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isSaved
                            ? "Removed from saved list"
                            : "Job Saved Successfully",
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved ? GenZ.purpleDark : AppColors.textHint,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Experience / Employment type chips
          Row(
            children: [
              _chip(
                job["experience"] as String,
                icon: Icons.work_outline_rounded,
              ),
              const SizedBox(width: 6),
              _chip(
                job["employmentType"] as String,
                icon: Icons.schedule_rounded,
              ),
              const Spacer(),
              Text(
                job["postedTime"] as String,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Salary + View Job Button
          Row(
            children: [
              Expanded(
                child: Text(
                  job["salary"] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: GenZ.purpleDark,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                height: 38,
                child: ElevatedButton(
                  onPressed: () => _openJobDetailsBottomSheet(job, distanceKm),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GenZ.purple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(100, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "View Job",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5.3 Floating Radius Selection Dialog
  void _showRadiusSliderSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        double tempRadius = _maxTravelRadius;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Maximum Travel Distance",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: GenZ.purple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${tempRadius.toStringAsFixed(1)} km",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: GenZ.purpleDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Define the maximum distance you are willing to travel from your current location for recommendations.",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Slider(
                    value: tempRadius,
                    min: 1.0,
                    max: 20.0,
                    divisions: 19,
                    activeColor: GenZ.purple,
                    inactiveColor: Colors.black12,
                    onChanged: (val) {
                      setSheetState(() => tempRadius = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          child: const Text("Use Temporarily"),
                          onPressed: () {
                            setState(() {
                              _maxTravelRadius = tempRadius;
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Distance filter updated to ${tempRadius.toStringAsFixed(1)} km for this session",
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GenZ.purple,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Save to Profile"),
                          onPressed: () {
                            setState(() {
                              _maxTravelRadius = tempRadius;
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Saved ${tempRadius.toStringAsFixed(1)} km radius preference to profile",
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 5.2 Filter Selection Bottom Sheet
  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        String tempExp = _filterExperience;
        String tempType = _filterJobType;
        double tempSalary = _filterMinSalary;
        bool tempUrgent = _filterOnlyUrgent;
        bool tempVerified = _filterOnlyVerified;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Refine Job Matches",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 1. Salary Minimum
                      Text(
                        "Minimum Monthly Salary (₹${tempSalary.round()})",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      Slider(
                        value: tempSalary,
                        min: 10000,
                        max: 50000,
                        divisions: 8,
                        activeColor: GenZ.purple,
                        inactiveColor: Colors.black12,
                        onChanged: (val) {
                          setSheetState(() => tempSalary = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      // 2. Experience Level
                      const Text(
                        "Experience Requirements",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children:
                            [
                              "All",
                              "Fresher",
                              "0-1 yr",
                              "1-2 yrs",
                              "2+ yrs",
                            ].map((exp) {
                              final isSel = tempExp == exp;
                              return ChoiceChip(
                                label: Text(exp),
                                selected: isSel,
                                selectedColor: GenZ.purple,
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : Colors.black87,
                                ),
                                onSelected: (_) =>
                                    setSheetState(() => tempExp = exp),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // 3. Job Type
                      const Text(
                        "Employment Type",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ["All", "Full-time", "Part-time", "Contract"]
                            .map((type) {
                              final isSel = tempType == type;
                              return ChoiceChip(
                                label: Text(type),
                                selected: isSel,
                                selectedColor: GenZ.purple,
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : Colors.black87,
                                ),
                                onSelected: (_) =>
                                    setSheetState(() => tempType = type),
                              );
                            })
                            .toList(),
                      ),
                      const SizedBox(height: 14),

                      // 4. Badges / Indicators
                      const Text(
                        "Additional Preferences",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      SwitchListTile(
                        title: const Text(
                          "Urgent Hiring Only",
                          style: TextStyle(fontSize: 13),
                        ),
                        activeThumbColor: GenZ.purple,
                        value: tempUrgent,
                        onChanged: (val) =>
                            setSheetState(() => tempUrgent = val),
                      ),
                      SwitchListTile(
                        title: const Text(
                          "Verified Employers Only",
                          style: TextStyle(fontSize: 13),
                        ),
                        activeThumbColor: GenZ.purple,
                        value: tempVerified,
                        onChanged: (val) =>
                            setSheetState(() => tempVerified = val),
                      ),

                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              child: const Text("Reset All"),
                              onPressed: () {
                                setSheetState(() {
                                  tempExp = "All";
                                  tempType = "All";
                                  tempSalary = 10000;
                                  tempUrgent = false;
                                  tempVerified = false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GenZ.purple,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Apply Filters"),
                              onPressed: () {
                                setState(() {
                                  _filterExperience = tempExp;
                                  _filterJobType = tempType;
                                  _filterMinSalary = tempSalary;
                                  _filterOnlyUrgent = tempUrgent;
                                  _filterOnlyVerified = tempVerified;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // 7. Job Details Overlay Bottom Sheet (displays comprehensive job & employer details)
  void _openJobDetailsBottomSheet(Map<String, dynamic> job, double distanceKm) {
    final String jobId = job["id"] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bool isApplied = _appliedJobIds.contains(jobId);
            final bool isSaved = _savedJobIds.contains(jobId);
            final bool isClosed = job["isClosed"] == true;
            final bool isExpired = job["isExpired"] == true;

            // Compute Application Button State
            String applyButtonText = "Apply Now";
            bool canApply = true;

            if (isApplied) {
              applyButtonText = "Applied Successfully";
              canApply = false;
            } else if (isClosed) {
              applyButtonText = "Job Closed";
              canApply = false;
            } else if (isExpired) {
              applyButtonText = "Job Expired";
              canApply = false;
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Drag indicator handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Job Header: Logo + Title + Company + Save
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: job["logoColor"] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            job["logoText"] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job["title"] as String,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  job["company"] as String,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (job["isVerified"] as bool) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: GenZ.purple,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                        ),
                        color: isSaved ? GenZ.purpleDark : Colors.grey,
                        onPressed: () {
                          setState(() {
                            if (isSaved) {
                              _savedJobIds.remove(jobId);
                            } else {
                              _savedJobIds.add(jobId);
                            }
                          });
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),

                  // Scrollable Job Information Sections
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Basic Stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _statCol("Salary", job["salary"] as String),
                              _statCol("Distance", _formatDistance(distanceKm)),
                              _statCol(
                                "Vacancies",
                                "${job["vacancies"]} positions",
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 2. Job details specifications
                          _sectionTitle("Job Specification"),
                          _detailRow(
                            Icons.work_outline_rounded,
                            "Experience Required: ${job["experience"]}",
                          ),
                          _detailRow(
                            Icons.schedule_rounded,
                            "Job Type: ${job["employmentType"]}",
                          ),
                          _detailRow(
                            Icons.school_outlined,
                            "Qualifications: ${job["qualification"]}",
                          ),
                          _detailRow(
                            Icons.access_time_rounded,
                            "Working Hours: ${job["workingHours"]} (${job["shift"]})",
                          ),
                          _detailRow(
                            Icons.calendar_today_rounded,
                            "Weekly Offs: ${job["weeklyOff"]}",
                          ),
                          _detailRow(
                            Icons.currency_rupee_rounded,
                            "Incentives: ${job["incentives"]}",
                          ),
                          _detailRow(
                            Icons.location_on_rounded,
                            "Location: ${job["location"]}",
                          ),
                          _detailRow(
                            Icons.warning_amber_rounded,
                            "Application Deadline: ${job["deadline"]}",
                          ),
                          const SizedBox(height: 16),

                          // 3. Job Description
                          _sectionTitle("Description"),
                          Text(
                            job["description"] as String,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 4. Job Responsibilities
                          _sectionTitle("Key Responsibilities"),
                          Column(
                            children: (job["responsibilities"] as List<String>)
                                .map((resp) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "• ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: GenZ.purple,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            resp,
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                          const SizedBox(height: 16),

                          // 5. Required Skills
                          _sectionTitle("Skills Required"),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (job["requiredSkills"] as List<String>)
                                .map((skill) {
                                  return Chip(
                                    label: Text(
                                      skill,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: GenZ.purpleDark,
                                      ),
                                    ),
                                    backgroundColor: GenZ.purple.withOpacity(
                                      0.12,
                                    ),
                                    padding: EdgeInsets.zero,
                                  );
                                })
                                .toList(),
                          ),
                          const SizedBox(height: 16),

                          // 6. Benefits
                          _sectionTitle("Benefits & Perks"),
                          Text(
                            job["benefits"] as String,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 7. Employer Information
                          _sectionTitle("About Employer"),
                          Text(
                            job["companyProfile"] as String,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.people_outline_rounded,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Company Size: ${job["companySize"]}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rate_rounded,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${job["ratings"]} Rating (${job["reviews"]} reviews)",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Actions Panel (Apply, Directions, Share, Report, Contact)
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, top: 8),
                    child: Row(
                      children: [
                        // Get Directions
                        _actionCircleButton(
                          icon: Icons.directions_outlined,
                          tooltip: "Directions",
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Routing directions to office...",
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),

                        // Contact Employer
                        _actionCircleButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          tooltip: "Contact",
                          onTap: () {
                            _showContactOptionsDialog(job["company"] as String);
                          },
                        ),
                        const SizedBox(width: 8),

                        // Share
                        _actionCircleButton(
                          icon: Icons.share_outlined,
                          tooltip: "Share",
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Shared ${job["title"]} link successfully",
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),

                        // Report
                        _actionCircleButton(
                          icon: Icons.report_gmailerrorred_outlined,
                          tooltip: "Report",
                          onTap: () {
                            _showReportJobDialog(job["title"] as String);
                          },
                        ),
                        const SizedBox(width: 14),

                        // Primary Action Button (Apply Now / Expired / Closed)
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canApply
                                    ? GenZ.purple
                                    : Colors.grey[300],
                                foregroundColor: canApply
                                    ? Colors.white
                                    : Colors.grey[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: canApply
                                  ? () {
                                      setState(() {
                                        _appliedJobIds.add(jobId);
                                      });
                                      setSheetState(() {});
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Application sent successfully to ${job["company"]}!",
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Text(
                                applyButtonText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _statCol(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10.5,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          val,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: GenZ.purple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
      ),
    );
  }

  // Dialog for reporting job
  void _showReportJobDialog(String jobTitle) {
    showDialog(
      context: context,
      builder: (context) {
        String reportReason = "Fake Job posting";
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Report Job Post",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Please choose a reason for reporting '$jobTitle':",
                style: const TextStyle(fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: reportReason,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items:
                    [
                      "Fake Job posting",
                      "Incorrect salary details",
                      "Demanding deposit fees",
                      "Adult content / Spam",
                    ].map((reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(
                          reason,
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      );
                    }).toList(),
                onChanged: (val) {
                  if (val != null) reportReason = val;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GenZ.coral,
                foregroundColor: Colors.white,
              ),
              child: const Text("Submit Report"),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Report submitted successfully for reason: '$reportReason'",
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog for contact options
  void _showContactOptionsDialog(String companyName) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Contact $companyName",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Initiating secure chat with HR..."),
                  ),
                );
              },
              child: const Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: GenZ.purple,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text("HR Chat Support", style: TextStyle(fontSize: 13.5)),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Opening HR call routing...")),
                );
              },
              child: const Row(
                children: [
                  Icon(
                    Icons.phone_in_talk_outlined,
                    color: GenZ.purple,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Call Recruiter Office",
                    style: TextStyle(fontSize: 13.5),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// ── FAKE MAP PAINTER WITH CURRENT LOCATION & RADIUS CIRCLE & HEATMAPS ──
class _FakeMapPainter extends CustomPainter {
  final bool drawHeatmap;
  final double radiusKm;
  _FakeMapPainter({required this.drawHeatmap, required this.radiusKm});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Map background grid roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6;

    final thinRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2.5;

    // Horizontal roads
    for (
      double y = size.height * 0.12;
      y < size.height;
      y += size.height * 0.18
    ) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }

    // Vertical roads
    for (double x = size.width * 0.15; x < size.width; x += size.width * 0.22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), thinRoadPaint);
    }

    // Soft green park area
    final parkPaint = Paint()..color = const Color(0xFFD9EAD3);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.58,
        size.height * 0.60,
        size.width * 0.32,
        size.height * 0.22,
      ),
      parkPaint,
    );

    // Soft blue water area
    final waterPaint = Paint()..color = const Color(0xFFCFE2F3);
    canvas.drawOval(
      Rect.fromLTWH(
        -size.width * 0.15,
        size.height * 0.02,
        size.width * 0.45,
        size.height * 0.16,
      ),
      waterPaint,
    );

    // 2. Draw Translucent Radius selection circle (5.3 definition) centered around candidate
    final double centerMapX = size.width * 0.5;
    final double centerMapY = size.height * 0.5;

    // Scale distance radius visually (1 km = 18 pixels approx)
    final double radiusPixels = radiusKm * 18.0;

    final radiusOutlinePaint = Paint()
      ..color = GenZ.purple.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final radiusFillPaint = Paint()
      ..color = GenZ.purple.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerMapX, centerMapY),
      radiusPixels,
      radiusFillPaint,
    );
    canvas.drawCircle(
      Offset(centerMapX, centerMapY),
      radiusPixels,
      radiusOutlinePaint,
    );

    // 3. Draw Local Hiring Heatmap overlays if toggled on (5.4)
    if (drawHeatmap) {
      final heatmapRed = Paint()
        ..color = Colors.red.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

      final heatmapOrange = Paint()
        ..color = Colors.orange.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

      final heatmapYellow = Paint()
        ..color = Colors.yellow.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

      // High activity areas (e.g. Kurla, Powai, Andheri East)
      canvas.drawCircle(
        Offset(size.width * 0.52, size.height * 0.56),
        40,
        heatmapRed,
      ); // Kurla (Red)
      canvas.drawCircle(
        Offset(size.width * 0.60, size.height * 0.38),
        35,
        heatmapOrange,
      ); // Powai (Orange)
      canvas.drawCircle(
        Offset(size.width * 0.32, size.height * 0.28),
        30,
        heatmapYellow,
      ); // Andheri (Yellow)
    }
  }

  @override
  bool shouldRepaint(covariant _FakeMapPainter oldDelegate) {
    return oldDelegate.drawHeatmap != drawHeatmap ||
        oldDelegate.radiusKm != radiusKm;
  }
}

/// ── pulsing current location indicator ──
class _CurrentLocationIndicator extends StatefulWidget {
  const _CurrentLocationIndicator();

  @override
  State<_CurrentLocationIndicator> createState() =>
      _CurrentLocationIndicatorState();
}

class _CurrentLocationIndicatorState extends State<_CurrentLocationIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulse = Tween<double>(
      begin: 8.0,
      end: 22.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            return Container(
              width: _pulse.value * 2,
              height: _pulse.value * 2,
              decoration: BoxDecoration(
                color: GenZ.purple.withOpacity(
                  0.3 - (_pulse.value / 22.0) * 0.3,
                ),
                shape: BoxShape.circle,
              ),
            );
          },
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: GenZ.purpleDark,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ── Pulsing Marker Halo (Ring around selected map pin) ──
class _PulsingMarkerHalo extends StatefulWidget {
  final Widget child;
  final Color color;
  final bool isSelected;
  const _PulsingMarkerHalo({
    required this.child,
    required this.color,
    required this.isSelected,
  });

  @override
  State<_PulsingMarkerHalo> createState() => _PulsingMarkerHaloState();
}

class _PulsingMarkerHaloState extends State<_PulsingMarkerHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _pulse = Tween<double>(
      begin: 34.0,
      end: 56.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isSelected) return widget.child;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: 0,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Container(
                width: _pulse.value,
                height: _pulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(
                    0.35 - (_pulse.value / 56.0) * 0.35,
                  ),
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}
