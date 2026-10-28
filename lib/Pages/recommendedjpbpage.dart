import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applicationtrackerpage.dart';
import 'package:hyper_local/Pages/homepage.dart';
import 'package:hyper_local/Pages/jobdescriptipnpage.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';
import 'package:hyper_local/Pages/profilepage.dart';
import 'package:hyper_local/models/job/job_application_model.dart';
import 'package:hyper_local/models/job/job_model.dart';
import 'package:hyper_local/services/job_application_service.dart';
import 'package:hyper_local/services/job_service.dart';
import 'package:hyper_local/utils/session_manager.dart';
import 'package:hyper_local/services/location_service.dart';
import 'package:hyper_local/models/location/city_model.dart';
import 'package:hyper_local/services/api_service.dart';
import '../utils/app_colors.dart';

/// Unified model for rendering a job card and passing details to JobDescriptionPage
class JobDisplayItem {
  final int id;
  final String title;
  final String company;
  final String companyFullName;
  final String location;
  final String distance;
  final double rating;
  final String salary;
  final String status;
  final String logoText;
  final Color logoColor;
  final String experience;
  final List<String> skills;
  final String description;
  final int totalVacancies;
  final int remainingVacancies;
  final String postedDate;
  final bool isPremium;
  final bool isUrgentHiring;
  final bool isWalkInInterview;
  final bool isFeatured;
  final bool topSearchPlacement;
  final bool homepagePlacement;
  final bool nearbyCandidateNotification;
  final int? cityId;
  final String? cityName;

  JobDisplayItem({
    required this.id,
    required this.title,
    required this.company,
    required this.companyFullName,
    required this.location,
    required this.distance,
    required this.rating,
    required this.salary,
    required this.status,
    required this.logoText,
    required this.logoColor,
    required this.experience,
    required this.skills,
    required this.description,
    required this.totalVacancies,
    required this.remainingVacancies,
    required this.postedDate,
    this.isPremium = false,
    this.isUrgentHiring = false,
    this.isWalkInInterview = false,
    this.isFeatured = false,
    this.topSearchPlacement = false,
    this.homepagePlacement = false,
    this.nearbyCandidateNotification = false,
    this.cityId,
    this.cityName,
  });

  JobDisplayItem copyWith({
    int? id,
    String? title,
    String? company,
    String? companyFullName,
    String? location,
    String? distance,
    double? rating,
    String? salary,
    String? status,
    String? logoText,
    Color? logoColor,
    String? experience,
    List<String>? skills,
    String? description,
    int? totalVacancies,
    int? remainingVacancies,
    String? postedDate,
    bool? isPremium,
    bool? isUrgentHiring,
    bool? isWalkInInterview,
    bool? isFeatured,
    bool? topSearchPlacement,
    bool? homepagePlacement,
    bool? nearbyCandidateNotification,
    int? cityId,
    String? cityName,
  }) {
    return JobDisplayItem(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyFullName: companyFullName ?? this.companyFullName,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      salary: salary ?? this.salary,
      status: status ?? this.status,
      logoText: logoText ?? this.logoText,
      logoColor: logoColor ?? this.logoColor,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      description: description ?? this.description,
      totalVacancies: totalVacancies ?? this.totalVacancies,
      remainingVacancies: remainingVacancies ?? this.remainingVacancies,
      postedDate: postedDate ?? this.postedDate,
      isPremium: isPremium ?? this.isPremium,
      isUrgentHiring: isUrgentHiring ?? this.isUrgentHiring,
      isWalkInInterview: isWalkInInterview ?? this.isWalkInInterview,
      isFeatured: isFeatured ?? this.isFeatured,
      topSearchPlacement: topSearchPlacement ?? this.topSearchPlacement,
      homepagePlacement: homepagePlacement ?? this.homepagePlacement,
      nearbyCandidateNotification: nearbyCandidateNotification ?? this.nearbyCandidateNotification,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
    );
  }

  factory JobDisplayItem.fromApplication(JobApplicationModel app) {
    return JobDisplayItem(
      id: app.jobPostId > 0 ? app.jobPostId : app.applicationId,
      title: app.jobTitle,
      company: app.companyName,
      companyFullName: '${app.companyName} Pvt. Ltd.',
      location: app.displayLocation,
      distance: app.displayLocation,
      rating: 4.5,
      salary: app.formattedSalary,
      status: app.statusLabel,
      logoText: app.logoLetter,
      logoColor: app.logoColor,
      cityName: app.city,
      experience: app.experienceRequired != null && app.experienceRequired!.isNotEmpty
          ? app.experienceRequired!
          : '1-3 years',
      skills: [
        if (app.jobRole != null && app.jobRole!.isNotEmpty) app.jobRole!,
        if (app.department != null && app.department!.isNotEmpty) app.department!,
        if (app.jobCategory != null && app.jobCategory!.isNotEmpty) app.jobCategory!,
        'Communication',
        'Problem Solving',
      ],
      description:
          'Exciting career opportunity at ${app.companyName} for the role of ${app.jobTitle}. Join our dynamic team, collaborate on impactful projects, and accelerate your professional growth.',
      totalVacancies: 10,
      remainingVacancies: 4,
      postedDate: app.formattedAppliedDate,
      isPremium: false,
      isUrgentHiring: false,
      isWalkInInterview: false,
      isFeatured: false,
      topSearchPlacement: false,
      homepagePlacement: false,
      nearbyCandidateNotification: false,
    );
  }

  factory JobDisplayItem.fromJob(JobModel job) {
    return JobDisplayItem(
      id: job.id,
      title: job.title,
      company: job.companyName,
      companyFullName: '${job.companyName} Pvt. Ltd.',
      location: job.location ?? 'Nearby',
      distance: job.formattedDistance,
      rating: job.displayRating,
      salary: job.formattedSalary,
      status: job.status.isNotEmpty ? job.status : 'Active',
      logoText: job.logoLetter,
      logoColor: job.logoColor,
      experience: job.experienceRequired ?? '0-2 years',
      skills: job.skills.isNotEmpty
          ? job.skills
          : const ['Teamwork', 'Communication', 'Skills'],
      description: job.description != null && job.description!.trim().isNotEmpty
          ? job.description!
          : 'Great opportunity at ${job.companyName} for ${job.title}. Competitive salary and professional work environment.',
      totalVacancies: job.totalVacancies > 0 ? job.totalVacancies : 6,
      remainingVacancies:
          job.remainingVacancies > 0 ? job.remainingVacancies : 3,
      postedDate: job.formattedPostedDate,
      isPremium: job.isPremium,
      isUrgentHiring: job.isUrgentHiring,
      isWalkInInterview: job.isWalkInInterview,
      isFeatured: job.isFeatured,
      topSearchPlacement: job.topSearchPlacement,
      homepagePlacement: job.homepagePlacement,
      nearbyCandidateNotification: job.nearbyCandidateNotification,
      cityId: job.cityId,
      cityName: job.cityName,
    );
  }

  factory JobDisplayItem.fromMap(Map<String, dynamic> map) {
    return JobDisplayItem(
      id: map['id'] is int ? map['id'] : (int.tryParse(map['id']?.toString() ?? '0') ?? 0),
      title: map['title'] ?? map['job_title'] ?? '',
      company: map['company'] ?? map['company_name'] ?? '',
      companyFullName: "${map['company'] ?? map['company_name'] ?? 'Company'} Pvt. Ltd.",
      location: map['location'] ?? map['city_name'] ?? map['city'] ?? 'Nearby',
      distance: map['distance'] ?? '2.5 km',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.2,
      salary: map['salary'] ?? '₹35,000 - ₹50,000',
      status: map['status'] ?? 'Active',
      logoText: map['logoText'] ?? 'J',
      logoColor: map['logoColor'] is Color ? map['logoColor'] : AppColors.primary,
      experience: '1-2 years',
      skills: const ['Flutter', 'Dart', 'Teamwork', 'Problem Solving'],
      description:
          'We are looking for enthusiastic individuals to join our team at ${map['company']}. Great career prospects with competitive salary.',
      totalVacancies: 8,
      remainingVacancies: 3,
      postedDate: 'Recently',
      isPremium: map['is_premium'] == 1 || map['is_premium'] == true || map['is_premium'] == '1' || map['isPremium'] == true,
      isUrgentHiring: map['is_urgent_hiring'] == 1 || map['is_urgent_hiring'] == true || map['is_urgent_hiring'] == '1' || map['isUrgentHiring'] == true,
      isWalkInInterview: map['is_walk_in_interview'] == 1 || map['is_walk_in_interview'] == true || map['is_walk_in_interview'] == '1' || map['isWalkInInterview'] == true,
      isFeatured: map['is_featured'] == 1 || map['is_featured'] == true || map['is_featured'] == '1' || map['isFeatured'] == true,
      topSearchPlacement: map['top_search_placement'] == 1 || map['top_search_placement'] == true,
      homepagePlacement: map['homepage_placement'] == 1 || map['homepage_placement'] == true,
      nearbyCandidateNotification: map['nearby_candidate_notification'] == 1 || map['nearby_candidate_notification'] == true,
      cityId: map['city_id'] != null
          ? (map['city_id'] is num ? (map['city_id'] as num).toInt() : int.tryParse(map['city_id'].toString()))
          : (map['cityId'] != null ? int.tryParse(map['cityId'].toString()) : null),
      cityName: (map['city_name'] ?? map['cityName'] ?? map['city'])?.toString(),
    );
  }
}

class RecommendedJobPage extends StatefulWidget {
  const RecommendedJobPage({super.key});

  @override
  State<RecommendedJobPage> createState() => _RecommendedJobPageState();
}

class _RecommendedJobPageState extends State<RecommendedJobPage> {
  int _selectedIndex = 2; // "Jobs" tab active

  // ── SEARCH STATE ────────────────────────────────────────
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // ── LOADING & JOBS STATE ───────────────────────────────
  bool _isLoading = true;
  List<JobDisplayItem> _jobs = [];
  int? _selectedCityId;
  String? _selectedCityName;

  final LocationService _locationService = LocationService();
  final JobService _jobService = JobService();

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkCityUpdate();
  }

  Future<void> _checkCityUpdate() async {
    final savedId = await SessionManager.getSelectedCityId();
    final savedCity = await SessionManager.getSelectedCityName();
    if ((savedId != null && savedId != _selectedCityId) ||
        (savedCity != null && savedCity != _selectedCityName)) {
      _fetchJobs();
    }
  }

  int _calculateRecommendationScore(JobModel job) {
    int score = 0;
    const preferredSkills = ["Flutter", "UI Design", "Figma", "Dart", "Frontend", "Communication"];
    final jobSkills = job.skills;
    score += jobSkills.where((s) => preferredSkills.any((u) => u.toLowerCase() == s.toLowerCase())).length * 2;
    final titleLower = job.title.toLowerCase();
    if (titleLower.contains("developer") || titleLower.contains("engineer") || titleLower.contains("frontend")) {
      score += 3;
    }
    if (job.isPremium) score += 2;
    if (job.isUrgentHiring) score += 1;
    if (job.isFeatured) score += 1;
    return score;
  }

  Future<void> _fetchJobs() async {
    setState(() => _isLoading = true);
    try {
      final userDetails = await SessionManager.getUserDetails();
      final userId = (userDetails['id'] is int)
          ? userDetails['id'] as int
          : int.tryParse(userDetails['id']?.toString() ?? '0') ?? 0;

      int? cityId = await SessionManager.getSelectedCityId();
      String? cityName = await SessionManager.getSelectedCityName();

      // Resolve cityId if not yet resolved in session (matching dashboard.page.dart)
      if (cityId == null || cityId <= 0) {
        try {
          final cities = await _locationService.getCities();
          final cityNameToMatch = (cityName != null && cityName.trim().isNotEmpty)
              ? cityName.trim()
              : "Amravati";
          final match = cities.firstWhere(
            (c) => c.cityName.toLowerCase() == cityNameToMatch.toLowerCase(),
            orElse: () => CityModel(id: 0, cityName: cityNameToMatch),
          );
          if (match.id > 0) {
            cityId = match.id;
            cityName = match.cityName;
            await SessionManager.saveSelectedCity(cityId: match.id, cityName: match.cityName);
          }
        } catch (e) {
          debugPrint("Error resolving city ID in RecommendedJobPage: $e");
        }
      }

      List<JobModel> fetchedJobs = [];

      // 1. Fetch public jobs via JobService with cityId filter
      try {
        fetchedJobs = await _jobService.getJobs(cityId: cityId);
      } catch (e) {
        debugPrint("JobService getJobs error: $e");
      }

      // 2. Fallback to direct API if JobService returned empty (identical to dashboard.page.dart)
      if (fetchedJobs.isEmpty) {
        try {
          final queryParam = (cityId != null && cityId > 0) ? '?city_id=$cityId' : '';
          final res = await ApiService().getRequest('/jobpost/public$queryParam');
          List<dynamic>? rawList;
          if (res['jobPosts'] is List) {
            rawList = res['jobPosts'];
          } else if (res['data'] is List) {
            rawList = res['data'];
          } else if (res['jobs'] is List) {
            rawList = res['jobs'];
          }

          if (rawList != null && rawList.isNotEmpty) {
            fetchedJobs = rawList
                .map((json) => JobModel.fromJson(Map<String, dynamic>.from(json)))
                .where((job) {
                  final s = job.status.toLowerCase().trim();
                  final matchesStatus = s == 'active' || s == 'published' || s.isEmpty;
                  final matchesCity = cityId == null || cityId == 0 || job.cityId == cityId;
                  return matchesStatus && matchesCity;
                })
                .toList();
          }
        } catch (e) {
          debugPrint("Direct fallback error in RecommendedJobPage: $e");
        }
      }

      // 3. Strictly enforce city matching: Do not show jobs from other cities
      if (cityId != null && cityId > 0) {
        fetchedJobs = fetchedJobs.where((job) => job.cityId == cityId).toList();
      } else if (cityName != null && cityName.trim().isNotEmpty) {
        fetchedJobs = fetchedJobs.where((job) =>
            job.cityName != null &&
            job.cityName!.trim().toLowerCase() == cityName!.trim().toLowerCase()).toList();
      }

      // 4. Recommendation algorithm scoring & sorting
      fetchedJobs.sort((a, b) {
        final scoreA = _calculateRecommendationScore(a);
        final scoreB = _calculateRecommendationScore(b);
        final scoreComp = scoreB.compareTo(scoreA);
        if (scoreComp != 0) return scoreComp;

        // Secondary sort: newest first
        if (a.createdAt != null && b.createdAt != null) {
          final dtA = DateTime.tryParse(a.createdAt!);
          final dtB = DateTime.tryParse(b.createdAt!);
          if (dtA != null && dtB != null) return dtB.compareTo(dtA);
        }
        return b.id.compareTo(a.id);
      });

      List<JobDisplayItem> displayItems =
          fetchedJobs.map((pj) => JobDisplayItem.fromJob(pj)).toList();

      // 5. Overlay application status if user has already applied
      if (userId > 0 && displayItems.isNotEmpty) {
        try {
          final applications =
              await JobApplicationService().getUserApplications(userId);
          if (applications.isNotEmpty) {
            final appliedMap = <int, String>{};
            for (final app in applications) {
              final jpId = app.jobPostId > 0 ? app.jobPostId : app.applicationId;
              if (jpId > 0) {
                appliedMap[jpId] = app.statusLabel;
              }
            }
            displayItems = displayItems.map((item) {
              if (appliedMap.containsKey(item.id)) {
                return item.copyWith(status: appliedMap[item.id] ?? 'Applied');
              }
              return item;
            }).toList();
          }
        } catch (e) {
          debugPrint("Error checking user applications for status: $e");
        }
      }

      if (mounted) {
        setState(() {
          _selectedCityId = cityId;
          _selectedCityName = cityName ?? (cityId != null ? 'City #$cityId' : null);
          _jobs = displayItems;
        });
      }
    } catch (e) {
      debugPrint("Error loading jobs in RecommendedJobPage: $e");
      if (mounted) {
        setState(() {
          _jobs = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  // ── FILTERED LIST BASED ON SEARCH QUERY ────────────────
  List<JobDisplayItem> get _filteredJobs {
    if (_searchQuery.trim().isEmpty) return _jobs;
    final query = _searchQuery.toLowerCase();
    return _jobs.where((job) {
      final title = job.title.toLowerCase();
      final company = job.company.toLowerCase();
      final loc = job.location.toLowerCase();
      return title.contains(query) ||
          company.contains(query) ||
          loc.contains(query);
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
          icon: const Icon(
            Icons.arrow_back,
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
      body: RefreshIndicator(
        onRefresh: _fetchJobs,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            // Heading
            Text(
              _isSearching && _searchQuery.isNotEmpty
                  ? "${filteredJobs.length} Results Found"
                  : "${filteredJobs.length}+ Jobs Found",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _selectedCityName != null && _selectedCityName!.isNotEmpty
                        ? "Near $_selectedCityName"
                        : "Near Amravati",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Loading state
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              )
            // Empty state
            else if (filteredJobs.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _searchQuery.trim().isNotEmpty
                          ? "No jobs found"
                          : (_selectedCityName != null && _selectedCityName!.isNotEmpty
                              ? "No recommended jobs found in $_selectedCityName"
                              : "No recommended jobs found in your city"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _searchQuery.trim().isNotEmpty
                          ? "Try searching with a different keyword"
                          : "Check back later or switch your location from the dashboard",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              )
            // Job cards
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
      ),

      // ── BOTTOM NAVIGATION BAR ──
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
                          // Already on this page
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
                              builder: (context) =>
                                  const ApplicationTrackerPage(),
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

  // ── SINGLE JOB CARD (OPENS JobDescriptionPage WITH PARTICULAR JOB DETAILS) ──
  Widget _jobCard(BuildContext context, JobDisplayItem job) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobDescriptionPage(
                jobPostId: job.id,
                companyName: job.company,
                jobTitle: job.title,
                companyFullName: job.companyFullName,
                rating: job.rating,
                distance: job.distance,
                salary: job.salary,
                experience: job.experience,
                logoText: job.logoText,
                logoColor: job.logoColor,
                skills: job.skills,
                description: job.description,
                totalVacancies: job.totalVacancies,
                remainingVacancies: job.remainingVacancies,
                postedDate: job.postedDate,
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
                  color: job.logoColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    job.logoText,
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
                      job.title,
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
                          job.company,
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
                        const Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            job.distance,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
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
                          "${job.rating}",
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
                      job.salary,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    // Promotion badges
                    if (job.isPremium || job.isUrgentHiring || job.isWalkInInterview) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          if (job.isPremium)
                            _buildPromotionBadge(
                              icon: Icons.workspace_premium_rounded,
                              label: "Premium",
                              textColor: const Color(0xFFB45309),
                              bgColor: const Color(0xFFFEF3C7),
                              borderColor: const Color(0xFFFDE68A),
                            ),
                          if (job.isUrgentHiring)
                            _buildPromotionBadge(
                              icon: Icons.bolt_rounded,
                              label: "Urgent Hiring",
                              textColor: const Color(0xFFC2410C),
                              bgColor: const Color(0xFFFFEDD5),
                              borderColor: const Color(0xFFFED7AA),
                            ),
                          if (job.isWalkInInterview)
                            _buildPromotionBadge(
                              icon: Icons.badge_outlined,
                              label: "Walk-in Interview",
                              textColor: const Color(0xFF1D4ED8),
                              bgColor: const Color(0xFFDBEAFE),
                              borderColor: const Color(0xFFBFDBFE),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Status pill + Apply action button
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
                      job.status,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => _handleCardApply(context, job),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Apply",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionBadge({
    required IconData icon,
    required String label,
    required Color textColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.5, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }



  Future<void> _handleCardApply(BuildContext context, JobDisplayItem job) async {
    final userDetails = await SessionManager.getUserDetails();
    final userId = (userDetails['id'] is int)
        ? userDetails['id'] as int
        : int.tryParse(userDetails['id']?.toString() ?? '0') ?? 0;

    if (userId == 0) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please log in first to apply."),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final isEligible = await JobApplicationService().validateResumeCompletion(context);
    if (!isEligible) return;

    final response = await JobApplicationService().applyForJob(
      userId: userId,
      jobPostId: job.id > 0 ? job.id : 1,
    );

    if (!context.mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Application submitted successfully for ${job.title}!"),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final msg = response['message']?.toString() ?? "Failed to submit application.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ── BOTTOM NAV ITEM HELPER ──
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
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.unselected,
              size: 23,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}