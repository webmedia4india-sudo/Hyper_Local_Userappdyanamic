import 'dart:ui';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/invitecandidatedpage.dart';
import 'package:video_player/video_player.dart';
import 'package:hyper_local/Pages/aboutapppage.dart';
import 'package:hyper_local/Pages/applicationtrackerpage.dart';
import 'package:hyper_local/Pages/homepage.dart';
import 'package:hyper_local/Pages/resumeuploded.dart';
import 'package:hyper_local/Pages/categoriespage.dart' show CategoriesPage;
import 'package:hyper_local/Pages/coverletterspage.dart';
import 'package:hyper_local/Pages/helpcenterpage.dart';
import 'package:hyper_local/Pages/hyperlocalfeaturespage.dart';
import 'package:hyper_local/Pages/learningcareerpage.dart';
import 'package:hyper_local/Pages/missopportunitypage.dart';
import 'package:hyper_local/Pages/notificationpage.dart';
import 'package:hyper_local/Pages/parttimejobpage.dart';
import 'package:hyper_local/Pages/governmentjobpage.dart';
import 'package:hyper_local/Pages/jobdescriptipnpage.dart';
import 'package:hyper_local/Pages/mockinterviewpage.dart';
import 'package:hyper_local/Pages/profilepage.dart';
import 'package:hyper_local/Pages/recommendedjpbpage.dart';
import 'package:hyper_local/Pages/savedjobpage.dart';
import 'package:hyper_local/Pages/settingpage.dart';
import 'package:hyper_local/Pages/supportticketspage.dart';
import 'package:hyper_local/Pages/wallectpremiumpage.dart';
import 'package:hyper_local/Pages/workfromhomepage.dart';
import 'package:hyper_local/Screen/login_screen.dart';
import 'package:hyper_local/utils/app_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'jobnearmappage.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyper_local/services/api_service.dart';
import 'package:hyper_local/utils/session_manager.dart';
import 'package:hyper_local/controllers/auth_controller.dart';
import 'package:hyper_local/services/category_service.dart';
import 'package:hyper_local/services/banner_service.dart';
import 'package:hyper_local/models/banner/banner_model.dart';
import 'package:hyper_local/services/missed_opportunity_service.dart';
import 'package:hyper_local/models/job/missed_opportunity_model.dart';
import 'package:hyper_local/models/job/job_model.dart';
import 'package:hyper_local/models/job/recent_job_model.dart';
import 'package:hyper_local/services/job_service.dart';
import 'package:hyper_local/controllers/recent_job_controller.dart';
import 'package:hyper_local/services/company_service.dart';
import 'package:hyper_local/models/company/company_model.dart';
import 'package:hyper_local/services/location_service.dart';
import 'package:hyper_local/models/location/city_model.dart';

/// ── GEN-Z PASTEL PALETTE (taken from reference collage image) ──────────
/// Purple / Lavender / Pink / Coral / Mint — soft, rounded, poppy.
/// Header + Sidebar now use a PURPLE GRADIENT (solid removed).
class GenZ {
  static const Color purple = AppColors.primary;
  static const Color purpleDark = AppColors.primaryDark;
  static const Color purpleDeep = AppColors.primaryDeep;
  static const Color lavender = AppColors.lime;
  static const Color lavenderSoft = AppColors.limeSoft;
  static const Color pink = AppColors.pink;
  static const Color pinkSoft = AppColors.pinkSoft;
  static const Color coral = AppColors.coral;
  static const Color coralSoft = AppColors.coralSoft;
  static const Color mint = AppColors.mint;
  static const Color mintSoft = AppColors.mintSoft;

  // ── BLUE GRADIENT for TOP HEADER (matching uploaded image theme, right side made darker) ──
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF001090), // Very deep navy/royal blue
      Color(0xFF0020C2), // Rich Dark Blue from image
      Color(0xFF004AE0), // Darker vibrant blue on the right (was 0xFF8AD1FC)
    ],
  );

  // ── BLUE GRADIENT for SIDEBAR/DRAWER header (matching uploaded image theme, right side made darker) ──
  static const LinearGradient drawerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF001090),
      Color(0xFF0020C2),
      Color(0xFF004AE0),
    ],
  );

  // ── SOFT GRADIENT for OVERALL PAGE BACKGROUND ──
  static const LinearGradient pageBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8ECFF), // very light blue at top
      AppColors.scaffoldBackground, // near-white blue-white
      Color(0xFFFFFFFF), // white towards bottom
    ],
  );

  // cycling accent colors for cards / logos / categories (kept multi-color)
  static const List<Color> accents = [purple, coral, mint, pink, lavender];
  static const List<Color> accentsSoft = [
    Color(0xFFDCE3FF),
    coralSoft,
    mintSoft,
    pinkSoft,
    lavenderSoft,
  ];
}

/// ── TAP-SCALE "HOVER" WRAPPER ────────────────────────────────────────
/// Mobile has no real hover, so this gives a snappy shrink-on-press feel
/// which reads as "hover/interactive" in a Gen-Z UI.
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const TapScale({super.key, required this.child, this.onTap});

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  double _scale = 1.0;

  void _setScale(double v) => setState(() => _scale = v);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setScale(0.94),
      onTapUp: (_) => _setScale(1.0),
      onTapCancel: () => _setScale(1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// ── 3D PRESS WRAPPER ──────────────────────────────────────────────────
/// Gives job cards a "pressable 3D button" feel: card sits raised with a
/// deep drop shadow; on press it sinks down and the shadow shrinks, like
/// it's physically being pushed into the screen.
class Tap3D extends StatefulWidget {
  final Widget Function(bool pressed) builder;
  final VoidCallback? onTap;
  const Tap3D({super.key, required this.builder, this.onTap});

  @override
  State<Tap3D> createState() => _Tap3DState();
}

class _Tap3DState extends State<Tap3D> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, _pressed ? 4.0 : 0.0)
          ..setEntry(3, 2, 0.0015)
          ..rotateX(_pressed ? 0.0 : -0.012)
          ..rotateY(_pressed ? 0.0 : 0.012),
        transformAlignment: Alignment.center,
        child: widget.builder(_pressed),
      ),
    );
  }
}

/// ── DECORATIVE BLOB (soft translucent circle) ─────────────────────────
/// Used behind the purple header/drawer header for extra depth & attractiveness.
class _HeaderBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _HeaderBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 1;

  // ── USER PROFILE & RESUME PROGRESS STATE (DYNAMIC) ──
  String _userName = "User";
  String _userFirstName = "User";
  String _userEmail = "";
  String _userMobile = "";
  String? _userPhoto;

  int _resumeCompletionPercent = 0;
  int _resumeCompletedPoints = 0;
  int _resumeTotalPoints = 9;

  final AuthController _authController = AuthController();
  final CategoryService _categoryService = CategoryService();
  final BannerService _bannerService = BannerService();
  List<Map<String, dynamic>> _dynamicCategories = [];
  List<Map<String, dynamic>> _dynamicBanners = [];
  bool _isLoadingCategories = true;
  String? _categoriesError;

  List<Map<String, dynamic>> _dynamicNearbyJobs = [];
  bool _isLoadingNearbyJobs = true;
  String? _nearbyJobsError;
  double _nearbyJobsProgress = 0.0;
  String _nearbyJobsProgressText = "0%";

  final JobService _jobService = JobService();
  final RecentJobController _recentJobController = RecentJobController();
  List<Map<String, dynamic>> _dynamicRecentJobs = [];
  bool _isLoadingRecentJobs = true;
  Timer? _dashboardAutoRefreshTimer;

  int _missedOpportunitiesCount = 0;
  List<MissedOpportunityModel> _missedOpportunityItems = [];
  bool _isLoadingMissedOpportunities = true;

  final CompanyService _companyService = CompanyService();
  final LocationService _locationService = LocationService();
  List<CompanyModel> _dynamicCompanies = [];
  bool _isLoadingCompanies = true;
  String? _companiesError;

  Future<void> _fetchCompanies() async {
    if (mounted) {
      setState(() {
        _isLoadingCompanies = true;
        _companiesError = null;
      });
    }
    try {
      final list = await _companyService.getCompanies();
      if (!mounted) return;
      setState(() {
        _dynamicCompanies = list;
        _isLoadingCompanies = false;
        _companiesError = null;
      });
    } catch (e) {
      debugPrint("Error fetching companies: $e");
      if (mounted) {
        setState(() {
          _dynamicCompanies = [];
          _isLoadingCompanies = false;
          _companiesError = "Failed to load companies";
        });
      }
    }
  }

  Future<void> _fetchMissedOpportunities() async {
    try {
      final userDetails = await SessionManager.getUserDetails();
      final userId = (userDetails['id'] is int)
          ? userDetails['id'] as int
          : int.tryParse(userDetails['id']?.toString() ?? '0') ?? 0;

      if (userId == 0) {
        if (mounted) {
          setState(() {
            _missedOpportunitiesCount = 0;
            _missedOpportunityItems = [];
            _isLoadingMissedOpportunities = false;
          });
        }
        return;
      }

      final result = await MissedOpportunityService().getMissedOpportunitiesByUser(userId);
      if (mounted) {
        if (result['success'] == true) {
          final items = (result['items'] as List<MissedOpportunityModel>?) ?? [];
          final filteredItems = items.where((m) => m.isWithinRetentionPeriod).toList();
          setState(() {
            _missedOpportunitiesCount = filteredItems.length;
            _missedOpportunityItems = filteredItems;
            _isLoadingMissedOpportunities = false;
          });
        } else {
          setState(() {
            _missedOpportunitiesCount = 0;
            _missedOpportunityItems = [];
            _isLoadingMissedOpportunities = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching dashboard missed opportunities: $e");
      if (mounted) {
        setState(() {
          _missedOpportunitiesCount = 0;
          _missedOpportunityItems = [];
          _isLoadingMissedOpportunities = false;
        });
      }
    }
  }

  Future<void> _fetchNearbyJobs() async {
    if (mounted) {
      setState(() {
        _isLoadingNearbyJobs = true;
        _nearbyJobsError = null;
      });
    }

    double lat = 20.9374;
    double lng = 77.7796;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 4),
          );
          lat = pos.latitude;
          lng = pos.longitude;
        }
      }
    } catch (e) {
      debugPrint("Location check error: $e");
    }

    try {
      // Resolve selected city ID if not set yet
      if (_selectedCityId == null || _selectedCityId! <= 0) {
        final savedId = await SessionManager.getSelectedCityId();
        if (savedId != null && savedId > 0) {
          _selectedCityId = savedId;
        }
      }

      final response = await ApiService().getNearbyJobs(
        lat,
        lng,
        radius: 50.0,
        cityId: _selectedCityId,
      );
      List<dynamic> rawJobs = [];

      if (response != null) {
        if (response['data'] is List && (response['data'] as List).isNotEmpty) {
          rawJobs = response['data'];
        } else if (response['jobs'] is List && (response['jobs'] as List).isNotEmpty) {
          rawJobs = response['jobs'];
        } else if (response['jobPosts'] is List && (response['jobPosts'] as List).isNotEmpty) {
          rawJobs = response['jobPosts'];
        } else if (response['nearbyJobs'] is List && (response['nearbyJobs'] as List).isNotEmpty) {
          rawJobs = response['nearbyJobs'];
        } else if (response['results'] is List && (response['results'] as List).isNotEmpty) {
          rawJobs = response['results'];
        }
      }

      final List<Map<String, dynamic>> parsedJobs = [];
      final List<Color> accentColors = [GenZ.purple, GenZ.coral, GenZ.pink, GenZ.mint, GenZ.lavender];

      for (int i = 0; i < rawJobs.length; i++) {
        final item = rawJobs[i];
        if (item is Map<String, dynamic>) {
          // Strictly filter the jobs count using the logged-in user's current city_id.
          // Do not count jobs from other cities.
          if (_selectedCityId != null && _selectedCityId! > 0) {
            final jobCityId = item['city_id'] ?? item['cityId'];
            final parsedJobCityId = jobCityId is int
                ? jobCityId
                : int.tryParse(jobCityId?.toString() ?? '');
            if (parsedJobCityId != null && parsedJobCityId != _selectedCityId) {
              continue;
            }
          }

          final title = (item['job_title'] ?? item['title'] ?? item['jobTitle'] ?? 'Job Opening').toString();
          final company = (item['company_name'] ?? item['company'] ?? item['companyName'] ?? item['job_category'] ?? 'Company').toString();
          final logoText = company.trim().isNotEmpty ? company.trim().substring(0, 1).toUpperCase() : 'J';
          final logoColor = accentColors[i % accentColors.length];

          final minSalaryVal = item['min_salary'] is num
              ? (item['min_salary'] as num).toInt()
              : int.tryParse(item['min_salary']?.toString() ?? item['salary_min']?.toString() ?? '0') ?? 0;
          final maxSalaryVal = item['max_salary'] is num
              ? (item['max_salary'] as num).toInt()
              : int.tryParse(item['max_salary']?.toString() ?? item['salary_max']?.toString() ?? '0') ?? 0;

          String salaryStr;
          if (item['salary'] != null && item['salary'].toString().trim().isNotEmpty) {
            salaryStr = item['salary'].toString();
          } else if (minSalaryVal > 0 && maxSalaryVal > 0) {
            salaryStr = "₹${minSalaryVal.toString().replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'), (Match m) => '${m[1]},')} - ₹${maxSalaryVal.toString().replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'), (Match m) => '${m[1]},')}";
          } else if (minSalaryVal > 0) {
            salaryStr = "₹${minSalaryVal.toString().replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'), (Match m) => '${m[1]},')}+";
          } else {
            salaryStr = "Competitive Salary";
          }

          final distanceKm = item['distance_km'] is num
              ? (item['distance_km'] as num).toDouble()
              : (item['distance'] is num
                  ? (item['distance'] as num).toDouble()
                  : double.tryParse(item['distance_km']?.toString() ?? item['distance']?.toString() ?? '0.0') ?? 0.0);

          final String distanceStr;
          if (distanceKm == 0.0 && (item['latitude'] != null || item['lat'] != null)) {
            distanceStr = "0 m away";
          } else if (distanceKm > 0 && distanceKm < 1.0) {
            distanceStr = "${(distanceKm * 1000).round()} m away";
          } else if (distanceKm >= 1.0) {
            distanceStr = "${distanceKm.toStringAsFixed(1)} km away";
          } else {
            distanceStr = item['distance']?.toString() ?? "Nearby";
          }

          final logoUrlStr = (item['logo_url'] ?? item['logoUrl'] ?? item['company_logo'] ?? '').toString();

          parsedJobs.add({
            "id": item['id'] ?? item['_id'] ?? item['job_post_id'],
            "title": title,
            "company": company,
            "companyFullName": item['company_full_name'] ?? company,
            "distance": distanceStr,
            "salary": salaryStr,
            "logoText": logoText,
            "logoColor": logoColor,
            "logoUrl": logoUrlStr,
            "rating": item['rating'] is num ? (item['rating'] as num).toDouble() : 4.2,
            "reviewCount": item['reviews_count']?.toString() ?? "3.5k reviews",
            "experience": item['experience_required']?.toString() ?? "1-2 years",
            "skills": item['skills'] is List ? List<String>.from(item['skills']) : <String>["Flutter", "Dart"],
            "description": item['description']?.toString() ?? "Job opportunity near you.",
            "totalVacancies": item['number_of_vacancies'] is num ? (item['number_of_vacancies'] as num).toInt() : 1,
            "remainingVacancies": item['remaining_vacancies'] is num ? (item['remaining_vacancies'] as num).toInt() : 1,
            "postedDate": item['posted_on']?.toString() ?? "Recently",
            "employmentType": (item['employment_type'] ?? item['job_type_id'])?.toString() ?? '',
            "isPartTime": (item['employment_type'] ?? '').toString().toLowerCase().contains('part') ||
                title.toLowerCase().contains('part-time') ||
                item['isPartTime'] == true,
            "isWFH": (item['employment_type'] ?? '').toString().toLowerCase().contains('work from home') ||
                (item['employment_type'] ?? '').toString().toLowerCase().contains('wfh') ||
                title.toLowerCase().contains('work from home') ||
                title.toLowerCase().contains('wfh') ||
                item['isWFH'] == true ||
                item['is_wfh'] == true,
            "isPremium": item['is_premium'] == 1 || item['is_premium'] == true || item['is_premium'] == '1' || item['isPremium'] == true,
            "isUrgentHiring": item['is_urgent_hiring'] == 1 || item['is_urgent_hiring'] == true || item['is_urgent_hiring'] == '1' || item['isUrgentHiring'] == true || item['isUrgent'] == true,
            "isWalkIn": item['is_walk_in_interview'] == 1 || item['is_walk_in_interview'] == true || item['is_walk_in_interview'] == '1' || item['is_walk_in_interview'].toString().trim() == '1' || item['isWalkInInterview'] == true || item['isWalkIn'] == true,
            "isWalkInInterview": item['is_walk_in_interview'] == 1 || item['is_walk_in_interview'] == true || item['is_walk_in_interview'] == '1' || item['is_walk_in_interview'].toString().trim() == '1' || item['isWalkInInterview'] == true || item['isWalkIn'] == true,
            "is_walk_in_interview": (item['is_walk_in_interview'] == 1 || item['is_walk_in_interview'] == true || item['is_walk_in_interview'] == '1' || item['is_walk_in_interview'].toString().trim() == '1' || item['isWalkInInterview'] == true || item['isWalkIn'] == true) ? 1 : 0,
            "isFeatured": item['is_featured'] == 1 || item['is_featured'] == true || item['is_featured'] == '1' || item['isFeatured'] == true,
            "raw": item,
          });
        }
      }

      // Progress calculation:
      // Filter the jobs count using the logged-in user's current city_id.
      // progressPercentage = min(availableJobsCount * 10, 100)
      final int availableJobsCount = parsedJobs.length;
      final int nearbyPct = math.min(availableJobsCount * 10, 100).clamp(0, 100);
      final double nearbyProg = (nearbyPct / 100.0).clamp(0.0, 1.0);

      if (mounted) {
        setState(() {
          _dynamicNearbyJobs = parsedJobs;
          _isLoadingNearbyJobs = false;
          _nearbyJobsProgress = nearbyProg;
          _nearbyJobsProgressText = "$nearbyPct%";
        });
      }
    } catch (e) {
      debugPrint("Error fetching nearby jobs: $e");
      if (mounted) {
        setState(() {
          _dynamicNearbyJobs = [];
          _isLoadingNearbyJobs = false;
          _nearbyJobsError = "Failed to load nearby jobs";
          _nearbyJobsProgress = 0.0;
          _nearbyJobsProgressText = "0%";
        });
      }
    }
  }

  Future<void> _fetchRecentJobs() async {
    if (mounted) {
      setState(() {
        _isLoadingRecentJobs = true;
      });
    }

    try {
      List<JobModel> fetchedList = await _jobService.getJobs(cityId: _selectedCityId);

      // If JobService returned empty, attempt direct fallback to /jobpost/public
      if (fetchedList.isEmpty) {
        final queryParam = (_selectedCityId != null && _selectedCityId! > 0) ? '?city_id=$_selectedCityId' : '';
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
          fetchedList = rawList
              .map((json) => JobModel.fromJson(Map<String, dynamic>.from(json)))
              .where((job) {
                final s = job.status.toLowerCase().trim();
                final matchesStatus = s == 'active' || s == 'published' || s.isEmpty;
                final matchesCity = _selectedCityId == null || _selectedCityId == 0 || job.cityId == _selectedCityId;
                return matchesStatus && matchesCity;
              })
              .toList();
        }
      } else if (_selectedCityId != null && _selectedCityId! > 0) {
        fetchedList = fetchedList.where((job) => job.cityId == _selectedCityId).toList();
      }

      if (fetchedList.isNotEmpty) {
        // Sort newest first by createdAt / postedOn / id
        final sortedList = List<JobModel>.from(fetchedList);
        sortedList.sort((a, b) {
          if (a.createdAt != null && b.createdAt != null) {
            final dtA = DateTime.tryParse(a.createdAt!);
            final dtB = DateTime.tryParse(b.createdAt!);
            if (dtA != null && dtB != null) {
              return dtB.compareTo(dtA);
            }
          }
          if (a.postedOn != null && b.postedOn != null) {
            final dtA = DateTime.tryParse(a.postedOn!);
            final dtB = DateTime.tryParse(b.postedOn!);
            if (dtA != null && dtB != null) {
              return dtB.compareTo(dtA);
            }
          }
          return b.id.compareTo(a.id);
        });

        final List<Color> accentColors = [
          GenZ.purple,
          GenZ.coral,
          GenZ.pink,
          GenZ.mint,
          GenZ.lavender,
        ];

        final List<Map<String, dynamic>> parsedJobs = [];
        for (int i = 0; i < sortedList.length; i++) {
          final job = sortedList[i];
          final compName = job.companyName.trim().isNotEmpty ? job.companyName.trim() : "Company";
          final logoChar = compName.isNotEmpty ? compName.substring(0, 1).toUpperCase() : "J";

          parsedJobs.add({
            "id": job.id,
            "title": job.title.trim().isNotEmpty ? job.title.trim() : "Job Opening",
            "company": compName,
            "companyFullName": compName,
            "distance": job.formattedDistance,
            "salary": job.formattedSalary,
            "logoText": logoChar,
            "logoColor": accentColors[i % accentColors.length],
            "rating": job.displayRating,
            "reviewCount": job.displayReviewCount,
            "experience": (job.experienceRequired != null && job.experienceRequired!.trim().isNotEmpty)
                ? job.experienceRequired!
                : "1-2 years",
            "skills": job.skills.isNotEmpty ? job.skills : <String>["Communication"],
            "description": (job.description != null && job.description!.trim().isNotEmpty)
                ? job.description!
                : "Recently posted job opening.",
            "totalVacancies": job.totalVacancies > 0 ? job.totalVacancies : 1,
            "remainingVacancies": job.remainingVacancies > 0 ? job.remainingVacancies : 1,
            "postedDate": job.formattedPostedDate,
            "employmentType": job.employmentType ?? '',
            "isPartTime": job.isPartTime,
            "isWFH": job.isWFH,
            "isPremium": job.isPremium,
            "isUrgentHiring": job.isUrgentHiring,
            "isWalkIn": job.isWalkInInterview,
            "isWalkInInterview": job.isWalkInInterview,
            "is_walk_in_interview": job.isWalkInInterview ? 1 : 0,
            "isFeatured": job.isFeatured,
            "city_id": job.cityId,
            "cityId": job.cityId,
            "city_name": job.cityName,
            "cityName": job.cityName,
            "state_id": job.stateId,
            "state_name": job.stateName,
            "raw": job.toJson(),
          });
        }

        if (mounted) {
          setState(() {
            _dynamicRecentJobs = parsedJobs;
            _isLoadingRecentJobs = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _dynamicRecentJobs = [];
            _isLoadingRecentJobs = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching recent jobs: $e");
      if (mounted) {
        setState(() {
          _dynamicRecentJobs = [];
          _isLoadingRecentJobs = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _activeSliderItems => _dynamicBanners;

  Future<void> _fetchBanners() async {
    try {
      List<BannerModel> fetchedList = await _bannerService.getBanners();
      if (fetchedList.isEmpty) {
        fetchedList = await _bannerService.getAllBanners();
      }

      if (!mounted) return;

      if (fetchedList.isEmpty) {
        setState(() {
          _dynamicBanners = [];
        });
        return;
      }

      final List<Map<String, dynamic>> items = [];
      final gradients = [
        const LinearGradient(
          colors: [Color(0xFF3F2B96), Color(0xFFA8C0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xFFF12711), Color(0xFFF5AF19)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xFF8A2387), Color(0xFFE94057)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ];

      for (int i = 0; i < fetchedList.length; i++) {
        final b = fetchedList[i];

        String img = b.imageUrl.trim();
        if (img.isNotEmpty) {
          if (!img.startsWith('http://') && !img.startsWith('https://')) {
            final base = ApiService.baseUrl.replaceAll('/api', '');
            final clean = img.startsWith('/') ? img.substring(1) : img;
            img = '$base/$clean';
          } else if (img.contains('localhost:5000') || img.contains('127.0.0.1:5000')) {
            final base = ApiService.baseUrl.replaceAll('/api', '');
            img = img
                .replaceAll('http://localhost:5000', base)
                .replaceAll('http://127.0.0.1:5000', base);
          }
        }

        final isVideo = img.toLowerCase().endsWith('.mp4') ||
            img.toLowerCase().endsWith('.mov') ||
            img.toLowerCase().endsWith('.avi') ||
            img.toLowerCase().endsWith('.mkv');

        items.add({
          "id": b.id,
          "title": b.title.isNotEmpty ? b.title : "Featured Banner",
          "subtitle": (b.subtitle != null && b.subtitle!.trim().isNotEmpty)
              ? b.subtitle!
              : "Explore top opportunities",
          "badge": (b.tag != null && b.tag!.trim().isNotEmpty) ? b.tag! : "FEATURED",
          "gradient": gradients[i % gradients.length],
          "icon": Icons.stars_rounded,
          "image": img,
          "isVideo": isVideo,
          "isNetworkVideo": isVideo,
          "videoUrl": isVideo ? img : null,
          "buttonText": (b.buttonText != null && b.buttonText!.trim().isNotEmpty)
              ? b.buttonText!
              : "Explore Now",
          "redirectType": b.redirectType,
          "redirectValue": b.redirectValue,
          "route": b.redirectValue ?? b.redirectType?.toLowerCase() ?? "",
        });
      }

      setState(() {
        _dynamicBanners = items;
        if (_currentSliderPage >= _dynamicBanners.length) {
          _currentSliderPage = 0;
        }
      });
    } catch (e) {
      debugPrint("Error fetching banners: $e");
      if (mounted) {
        setState(() {
          _dynamicBanners = [];
        });
      }
    }
  }

  Future<void> _fetchCategories() async {
    if (mounted) {
      setState(() {
        _isLoadingCategories = true;
        _categoriesError = null;
      });
    }
    try {
      final fetchedList = await _categoryService.getCategories();
      if (!mounted) return;

      if (fetchedList.isNotEmpty) {
        final List<Map<String, dynamic>> formatted = [];
        final colors = [GenZ.purple, GenZ.coral, GenZ.pink, GenZ.mint];

        for (int i = 0; i < fetchedList.length; i++) {
          final cat = fetchedList[i];

          String formatUrl(String? raw) {
            if (raw == null || raw.trim().isEmpty) return '';
            final p = raw.trim();
            if (p.startsWith('http://') || p.startsWith('https://')) return p;
            final base = ApiService.baseUrl.replaceAll('/api', '');
            final clean = p.startsWith('/') ? p.substring(1) : p;
            return '$base/$clean';
          }

          final bgUrl = formatUrl(cat.backgroundImg);
          final iconUrl = formatUrl(cat.iconImg);

          formatted.add({
            "id": cat.id,
            "label": cat.title,
            "icon": _getIconForCategoryTitle(cat.title, i),
            "color": colors[i % colors.length],
            "openings": (cat.subtitle != null && cat.subtitle!.trim().isNotEmpty)
                ? cat.subtitle!
                : "Explore Openings",
            "bgImage": bgUrl.isNotEmpty ? bgUrl : null,
            "iconImg": iconUrl.isNotEmpty ? iconUrl : null,
          });
        }

        setState(() {
          _dynamicCategories = formatted;
          _isLoadingCategories = false;
          _categoriesError = null;
        });
      } else {
        setState(() {
          _dynamicCategories = [];
          _isLoadingCategories = false;
          _categoriesError = null;
        });
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      if (mounted) {
        setState(() {
          _dynamicCategories = [];
          _isLoadingCategories = false;
          _categoriesError = "Failed to load categories";
        });
      }
    }
  }

  IconData _getIconForCategoryTitle(String title, int index) {
    final t = title.toLowerCase();
    if (t.contains('delivery') || t.contains('courier')) return Icons.electric_moped_rounded;
    if (t.contains('retail') || t.contains('store')) return Icons.shopping_bag_rounded;
    if (t.contains('hotel') || t.contains('hospitality')) return Icons.room_service_rounded;
    if (t.contains('sales') || t.contains('marketing')) return Icons.campaign_rounded;
    if (t.contains('tech') || t.contains('code') || t.contains('it') || t.contains('software')) return Icons.code_rounded;
    if (t.contains('design')) return Icons.palette_rounded;
    if (t.contains('office')) return Icons.business_center_rounded;
    if (t.contains('driver')) return Icons.directions_car_filled_rounded;
    if (t.contains('manufactur') || t.contains('factory')) return Icons.factory_rounded;
    if (t.contains('health') || t.contains('medical')) return Icons.medical_services_rounded;
    if (t.contains('construct')) return Icons.construction_rounded;

    final defaultList = [
      Icons.work_rounded,
      Icons.category_rounded,
      Icons.business_center_rounded,
      Icons.stars_rounded,
      Icons.widgets_rounded,
    ];
    return defaultList[index % defaultList.length];
  }

  Future<void> _fetchUserProfileAndResume() async {
    // 1. Load cached details first
    final details = await SessionManager.getUserDetails();
    final prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        final name = (details['name'] != null && details['name'].toString().trim().isNotEmpty)
            ? details['name'].toString().trim()
            : "User";
        _userName = name;
        _userFirstName = name.split(' ').first;
        _userEmail = (details['email'] != null) ? details['email'].toString().trim() : "";
        _userMobile = (details['mobile'] != null) ? details['mobile'].toString().trim() : "";
        _userPhoto = details['photo']?.toString();

        _resumeCompletionPercent = prefs.getInt('resume_completion_percent') ?? 0;
        _resumeCompletedPoints = prefs.getInt('resume_completed_points') ?? 0;
        _resumeTotalPoints = prefs.getInt('resume_total_points') ?? 9;
      });
    }

    // 2. Fetch fresh profile from backend (/api/user/profile)
    try {
      final success = await _authController.getProfile();
      if (success && _authController.profileData != null) {
        final p = _authController.profileData!;
        if (mounted) {
          setState(() {
            if (p.name.isNotEmpty) {
              _userName = p.name;
              _userFirstName = p.name.split(' ').first;
            }
            if (p.email.isNotEmpty) _userEmail = p.email;
            if (p.mobileNo.isNotEmpty) _userMobile = p.mobileNo;
            if (p.profilePhoto != null && p.profilePhoto!.isNotEmpty) {
              _userPhoto = p.profilePhoto;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching dashboard user profile: $e");
    }

    // 3. Fetch fresh resume progress from backend (/api/resume)
    try {
      final token = await SessionManager.getToken();
      if (token != null && token.isNotEmpty) {
        final url = Uri.parse('${ApiService.baseUrl}/resume');
        final response = await http.get(
          url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 6));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded['success'] == true && decoded['data'] != null) {
            final data = decoded['data'] as Map<String, dynamic>;
            final serverPercent = (data['completion_percentage'] as num?)?.toInt() ?? 0;

            int count = 0;
            if (data['full_name'] != null && data['full_name'].toString().trim().isNotEmpty) count++;
            if (data['objective'] != null && data['objective'].toString().trim().isNotEmpty) count++;
            if (data['skills'] != null && (data['skills'] as List).isNotEmpty) count++;
            if (data['languages'] != null && (data['languages'] as List).isNotEmpty) count++;
            if (data['education'] != null && (data['education'] as List).isNotEmpty) count++;
            if (data['certifications'] != null && (data['certifications'] as List).isNotEmpty) count++;
            if (data['experiences'] != null && (data['experiences'] as List).isNotEmpty) count++;
            if (data['projects'] != null && (data['projects'] as List).isNotEmpty) count++;
            if (data['accomplishments'] != null && (data['accomplishments'] as List).isNotEmpty) count++;

            await prefs.setInt('resume_completion_percent', serverPercent);
            await prefs.setInt('resume_completed_points', count);
            await prefs.setInt('resume_total_points', 9);

            if (mounted) {
              setState(() {
                _resumeCompletionPercent = serverPercent;
                _resumeCompletedPoints = count;
                _resumeTotalPoints = 9;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching dashboard resume progress: $e");
    }
  }

  ImageProvider? _getDrawerAvatarImage() {
    if (_userPhoto != null && _userPhoto!.trim().isNotEmpty) {
      final photo = _userPhoto!.trim();
      if (photo.startsWith('http://') || photo.startsWith('https://')) {
        return NetworkImage(photo);
      } else if (!kIsWeb && File(photo).existsSync()) {
        return FileImage(File(photo));
      } else {
        final baseUrlNoApi = ApiService.baseUrl.replaceAll('/api', '');
        final fullUrl = photo.startsWith('/')
            ? "$baseUrlNoApi$photo"
            : "$baseUrlNoApi/$photo";
        return NetworkImage(fullUrl);
      }
    }
    return null;
  }

  // ── NOTIFICATION "NEW JOB POST" BLINK STATE ──────────────────────────
  bool _hasNewNotification = true; // set true whenever a new job is posted
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // ── WAVING HAND EMOJI ANIMATION ───────────────────────────────────────
  late final AnimationController _waveCtrl;
  late final Animation<double> _waveAnim;

  // ── SEARCH BAR STATE ───────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedLocation = "Amravati";
  int? _selectedCityId;
  bool _isSearchExpanded = false;

  // ── SLIDER STATE ──────────────────────────────────────────────────
  late final PageController _sliderPageController;
  Timer? _sliderTimer;
  int _currentSliderPage = 0;

  Future<void> _loadSavedLocation() async {
    try {
      final savedId = await SessionManager.getSelectedCityId();
      final savedCity = await SessionManager.getSelectedCityName();
      if (savedCity != null && savedCity.trim().isNotEmpty && mounted) {
        setState(() {
          _selectedLocation = savedCity.trim();
        });
      }
      if (savedId != null && savedId > 0) {
        _selectedCityId = savedId;
      } else {
        // Resolve cityId from cached or fetched cities
        final cities = await _locationService.getCities();
        final match = cities.firstWhere(
          (c) => c.cityName.toLowerCase() == _selectedLocation.toLowerCase(),
          orElse: () => CityModel(id: 0, cityName: _selectedLocation),
        );
        if (match.id > 0) {
          _selectedCityId = match.id;
          await SessionManager.saveSelectedCity(cityId: match.id, cityName: _selectedLocation);
        }
      }
      // Prefetch and reload jobs for the selected city
      _fetchRecentJobs();
      _recentJobController.loadRecentJobs(cityId: _selectedCityId);
      _fetchNearbyJobs();
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
  }

  /// Updates selected city in local state, SessionManager, reloads jobs,
  /// and hits the backend Update Profile API (PUT /api/user/update-profile)
  Future<void> _updateProfileCity({
    required int cityId,
    required String cityName,
  }) async {
    // 1. Save selected city locally
    await SessionManager.saveSelectedCity(
      cityId: cityId,
      cityName: cityName,
    );

    // 2. Update dashboard UI and reload jobs
    if (mounted) {
      setState(() {
        _selectedLocation = cityName;
        _selectedCityId = cityId > 0 ? cityId : null;
      });
      _fetchRecentJobs();
      _recentJobController.loadRecentJobs(cityId: _selectedCityId);
      _fetchNearbyJobs();
    }

    // 3. Hit Update Profile API to update users table in backend:
    // PUT /api/user/update-profile with payload: {"city_id": cityId}
    if (cityId > 0) {
      try {
        final token = await SessionManager.getToken();
        if (token != null && token.isNotEmpty) {
          final res = await ApiService().putRequest(
            '/user/update-profile',
            {"city_id": cityId},
          );
          debugPrint("Update Profile API (city_id: $cityId) response: $res");
        }
      } catch (e) {
        debugPrint("Error updating city in profile: $e");
      }
    }
  }

  void _showLocationSelectionDialog() {
    final TextEditingController searchController = TextEditingController();
    final TextEditingController customController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        List<CityModel> allCities = _locationService.cachedCities ?? [];
        List<CityModel> filteredCities = List.from(allCities);
        bool isLoading = allCities.isEmpty;
        String? errorMessage;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            void fetchDialogCities() async {
              try {
                final list = await _locationService.getCities();
                if (dialogContext.mounted) {
                  setDialogState(() {
                    allCities = list;
                    filteredCities = list;
                    isLoading = false;
                  });
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  setDialogState(() {
                    errorMessage = "Failed to load cities";
                    isLoading = false;
                  });
                }
              }
            }

            if (isLoading && errorMessage == null) {
              fetchDialogCities();
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Select Location",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search city...",
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (val) {
                        final q = val.trim().toLowerCase();
                        setDialogState(() {
                          if (q.isEmpty) {
                            filteredCities = List.from(allCities);
                          } else {
                            filteredCities = allCities
                                .where((c) =>
                                    c.cityName.toLowerCase().contains(q) ||
                                    (c.stateName != null &&
                                        c.stateName!.toLowerCase().contains(q)))
                                .toList();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : errorMessage != null
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          errorMessage!,
                                          style: const TextStyle(color: Colors.red),
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton(
                                          onPressed: () {
                                            setDialogState(() {
                                              isLoading = true;
                                              errorMessage = null;
                                            });
                                            fetchDialogCities();
                                          },
                                          child: const Text("Retry"),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : filteredCities.isEmpty
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          "No cities found",
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: filteredCities.length,
                                      separatorBuilder: (_, _) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final city = filteredCities[index];
                                        final isSelected = _selectedLocation
                                                .toLowerCase() ==
                                            city.cityName.toLowerCase();

                                        return ListTile(
                                          dense: true,
                                          leading: Icon(
                                            Icons.location_city_rounded,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.unselected,
                                          ),
                                          title: Text(
                                            city.cityName,
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          subtitle: city.stateName != null
                                              ? Text(
                                                  city.stateName!,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                )
                                              : null,
                                          trailing: isSelected
                                              ? const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: AppColors.primary,
                                                  size: 20,
                                                )
                                              : null,
                                          onTap: () async {
                                            final selectedId = city.id;
                                            final selectedName = city.cityName;
                                            Navigator.pop(dialogContext);
                                            await _updateProfileCity(
                                              cityId: selectedId,
                                              cityName: selectedName,
                                            );
                                          },
                                        );
                                      },
                                    ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: customController,
                              decoration: InputDecoration(
                                hintText: "Enter custom location",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 30,
                            ),
                            onPressed: () async {
                              final text = customController.text.trim();
                              if (text.isNotEmpty) {
                                Navigator.pop(dialogContext);
                                final match = allCities.firstWhere(
                                  (c) => c.cityName.toLowerCase() == text.toLowerCase(),
                                  orElse: () => CityModel(id: 0, cityName: text),
                                );
                                await _updateProfileCity(
                                  cityId: match.id,
                                  cityName: text,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([
      _recentJobController.loadRecentJobs(cityId: _selectedCityId),
      _fetchRecentJobs(),
      _fetchNearbyJobs(),
      _fetchCategories(),
      _fetchBanners(),
      _fetchCompanies(),
      _fetchMissedOpportunities(),
      _loadSavedLocation(),
    ]);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedLocation();
    _fetchUserProfileAndResume();
    _fetchCategories();
    _fetchBanners();
    _fetchCompanies();
    _fetchNearbyJobs();
    _recentJobController.addListener(() {
      if (mounted) setState(() {});
    });
    _recentJobController.loadRecentJobs(cityId: _selectedCityId);
    _fetchRecentJobs();
    _fetchMissedOpportunities();
    _dashboardAutoRefreshTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (mounted) {
        _recentJobController.loadRecentJobs(silent: true, cityId: _selectedCityId);
        _fetchRecentJobs();
        _fetchMissedOpportunities();
      }
    });
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Hand waves back and forth a few times, then stops upright
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _waveAnim = Tween<double>(
      begin: -0.28,
      end: 0.28,
    ).animate(CurvedAnimation(parent: _waveCtrl, curve: Curves.easeInOut));

    _waveCtrl.value = 0.5; // Start upright
    int waveCount = 0;
    bool isStopping = false;
    _waveCtrl.addStatusListener((status) {
      if (isStopping) return;
      if (status == AnimationStatus.completed) {
        waveCount++;
        if (waveCount >= 6) {
          isStopping = true;
          _waveCtrl.animateTo(0.5, duration: const Duration(milliseconds: 200));
        } else {
          _waveCtrl.reverse();
        }
      } else if (status == AnimationStatus.dismissed) {
        waveCount++;
        if (waveCount >= 6) {
          isStopping = true;
          _waveCtrl.animateTo(0.5, duration: const Duration(milliseconds: 200));
        } else {
          _waveCtrl.forward();
        }
      }
    });
    _waveCtrl.forward();

    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });

    // Slider auto-play timer
    _sliderPageController = PageController(initialPage: 0);
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      final listLength = _activeSliderItems.length;
      if (listLength <= 1) return;
      if (_currentSliderPage < listLength - 1) {
        _currentSliderPage++;
      } else {
        _currentSliderPage = 0;
      }
      if (_sliderPageController.hasClients) {
        _sliderPageController.animateToPage(
          _currentSliderPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sliderTimer?.cancel();
    _dashboardAutoRefreshTimer?.cancel();
    _sliderPageController.dispose();
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _searchController.dispose();
    _recentJobController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDashboard();
    }
  }

  // ── USER INFO ────────────────────────────────────────
  static const String userFirstName = "Rahul";
  static const String userName = "Rahul Sharma";
  static const String userEmail = "rahul.sharma@email.com";

  // ── QUICK ACTIONS ROW (updated) ───────────────────────
  final quickActions = [
    {
      "label": "Candidates",
      "icon": Icons.people_alt_rounded,
      "color": GenZ.mint,
    },
    {
      "label": "Nearby Jobs",
      "icon": Icons.location_on_rounded,
      "color": GenZ.coral,
    },
    {
      "label": " Applications",
      "icon": Icons.assignment_turned_in_rounded,
      "color": GenZ.purple,
    },
    {
      "label": "Build Resume",
      "icon": Icons.description_rounded,
      "color": GenZ.pink,
    },
  ];



  // ── JOBS DATA (extended with tags used for Home Sections + Personalization) ──
  final jobs = [
    {
      "title": "UI/UX Designer",
      "company": "Zoho Corporation",
      "distance": "1.8 km",
      "salary": "₹25,000 - ₹35,000",
      "logoText": "U",
      "logoColor": GenZ.purple,
      "logoUrl": "https://logo.clearbit.com/zoho.com",
      "skills": ["Figma", "UI Design", "Prototyping"],
      "isUrgent": true,
      "isNew": true,
      "isWalkIn": false,
      "isPremium": true,
      "isPartTime": false,
      "isWFH": false,
    },
    {
      "title": "Sales Management",
      "company": "Reliance Digital",
      "distance": "2.5 km",
      "salary": "₹22,000 - ₹30,000",
      "logoText": "S",
      "logoColor": GenZ.coral,
      "logoUrl": "https://logo.clearbit.com/reliancedigital.in",
      "skills": ["Sales", "Communication"],
      "isUrgent": false,
      "isNew": false,
      "isWalkIn": true,
      "isPremium": false,
      "isPartTime": false,
      "isWFH": false,
    },
    {
      "title": "Frontend Developer",
      "company": "Infosys",
      "distance": "3.2 km",
      "salary": "₹35,000 - ₹50,000",
      "logoText": "F",
      "logoColor": GenZ.mint,
      "logoUrl": "https://logo.clearbit.com/infosys.com",
      "skills": ["Flutter", "JavaScript", "React"],
      "isUrgent": true,
      "isNew": true,
      "isWalkIn": false,
      "isPremium": true,
      "isPartTime": false,
      "isWFH": false,
    },
    {
      "title": "Backend Developer",
      "company": "TCS",
      "distance": "2.9 km",
      "salary": "₹38,000 - ₹55,000",
      "logoText": "B",
      "logoColor": GenZ.pink,
      "logoUrl": "https://logo.clearbit.com/tcs.com",
      "skills": ["Node.js", "Java"],
      "isUrgent": false,
      "isNew": false,
      "isWalkIn": false,
      "isPremium": false,
      "isPartTime": false,
      "isWFH": false,
    },
    {
      "title": "Delivery Executive",
      "company": "Swiggy",
      "distance": "1.2 km",
      "salary": "₹15,000 - ₹20,000",
      "logoText": "D",
      "logoColor": GenZ.lavender,
      "logoUrl": "https://logo.clearbit.com/swiggy.com",
      "skills": ["Driving", "Delivery"],
      "isUrgent": true,
      "isNew": false,
      "isWalkIn": true,
      "isPremium": false,
      "isPartTime": true,
      "isWFH": false,
    },
    {
      "title": "Data Entry Operator",
      "company": "Wipro",
      "distance": "4.0 km",
      "salary": "₹12,000 - ₹18,000",
      "logoText": "W",
      "logoColor": GenZ.purple,
      "logoUrl": "https://logo.clearbit.com/wipro.com",
      "skills": ["Typing", "MS Office"],
      "isUrgent": false,
      "isNew": true,
      "isWalkIn": false,
      "isPremium": false,
      "isPartTime": true,
      "isWFH": false,
    },
    {
      "title": "Customer Support Executive",
      "company": "Airtel",
      "distance": "2.1 km",
      "salary": "₹18,000 - ₹24,000",
      "logoText": "A",
      "logoColor": GenZ.coral,
      "logoUrl": "https://logo.clearbit.com/airtel.in",
      "skills": ["Calling", "English"],
      "isUrgent": false,
      "isNew": true,
      "isWalkIn": true,
      "isPremium": false,
      "isPartTime": false,
      "isWFH": false,
    },
    {
      "title": "Content Writer",
      "company": "Byju's",
      "distance": "3.5 km",
      "salary": "₹12,000 - ₹16,000",
      "logoText": "B",
      "logoColor": GenZ.purple,
      "logoUrl": "https://logo.clearbit.com/byjus.com",
      "skills": ["Writing", "SEO"],
      "isUrgent": false,
      "isNew": false,
      "isWalkIn": false,
      "isPremium": false,
      "isPartTime": true,
      "isWFH": false,
    },
    {
      "title": "Graphic Designer",
      "company": "Canva",
      "distance": "5.0 km",
      "salary": "₹20,000 - ₹28,000",
      "logoText": "C",
      "logoColor": GenZ.pink,
      "logoUrl": "https://logo.clearbit.com/canva.com",
      "skills": ["Figma", "Photoshop"],
      "isUrgent": false,
      "isNew": false,
      "isWalkIn": false,
      "isPremium": true,
      "isPartTime": false,
      "isWFH": false,
    },
    {
      "title": "Flutter Developer",
      "company": "Razorpay",
      "distance": "1.5 km",
      "salary": "₹40,000 - ₹55,000",
      "logoText": "R",
      "logoColor": GenZ.mint,
      "logoUrl": "https://logo.clearbit.com/razorpay.com",
      "skills": ["Flutter", "Dart"],
      "isUrgent": true,
      "isNew": true,
      "isWalkIn": false,
      "isPremium": true,
      "isPartTime": false,
      "isWFH": false,
    },
    {
      "title": "Telecaller",
      "company": "HDFC Bank",
      "distance": "1.9 km",
      "salary": "₹15,000 - ₹22,000",
      "logoText": "H",
      "logoColor": GenZ.purple,
      "logoUrl": "https://logo.clearbit.com/hdfcbank.com",
      "skills": ["Calling", "Sales"],
      "isUrgent": false,
      "isNew": false,
      "isWalkIn": true,
      "isPremium": false,
      "isPartTime": false,
      "isWFH": false,
    },
  ];

  // ── CAREER TIPS (static demo data) ─────────────────────
  final careerTips = [
    {
      "icon": Icons.description_rounded,
      "title": "Perfect Your Resume",
      "subtitle": "Tips to make your resume stand out",
      "color": GenZ.purple,
    },
    {
      "icon": Icons.record_voice_over_rounded,
      "title": "Ace The Interview",
      "subtitle": "Common questions & how to answer",
      "color": GenZ.coral,
    },
    {
      "icon": Icons.trending_up_rounded,
      "title": "Upskill Yourself",
      "subtitle": "Courses to boost your career",
      "color": GenZ.mint,
    },
    {
      "icon": Icons.handshake_rounded,
      "title": "Networking Tips",
      "subtitle": "Build connections that matter",
      "color": GenZ.pink,
    },
  ];

  // ── HOME PERSONALIZATION: mock user profile used to drive recommendations ──
  // Real app madhe he backend/API varun yeil (candidate profile, resume, activity)
  final userProfile = {
    "skills": ["Flutter", "UI Design", "Figma"],
    "experience": "2 years",
    "education": "B.Tech Computer Science",
    "preferredRole": "Frontend Developer",
    "currentLocation": "Amravati, Maharashtra",
    "preferredLocation": "Amravati, Maharashtra",
    "radiusKm": 5,
    "salaryExpectation": 25000,
    "employmentPreference": "Full-time",
    "previousSearches": ["UI Designer", "Flutter Developer"],
    "savedJobTitles": ["Frontend Developer"],
    "appliedJobTitles": <String>[],
  };

  /// Simple scoring: skills overlap + preferred-role match + premium status.
  int _recommendationScore(Map<String, dynamic> job) {
    int score = 0;
    List<String> jobSkills = [];
    if (job["skills"] is List) {
      jobSkills = (job["skills"] as List).map((s) => s.toString().trim()).where((s) => s.isNotEmpty).toList();
    }
    final userSkills = (userProfile["skills"] as List).cast<String>();
    score += jobSkills.where((s) => userSkills.any((u) => u.toLowerCase() == s.toLowerCase())).length * 2;
    if (job["title"] != null &&
        userProfile["preferredRole"] != null &&
        job["title"].toString().toLowerCase().contains(userProfile["preferredRole"].toString().toLowerCase())) {
      score += 3;
    }
    if (job["isPremium"] == true) score += 1;
    return score;
  }

  /// Helper to aggregate dynamic jobs from both controller and direct fetch,
  /// strictly filtered by candidate's currently selected city ID.
  List<Map<String, dynamic>> _getCityFilteredDynamicJobs() {
    final Map<int, Map<String, dynamic>> uniqueJobs = {};

    if (_recentJobController.recentJobs.isNotEmpty) {
      for (final j in _recentJobController.recentJobs) {
        final map = j.toMap();
        if (j.id > 0) uniqueJobs[j.id] = map;
      }
    }

    for (final j in _dynamicRecentJobs) {
      final id = j["id"] is num
          ? (j["id"] as num).toInt()
          : int.tryParse(j["id"]?.toString() ?? '0') ?? 0;
      if (id > 0) {
        uniqueJobs.putIfAbsent(id, () => j);
      }
    }

    var list = uniqueJobs.values.toList();
    if (_selectedCityId != null && _selectedCityId! > 0) {
      list = list.where((j) {
        final dynamic cId = j["city_id"] ?? j["cityId"];
        if (cId == null) return false;
        final int? parsed = cId is num ? cId.toInt() : int.tryParse(cId.toString());
        return parsed == _selectedCityId;
      }).toList();
    }
    return list;
  }

  List<Map<String, dynamic>> get _recommendedJobs {
    final list = _getCityFilteredDynamicJobs();
    list.sort(
      (a, b) => _recommendationScore(b).compareTo(_recommendationScore(a)),
    );
    return list.take(5).toList();
  }

  List<Map<String, dynamic>> get _skillMatchedJobs {
    final userSkills = (userProfile["skills"] as List).cast<String>();
    return _getCityFilteredDynamicJobs()
        .where(
          (j) => (j["skills"] is List) &&
              (j["skills"] as List).map((s) => s.toString().toLowerCase()).any(
                    (s) => userSkills.any((u) => u.toLowerCase() == s),
                  ),
        )
        .take(2)
        .toList();
  }

  List<Map<String, dynamic>> get _jobsNearYou => _dynamicNearbyJobs.take(5).toList();
  List<Map<String, dynamic>> get _urgentJobs {
    final Map<int, Map<String, dynamic>> uniqueUrgent = {};

    if (_recentJobController.recentJobs.isNotEmpty) {
      for (final j in _recentJobController.recentJobs) {
        if (j.isUrgentHiring) {
          uniqueUrgent[j.id] = j.toMap();
        }
      }
    }

    for (final j in _dynamicRecentJobs) {
      final isUrg = j["isUrgentHiring"] == true || j["isUrgent"] == true;
      if (isUrg) {
        final id = j["id"] as int? ?? 0;
        uniqueUrgent.putIfAbsent(id, () => j);
      }
    }

    for (final j in _dynamicNearbyJobs) {
      final isUrg = j["isUrgentHiring"] == true || j["isUrgent"] == true;
      if (isUrg) {
        final id = j["id"] as int? ?? 0;
        uniqueUrgent.putIfAbsent(id, () => j);
      }
    }

    return uniqueUrgent.values.take(6).toList();
  }
  List<Map<String, dynamic>> get _recentJobs {
    final list = _getCityFilteredDynamicJobs();
    list.sort((a, b) {
      final aCreated = a["createdAt"] ?? a["postedDate"];
      final bCreated = b["createdAt"] ?? b["postedDate"];
      if (aCreated != null && bCreated != null) {
        final dtA = DateTime.tryParse(aCreated.toString());
        final dtB = DateTime.tryParse(bCreated.toString());
        if (dtA != null && dtB != null) {
          return dtB.compareTo(dtA);
        }
      }
      final idA = a["id"] is num
          ? (a["id"] as num).toInt()
          : int.tryParse(a["id"]?.toString() ?? '0') ?? 0;
      final idB = b["id"] is num
          ? (b["id"] as num).toInt()
          : int.tryParse(b["id"]?.toString() ?? '0') ?? 0;
      return idB.compareTo(idA);
    });
    return list.take(5).toList();
  }
  List<Map<String, dynamic>> get _walkInJobs {
    final Map<int, Map<String, dynamic>> uniqueWalkIn = {};

    bool isWalkInJob(Map<String, dynamic> item) {
      final raw = item['raw'] is Map ? item['raw'] as Map : null;
      final val = item['is_walk_in_interview'] ??
          (raw != null ? raw['is_walk_in_interview'] : null) ??
          item['isWalkInInterview'] ??
          item['isWalkIn'];

      if (val == null) return false;
      if (val is bool) return val;
      if (val is num) return val.toInt() == 1;
      final str = val.toString().trim().toLowerCase();
      return str == '1' || str == 'true';
    }

    if (_recentJobController.recentJobs.isNotEmpty) {
      for (final j in _recentJobController.recentJobs) {
        final map = j.toMap();
        if (isWalkInJob(map)) {
          uniqueWalkIn[j.id] = map;
        }
      }
    }

    for (final j in _dynamicRecentJobs) {
      if (isWalkInJob(j)) {
        final id = j["id"] as int? ?? 0;
        uniqueWalkIn.putIfAbsent(id, () => j);
      }
    }

    for (final j in _dynamicNearbyJobs) {
      if (isWalkInJob(j)) {
        final id = j["id"] as int? ?? 0;
        uniqueWalkIn.putIfAbsent(id, () => j);
      }
    }

    return uniqueWalkIn.values.toList();
  }
  List<Map<String, dynamic>> get _partTimeJobsList {
    final Map<int, Map<String, dynamic>> uniquePartTime = {};

    if (_recentJobController.recentJobs.isNotEmpty) {
      for (final j in _recentJobController.recentJobs) {
        final isPart = j.isPartTime || (j.employmentType ?? '').toLowerCase().contains('part');
        if (isPart) {
          uniquePartTime[j.id] = j.toMap();
        }
      }
    }

    for (final j in _dynamicRecentJobs) {
      final isPart = j["isPartTime"] == true ||
          (j["employmentType"] ?? "").toString().toLowerCase().contains("part") ||
          (j["title"] ?? "").toString().toLowerCase().contains("part-time");
      if (isPart) {
        final id = j["id"] as int? ?? 0;
        uniquePartTime.putIfAbsent(id, () => j);
      }
    }

    for (final j in _dynamicNearbyJobs) {
      final isPart = j["isPartTime"] == true ||
          (j["employmentType"] ?? "").toString().toLowerCase().contains("part") ||
          (j["title"] ?? "").toString().toLowerCase().contains("part-time");
      if (isPart) {
        final id = j["id"] as int? ?? 0;
        uniquePartTime.putIfAbsent(id, () => j);
      }
    }

    return uniquePartTime.values.take(5).toList();
  }
  List<Map<String, dynamic>> get _wfhJobsList {
    final Map<int, Map<String, dynamic>> uniqueWFH = {};

    if (_recentJobController.recentJobs.isNotEmpty) {
      for (final j in _recentJobController.recentJobs) {
        final emp = (j.employmentType ?? '').toLowerCase();
        final title = j.title.toLowerCase();
        final isWfh = j.isWFH ||
            emp.contains('work from home') ||
            emp.contains('wfh') ||
            title.contains('work from home') ||
            title.contains('wfh');
        if (isWfh) {
          uniqueWFH[j.id] = j.toMap();
        }
      }
    }

    for (final j in _dynamicRecentJobs) {
      final emp = (j["employmentType"] ?? "").toString().toLowerCase();
      final title = (j["title"] ?? "").toString().toLowerCase();
      final isWfh = j["isWFH"] == true ||
          emp.contains("work from home") ||
          emp.contains("wfh") ||
          title.contains("work from home") ||
          title.contains("wfh");
      if (isWfh) {
        final id = j["id"] as int? ?? 0;
        uniqueWFH.putIfAbsent(id, () => j);
      }
    }

    for (final j in _dynamicNearbyJobs) {
      final emp = (j["employmentType"] ?? "").toString().toLowerCase();
      final title = (j["title"] ?? "").toString().toLowerCase();
      final isWfh = j["isWFH"] == true ||
          emp.contains("work from home") ||
          emp.contains("wfh") ||
          title.contains("work from home") ||
          title.contains("wfh");
      if (isWfh) {
        final id = j["id"] as int? ?? 0;
        uniqueWFH.putIfAbsent(id, () => j);
      }
    }

    return uniqueWFH.values.take(5).toList();
  }
  List<Map<String, dynamic>> get _premiumJobsList {
    final Map<int, Map<String, dynamic>> uniquePremium = {};

    if (_recentJobController.recentJobs.isNotEmpty) {
      for (final j in _recentJobController.recentJobs) {
        if (j.isPremium) {
          uniquePremium[j.id] = j.toMap();
        }
      }
    }

    for (final j in _dynamicRecentJobs) {
      final isPrem = j["isPremium"] == true;
      if (isPrem) {
        final id = j["id"] as int? ?? 0;
        uniquePremium.putIfAbsent(id, () => j);
      }
    }

    for (final j in _dynamicNearbyJobs) {
      final isPrem = j["isPremium"] == true;
      if (isPrem) {
        final id = j["id"] as int? ?? 0;
        uniquePremium.putIfAbsent(id, () => j);
      }
    }

    return uniquePremium.values.take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ── LIVE SEARCH: filter jobs by title or company as you type ──
    final allSearchPool = _recentJobController.recentJobs.isNotEmpty
        ? _recentJobController.recentJobs.map((j) => j.toMap()).toList()
        : (_dynamicRecentJobs.isNotEmpty ? _dynamicRecentJobs : jobs);
    final filteredJobs = _searchQuery.isEmpty
        ? allSearchPool
        : allSearchPool.where((job) {
            final title = (job["title"] as String).toLowerCase();
            final company = (job["company"] as String).toLowerCase();
            return title.contains(_searchQuery) ||
                company.contains(_searchQuery);
          }).toList();

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarOverlapSpacer = (132.0 + statusBarHeight) - 28.0;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 72.0,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          child: Container(
            decoration: const BoxDecoration(gradient: GenZ.headerGradient),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TapScale(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
        leadingWidth: 58,
        centerTitle: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/new_splash_logo.png",
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 14),
          ],
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── NOTIFICATION BUTTON ──
              TapScale(
                onTap: () {
                  setState(() => _hasNewNotification = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationPage()),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        if (_hasNewNotification)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (context, child) {
                                return Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: GenZ.coral.withOpacity(
                                          _pulseAnim.value * 0.9,
                                        ),
                                        blurRadius: 6 * _pulseAnim.value,
                                        spreadRadius: 1 * _pulseAnim.value,
                                      ),
                                    ],
                                    color: GenZ.coral.withOpacity(
                                      _pulseAnim.value,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // ── LOCATION BUTTON ──
              TapScale(
                onTap: () {
                  _showLocationSelectionDialog();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      width: 60,
                      child: Text(
                        _selectedLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: 8.0,
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: !_isSearchExpanded
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Hi, $_userFirstName ",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _waveAnim,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _waveAnim.value,
                                      alignment: Alignment.bottomCenter,
                                      child: child,
                                    );
                                  },
                                  child: const Text(
                                    "👋",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Find your dream job near you",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        TapScale(
                          onTap: () {
                            setState(() {
                              _isSearchExpanded = true;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: GenZ.purple.withOpacity(0.18),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: GenZ.purple.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: GenZ.purple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                              decoration: const InputDecoration(
                                hintText: "Search jobs, skills, companies...",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          TapScale(
                            onTap: () {
                              setState(() {
                                _isSearchExpanded = false;
                                _searchController.clear();
                              });
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.grey,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),

      // ── DRAWER (opens via profile avatar tap) ────────────
      drawer: Drawer(
        width: 280,
        backgroundColor: AppColors.background,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                // ── PURPLE GRADIENT (solid removed) ──
                decoration: const BoxDecoration(gradient: GenZ.drawerGradient),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ── decorative purple blobs for extra depth ──
                    Positioned(
                      top: -30,
                      right: -30,
                      child: _HeaderBlob(
                        size: 90,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: _HeaderBlob(
                        size: 70,
                        color: GenZ.lavender.withOpacity(0.18),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            Navigator.pop(context);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            );
                            _fetchUserProfileAndResume();
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.15),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 1.5,
                                  ),
                                ),
                                child: _getDrawerAvatarImage() != null
                                    ? CircleAvatar(
                                        radius: 28,
                                        backgroundImage: _getDrawerAvatarImage(),
                                      )
                                    : Center(
                                        child: Text(
                                          _userName.isNotEmpty
                                              ? _userName[0].toUpperCase()
                                              : "U",
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _userEmail.isNotEmpty ? _userEmail : _userMobile,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: AppColors.divider, height: 1, thickness: 1),

              // ── SCROLLABLE MIDDLE SECTION ─────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // _drawerTile(
                      //   Icons.home_outlined,
                      //   "Home",
                      //   AppColors.primary,
                      //   () {},
                      // ),
                      _drawerTile(
                        Icons.category_outlined,
                        "Categories",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoriesPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.thumb_up_alt_outlined,
                        "Recommended Job",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RecommendedJobPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.bookmark_border_rounded,
                        "Saved Job",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavedJobPage(),
                            ),
                          );
                        },
                      ),
                       _drawerTile(
                        Icons.bookmark_border_rounded,
                        "My Invite",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InviteCandidatedPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.account_balance_wallet_outlined,
                        "Wallect & Premium",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WalletPremiumPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.school_outlined,
                        "Learning Career",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LearningCareerPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.explore_outlined,
                        "Jobs Near You",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const HyperlocalFeaturesPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.person_outline_rounded,
                        "My Profile",
                        AppColors.primary,
                        () {},
                      ),
                      _drawerTile(
                        Icons.settings_outlined,
                        "Settings",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.help_outline_rounded,
                        "Help Center",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpCenterPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.confirmation_number_outlined,
                        "Support Tickets",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SupportTicketsPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.article_outlined,
                        "Cover Letters",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CoverLettersPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.info_outline_rounded,
                        "About App",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutAppPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.filter_alt_outlined,
                        "Missed Opportunity",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MissOpportunityPage(
                                missedJobs: _missedOpportunityItems
                                    .where((m) => m.isWithinRetentionPeriod)
                                    .map((m) => MissedJobInfo(
                                          companyName: m.companyName,
                                          jobTitle: m.title,
                                          companyFullName: m.companyFullName ?? "${m.companyName} Pvt. Ltd.",
                                          salary: m.formattedSalary,
                                          logoText: m.logoLetter,
                                          logoColor: m.logoColor,
                                          postedDate: m.formattedPostedDate,
                                          missedDate: m.formattedClosedDate,
                                          reason: m.formattedReason,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ).then((_) => _fetchMissedOpportunities());
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── FIXED BOTTOM: LOGOUT ──────────────────────
              const Divider(color: AppColors.divider, height: 1, thickness: 1),
              _drawerTile(
                Icons.logout_rounded,
                "Logout",
                const Color.fromARGB(255, 226, 30, 30),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 15, top: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Made with ",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        const Text("❤️"),
                        const Text(
                          " by ",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: _openWebsite,
                          child: const Text(
                            "WEBMEDIA",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Version 1.0 | UserId : 01",
                      style: TextStyle(color: Colors.black45, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ── OVERALL PAGE BACKGROUND: GRADIENT ──
      body: Container(
        decoration: const BoxDecoration(
          gradient: GenZ.pageBackgroundGradient,
        ),
        child: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: _refreshDashboard,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: appBarOverlapSpacer),
                // ── VISUAL SLIDER ──
                _buildImageSlider(),

                // ── QUICK ACTIONS (BUILD RESUME & NEARBY JOBS STACKED VERTICALLY IN IMAGE STYLE) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Card 1: Build Resume (Dynamic progress from backend/prefs)
                      _imageStyleCard(
                        title: "Build Resume",
                        subtitle1: "AI-Powered Builder",
                        subtitle2: _resumeCompletionPercent == 100
                            ? "Score 100% • Profile Completed"
                            : "Score $_resumeCompletionPercent% • Completed ($_resumeCompletedPoints/$_resumeTotalPoints)",
                        progressValue: (_resumeCompletionPercent / 100.0).clamp(0.0, 1.0),
                        progressText: "$_resumeCompletionPercent%",
                        icon: Icons.description_rounded,
                        iconColor: const Color(0xFFFF4096),
                        iconBgColor: const Color(0xFFFF4096),
                        buttonText: _resumeCompletionPercent > 0 ? "Continue" : "Start",
                        buttonGradient: const LinearGradient(
                          colors: [Color(0xFFFF4096), Color(0xFFC77DFF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        cardBackgroundGradient: const LinearGradient(
                          colors: [Color(0xFF3A122B), Color(0xFF1C0815)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ResumeUploadedPage(),
                            ),
                          );
                          _fetchUserProfileAndResume();
                        },
                      ),
                      const SizedBox(height: 10),

                      // Side by Side Row: Nearby Jobs & Missed Opportunity
                      Row(
                        children: [
                          _sideBySideCard(
                            title: "Nearby Jobs",
                            subtitle: "In $_selectedLocation",
                            progressValue: _nearbyJobsProgress,
                            progressText: _nearbyJobsProgressText,
                            icon: Icons.location_on_rounded,
                            iconColor: const Color(0xFFFF9E00),
                            iconBgColor: const Color(0xFFFF9E00),
                            buttonText: "Explore",
                            buttonGradient: const LinearGradient(
                              colors: [Color(0xFFFF9E00), Color(0xFF00D2FF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            cardBackgroundGradient: const LinearGradient(
                              colors: [Color(0xFF0B2B26), Color(0xFF051513)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const JobNearMapPage(),
                                ),
                              ).then((_) {
                                if (mounted) _loadSavedLocation();
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          _sideBySideCard(
                            title: "Missed Jobs",
                            subtitle: _missedOpportunitiesCount == 1
                                ? "1 Deadline"
                                : "$_missedOpportunitiesCount Deadlines",
                            progressValue: _missedOpportunitiesCount > 0
                                ? (_missedOpportunitiesCount / 10.0).clamp(0.1, 1.0)
                                : 0.0,
                            progressText: "$_missedOpportunitiesCount",
                            icon: Icons.history_toggle_off_rounded,
                            iconColor: const Color(0xFFFF5252),
                            iconBgColor: const Color(0xFFFF5252),
                            buttonText: "Catch Up",
                            buttonGradient: const LinearGradient(
                              colors: [Color(0xFFFF5252), Color(0xFFFF7A00)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            cardBackgroundGradient: const LinearGradient(
                              colors: [Color(0xFF2E1015), Color(0xFF140508)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MissOpportunityPage(
                                    missedJobs: _missedOpportunityItems
                                        .where((m) => m.isWithinRetentionPeriod)
                                        .map((m) => MissedJobInfo(
                                              companyName: m.companyName,
                                              jobTitle: m.title,
                                              companyFullName: m.companyFullName ?? "${m.companyName} Pvt. Ltd.",
                                              salary: m.formattedSalary,
                                              logoText: m.logoLetter,
                                              logoColor: m.logoColor,
                                              postedDate: m.formattedPostedDate,
                                              missedDate: m.formattedClosedDate,
                                              reason: m.formattedReason,
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ).then((_) => _fetchMissedOpportunities());
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Top Categories",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoriesPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "See All",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── EXPLORE CATEGORIES HORIZONTAL CARDS (Ranked) ──
                SizedBox(
                  height: 135,
                  child: _isLoadingCategories
                      ? const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        )
                      : _categoriesError != null
                          ? Center(
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.red.withOpacity(0.15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _categoriesError!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: _fetchCategories,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                                            SizedBox(width: 4),
                                            Text(
                                              "Retry",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _dynamicCategories.isEmpty
                              ? Center(
                                  child: Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey.withOpacity(0.15)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "No Categories Found",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  itemCount: _dynamicCategories.length,
                                  itemBuilder: (context, index) {
                                    final item = _dynamicCategories[index];
                                    final color = item["color"] as Color;
                                    final label = item["label"] as String;
                                    final openings = item["openings"] as String;
                                    final isFirst = true; // Make all cards use the first/large card size
                                    final iconImg = item["iconImg"] as String?;
                                    
                                    return TapScale(
                                      onTap: () {
                                        if (label == "More") {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const CategoriesPage(),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const RecommendedJobPage(),
                                            ),
                                          );
                                        }
                                      },
                                      child: SizedBox(
                                        width: isFirst ? 230 : 170,
                                        height: 135,
                                        child: Stack(
                                          children: [
                                            // Huge Rank Number on the left background matching the category color
                                            Positioned(
                                              left: 5,
                                              bottom: -5,
                                              child: Text(
                                                "${index + 1}",
                                                style: TextStyle(
                                                  fontSize: isFirst ? 90 : 78,
                                                  fontWeight: FontWeight.w900,
                                                  color: color.withOpacity(0.16),
                                                  height: 1.0,
                                                ),
                                              ),
                                            ),
                                            // The Card container overlapping the rank number
                                            Positioned(
                                              left: isFirst ? 55 : 45,
                                              top: 4,
                                              bottom: 4,
                                              right: 10,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: color.withOpacity(0.35),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 5),
                                                    ),
                                                  ],
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      color,
                                                      color.withOpacity(0.75),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: Stack(
                                                  children: [
                                                    // ── CATEGORY BACKGROUND IMAGE ──
                                                    if (item["bgImage"] != null)
                                                      Positioned.fill(
                                                        child: Opacity(
                                                          opacity: 0.22,
                                                          child: Image.network(
                                                            item["bgImage"] as String,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                                          ),
                                                        ),
                                                      ),
                                                    // Large background icon with low opacity
                                                    Positioned(
                                                      right: -10,
                                                      bottom: -10,
                                                      child: (iconImg != null && iconImg.isNotEmpty)
                                                          ? Opacity(
                                                              opacity: 0.15,
                                                              child: Image.network(
                                                                iconImg,
                                                                width: isFirst ? 85 : 68,
                                                                height: isFirst ? 85 : 68,
                                                                fit: BoxFit.contain,
                                                                errorBuilder: (_, _, _) => Icon(
                                                                  item["icon"] as IconData,
                                                                  size: isFirst ? 85 : 68,
                                                                  color: Colors.white.withOpacity(0.12),
                                                                ),
                                                              ),
                                                            )
                                                          : Icon(
                                                              item["icon"] as IconData,
                                                              size: isFirst ? 85 : 68,
                                                              color: Colors.white.withOpacity(0.12),
                                                            ),
                                                    ),
                                                    // Content Column placing text immediately after icon
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // Top Row (Icon Badge & Arrow)
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                width: isFirst ? 38 : 32,
                                                                height: isFirst ? 38 : 32,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  shape: BoxShape.circle,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.black.withOpacity(0.1),
                                                                      blurRadius: 4,
                                                                      offset: const Offset(0, 2),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: (iconImg != null && iconImg.isNotEmpty)
                                                                    ? ClipOval(
                                                                        child: Image.network(
                                                                          iconImg,
                                                                          fit: BoxFit.cover,
                                                                          errorBuilder: (_, _, _) => Icon(
                                                                            item["icon"] as IconData,
                                                                            color: color,
                                                                            size: isFirst ? 18 : 15,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Icon(
                                                                        item["icon"] as IconData,
                                                                        color: color,
                                                                        size: isFirst ? 18 : 15,
                                                                      ),
                                                              ),
                                                              Container(
                                                                padding: const EdgeInsets.all(5),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white.withOpacity(0.2),
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: Icon(
                                                                  Icons.arrow_forward_ios_rounded,
                                                                  color: Colors.white,
                                                                  size: isFirst ? 11 : 9.5,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: isFirst ? 12 : 8),
                                                          Text(
                                                            label,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontSize: isFirst ? 15.5 : 13.5,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                              letterSpacing: 0.3,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 3),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: isFirst ? 14 : 10,
                                                                height: 2.5,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white.withOpacity(0.6),
                                                                  borderRadius: BorderRadius.circular(1),
                                                                ),
                                                              ),
                                                              const SizedBox(width: 5),
                                                              Expanded(
                                                                child: Text(
                                                                  openings,
                                                                  style: TextStyle(
                                                                    fontSize: isFirst ? 11.5 : 9.5,
                                                                    fontWeight: FontWeight.w500,
                                                                    color: Colors.white.withOpacity(0.9),
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                ),

                const SizedBox(height: 4),

                // ── SEARCH RESULTS (when typing) OR HOME SECTIONS (default) ──
                if (_searchQuery.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _sectionHeader("Search Results"),
                  ),
                  if (filteredJobs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 40,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No jobs found for "${_searchController.text}"',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredJobs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final job = filteredJobs[index];
                          return _jobCard(
                            title: job["title"] as String,
                            company: job["company"] as String,
                            distance: job["distance"] as String,
                            salary: job["salary"] as String,
                            logoText: job["logoText"] as String,
                            logoColor: job["logoColor"] as Color,
                            logoUrl: job["logoUrl"] as String,
                          );
                        },
                      ),
                    ),
                ] else ...[
                  _horizontalSection(
                    title: "Urgent Hiring",
                    sectionJobs: _urgentJobs,
                    cardBuilder: _urgentHiringCard,
                    height: 112,
                    emptyMessage: "No Urgent Hiring Jobs Available",
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommendedJobPage(),
                      ),
                    ),
                  ),
                  _verticalSection(
                    title: "Jobs Near You",
                    sectionJobs: _jobsNearYou,
                    cardBuilder: (job, {badgeColor, badgeText}) => _jobsNearYouCard(
                      job,
                      badgeText: badgeText,
                      badgeColor: badgeColor,
                      width: double.infinity,
                    ),
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JobNearMapPage()),
                    ).then((_) {
                      if (mounted) _loadSavedLocation();
                    }),
                  ),
                  _horizontalSection(
                    title: "Premium Jobs",
                    sectionJobs: _premiumJobsList,
                    cardBuilder: _premiumJobCard,
                    height: 108,
                    emptyMessage: "No Premium Jobs Available",
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WalletPremiumPage(),
                      ),
                    ),
                  ),
                  _horizontalSection(
                    title: "Recommended Jobs",
                    sectionJobs: _recommendedJobs,
                    cardBuilder: _recommendedForYouCard,
                    height: 120,
                    emptyMessage: "No recommended jobs found in $_selectedLocation",
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommendedJobPage(),
                      ),
                    ),
                  ),
                  _verticalSection(
                    title: "Recently Posted",
                    sectionJobs: _recentJobs,
                    emptyMessage: "No recently posted jobs found in $_selectedLocation",
                    cardBuilder: (job, {badgeColor, badgeText}) => _recentlyPostedCard(
                      job,
                      badgeText: badgeText ??
                          (job["isPartTime"] == true
                              ? "PART-TIME"
                              : (job["employmentType"] != null &&
                                      job["employmentType"].toString().trim().isNotEmpty
                                  ? job["employmentType"].toString().trim().toUpperCase()
                                  : "JUST IN")),
                      badgeColor: badgeColor ??
                          (job["isPartTime"] == true
                              ? const Color(0xFFD97706)
                              : null),
                      width: double.infinity,
                    ),
                    onViewAll: () => _recentJobController.navigateToAllRecentJobs(context),
                  ),
                  _horizontalSection(
                    title: "Walk-in Interviews",
                    sectionJobs: _walkInJobs,
                    cardBuilder: _walkInCard,
                    height: 112,
                    emptyMessage: "No Walk-in Interview Jobs Found",
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommendedJobPage(),
                      ),
                    ),
                  ),
                  _horizontalSection(
                    title: "Part-Time Jobs",
                    sectionJobs: _partTimeJobsList,
                    cardBuilder: _partTimeCard,
                    height: 112,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PartTimeJobPage(),
                      ),
                    ),
                  ),
                  _verticalSection(
                    title: "Work From Home",
                    sectionJobs: _wfhJobsList,
                    emptyMessage: "No Work From Home Jobs Found",
                    cardBuilder: (job, {badgeColor, badgeText}) => _wfhCard(
                      job,
                      badgeText: badgeText,
                      badgeColor: badgeColor,
                      width: double.infinity,
                    ),
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkFromHomePage(),
                      ),
                    ),
                  ),
                  _horizontalSection(
                    title: "Jobs Matching Your Skills",
                    sectionJobs: _skillMatchedJobs,
                    cardBuilder: _compactJobCard2,
                    badgeText: "Skill Match",
                    badgeColor: GenZ.lavender,
                    height: 108,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommendedJobPage(),
                      ),
                    ),
                  ),

                  // ── TOP LOCAL EMPLOYERS ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _sectionHeader(
                            "Top Local Employers",
                            onViewAll: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CategoriesPage(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 120,
                          child: _isLoadingCompanies
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: GenZ.purple,
                                    ),
                                  ),
                                )
                              : _dynamicCompanies.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Text(
                                          _companiesError != null
                                              ? "Failed to load employers"
                                              : "No employers registered yet",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      clipBehavior: Clip.none,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      itemCount: _dynamicCompanies.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(width: 4),
                                      itemBuilder: (context, index) =>
                                          _employerCard(
                                              _dynamicCompanies[index], index),
                                    ),
                        ),
                      ],
                    ),
                  ),

                  // ── CAREER TIPS ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _sectionHeader(
                            "Career Tips",
                            onViewAll: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LearningCareerPage(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 110,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            clipBehavior: Clip.none,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: careerTips.take(2).length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 4),
                            itemBuilder: (context, index) =>
                                _careerTipCard(careerTips[index]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 70),
                ],
              ],
            ),
          ),
        ),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
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
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                          _fetchUserProfileAndResume();
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

  // ── VISUAL SLIDER HELPER ───────────────────────────────────────────
  Widget _buildImageSlider() {
    if (_activeSliderItems.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          SizedBox(
            height: 188,
            child: PageView.builder(
              controller: _sliderPageController,
              onPageChanged: (int index) {
                setState(() {
                  _currentSliderPage = index;
                });
              },
              itemCount: _activeSliderItems.length,
              itemBuilder: (context, index) {
                final item = _activeSliderItems[index];
                return AnimatedBuilder(
                  animation: _sliderPageController,
                  builder: (context, child) {
                    return TapScale(
                      onTap: () {
                        final route = (item["route"] ?? item["redirectType"] ?? item["redirectValue"] ?? "").toString().toLowerCase();
                        if (route == "gov" || route.contains("gov")) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GovernmentJobPage(),
                            ),
                          );
                        } else if (route == "mock" || route.contains("mock")) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MockInterviewPage(),
                            ),
                          );
                        } else if (route == "parttime" || route.contains("part")) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PartTimeJobPage(),
                            ),
                          );
                        } else if (route == "wfh" || route.contains("home")) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WorkFromHomePage(),
                            ),
                          );
                        } else if (route.contains("cat")) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CategoriesPage(),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: item["gradient"] as LinearGradient,
                          borderRadius: BorderRadius.zero,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // ── BANNER POSTER BACKGROUND IMAGE OR VIDEO ──
                            Positioned.fill(
                              child: item["isVideo"] == true
                                  ? SliderVideoPlayer(
                                      videoPath: item["videoUrl"] ?? item["videoPath"] ?? "",
                                      isNetwork: item["isNetworkVideo"] == true,
                                      isAsset: item["isAssetVideo"] == true,
                                    )
                                  : (item["isLocalImage"] == true && !kIsWeb
                                      ? Image.file(
                                          File(item["image"] as String),
                                          fit: BoxFit.cover,
                                        )
                                      : ((item["image"] != null && (item["image"] as String).trim().isNotEmpty)
                                          ? Image.network(
                                              item["image"] as String,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Container(
                                                  color: Colors.black12,
                                                  child: const Center(
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    gradient: item["gradient"] as LinearGradient,
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                gradient: item["gradient"] as LinearGradient,
                                              ),
                                            ))),
                            ),
                            // Dark gradient overlay for typography readability
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.85),
                                      Colors.black.withOpacity(0.2),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),
                            ),
                            // Background design circles
                            Positioned(
                              right: -20,
                              top: -20,
                              child: CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            Positioned(
                              right: 30,
                              bottom: -30,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            // A light blue circle matching the uploaded image theme on the right
                            Positioned(
                              right: 15,
                              top: 48,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBFEFFF).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            // The main illustrative icon on the right side of the poster banner
                            Positioned(
                              right: 32,
                              top: 65,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.22),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  (item["icon"] is IconData) ? item["icon"] as IconData : Icons.stars_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                            // Content Column placing text immediately after icon
                            Padding(
                              padding: const EdgeInsets.only(left: 24, right: 24, top: 44, bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if ((item["badge"]?.toString() ?? "").trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          item["badge"].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Text(
                                    (item["title"]?.toString() ?? "").trim().isNotEmpty
                                        ? item["title"].toString()
                                        : "Featured Banner",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if ((item["subtitle"]?.toString() ?? "").trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        item["subtitle"].toString(),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          (item["buttonText"]?.toString() ?? "").trim().isNotEmpty
                                              ? item["buttonText"].toString()
                                              : "Explore Now",
                                          style: TextStyle(
                                            color: (item["gradient"] as LinearGradient).colors[0],
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: (item["gradient"] as LinearGradient).colors[0],
                                          size: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_activeSliderItems.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _activeSliderItems.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 6,
                    width: _currentSliderPage == index ? 18 : 6,
                    decoration: BoxDecoration(
                      color: _currentSliderPage == index
                          ? AppColors.primary
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── SECTION HEADER HELPER (title + optional "View all") ──────────────
  Widget _sectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [GenZ.purple, GenZ.pink],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          if (onViewAll != null)
            TapScale(
              onTap: onViewAll,
              child: const Text(
                "View all",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: GenZ.purpleDark,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── REUSABLE HORIZONTAL JOB SECTION (used by all Home Sections) ──────
  // Each section now takes its own `cardBuilder` so every section can have
  // a visually distinct card design, and the vertical gap between sections
  // has been trimmed down to tighten up the layout to match the reference design.
  Widget _horizontalSection({
    required String title,
    required List<Map<String, dynamic>> sectionJobs,
    required Widget Function(
      Map<String, dynamic> job, {
      String? badgeText,
      Color? badgeColor,
    })
    cardBuilder,
    VoidCallback? onViewAll,
    String? badgeText,
    Color? badgeColor,
    double height = 150,
    String? emptyMessage,
  }) {
    if (sectionJobs.isEmpty) {
      if (emptyMessage != null) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _sectionHeader(title, onViewAll: onViewAll),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: (_isLoadingRecentJobs || _isLoadingNearbyJobs || _recentJobController.isLoading)
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                title.toLowerCase().contains("urgent")
                                    ? Icons.bolt_rounded
                                    : (title.toLowerCase().contains("premium")
                                        ? Icons.workspace_premium_outlined
                                        : (title.toLowerCase().contains("walk-in")
                                            ? Icons.confirmation_number_outlined
                                            : Icons.work_outline_rounded)),
                                size: 36,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                emptyMessage,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _sectionHeader(title, onViewAll: onViewAll),
          ),
          SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: sectionJobs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final job = sectionJobs[index];
                return cardBuilder(
                  job,
                  badgeText: badgeText,
                  badgeColor: badgeColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── REUSABLE VERTICAL JOB SECTION ───────────────────────────────────
  Widget _verticalSection({
    required String title,
    required List<Map<String, dynamic>> sectionJobs,
    required Widget Function(
      Map<String, dynamic> job, {
      String? badgeText,
      Color? badgeColor,
    })
    cardBuilder,
    VoidCallback? onViewAll,
    String? badgeText,
    Color? badgeColor,
    String? emptyMessage,
  }) {
    if (sectionJobs.isEmpty) {
      if (emptyMessage != null) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _sectionHeader(title, onViewAll: onViewAll),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: _isLoadingRecentJobs
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home_work_outlined, size: 36, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                emptyMessage,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _sectionHeader(title, onViewAll: onViewAll),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sectionJobs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final job = sectionJobs[index];
                return cardBuilder(
                  job,
                  badgeText: badgeText,
                  badgeColor: badgeColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── CUSTOM GRADIENT GLOW CARD HELPER (IMAGE STYLE) ─────────────────────
  Widget _imageStyleCard({
    required String title,
    required String subtitle1,
    required String subtitle2,
    required double progressValue,
    required String progressText,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String buttonText,
    required LinearGradient buttonGradient,
    required LinearGradient cardBackgroundGradient,
    required VoidCallback onTap,
  }) {
    return TapScale(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: cardBackgroundGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rounded square icon container with matching borders
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBgColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: iconBgColor.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle1,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle2,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Continue / Explore Button
                Container(
                  decoration: BoxDecoration(
                    gradient: buttonGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: buttonGradient.colors.first.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Progress",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  progressText,
                  style: const TextStyle(
                    color: Color(0xFFFF4096),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Progress Bar
            Container(
              height: 4.5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(2.25),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressValue,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: buttonGradient.colors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SIDE-BY-SIDE COMPACT CARD HELPER ─────────────────────────────────
  Widget _sideBySideCard({
    required String title,
    required String subtitle,
    required double progressValue,
    required String progressText,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String buttonText,
    required LinearGradient buttonGradient,
    required LinearGradient cardBackgroundGradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: TapScale(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: cardBackgroundGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBgColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: iconBgColor.withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 18,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: buttonGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: buttonGradient.colors.first.withOpacity(0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Progress",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    progressText,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressValue,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: buttonGradient.colors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── QUICK ACTION UNIFORM CARD HELPER ─────────────────────────────────
  Widget _quickActionCard({
    required String title,
    String? subtitleText,
    Widget? subtitleWidget,
    required String badgeText,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
    double width = double.infinity,
    double height = 104,
  }) {
    return TapScale(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            if (subtitleWidget != null)
              subtitleWidget
            else if (subtitleText != null)
              Text(
                subtitleText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ══════════════════════════════════════════════════════════════════
  // 1) JOBS NEAR YOU — Location pin radar accent, soft blue theme
  // ══════════════════════════════════════════════════════════════════
  Widget _jobsNearYouCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
    double width = 195,
  }) {
    final Color color = job["logoColor"] as Color;
    return Tap3D(
      onTap: () {
        final jobIdVal = job["id"] is int
            ? job["id"] as int
            : int.tryParse(job["id"]?.toString() ?? '1') ?? 1;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDescriptionPage(
              jobPostId: jobIdVal,
              companyName: (job["company"] ?? "Company").toString(),
              jobTitle: (job["title"] ?? "Job Title").toString(),
              companyFullName: (job["companyFullName"] ?? job["company"] ?? "Company").toString(),
              rating: (job["rating"] is num) ? (job["rating"] as num).toDouble() : 4.2,
              reviewCount: (job["reviewCount"] ?? "3.5k reviews").toString(),
              distance: (job["distance"] ?? "Nearby").toString(),
              salary: (job["salary"] ?? "Competitive").toString(),
              experience: (job["experience"] ?? "1-2 years").toString(),
              logoText: (job["logoText"] ?? "J").toString(),
              logoColor: (job["logoColor"] is Color) ? job["logoColor"] as Color : GenZ.purple,
              skills: (job["skills"] is List) ? List<String>.from(job["skills"]) : const ["Flutter"],
              description: (job["description"] ?? "Job description").toString(),
              totalVacancies: (job["totalVacancies"] is int) ? job["totalVacancies"] as int : 1,
              remainingVacancies: (job["remainingVacancies"] is int) ? job["remainingVacancies"] as int : 1,
              postedDate: (job["postedDate"] ?? "Recently").toString(),
            ),
          ),
        );
      },
      builder: (pressed) {
        return Container(
          width: width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              topLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(
              color: color.withOpacity(pressed ? 0.35 : 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  job["logoUrl"] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      job["logoText"] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      job["title"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job["company"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job["salary"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.near_me_rounded, size: 8, color: color),
                    const SizedBox(width: 2),
                    Text(
                      job["distance"] as String,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: color,
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
  }

  // ══════════════════════════════════════════════════════════════════
  // 2) URGENT HIRING — Notched Alert Card with Solid Coral Left Bar
  // ══════════════════════════════════════════════════════════════════
  Widget _urgentHiringCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
  }) {
    return Tap3D(
      onTap: () {
        final jobIdVal = job["id"] is int
            ? job["id"] as int
            : int.tryParse(job["id"]?.toString() ?? '1') ?? 1;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDescriptionPage(
              jobPostId: jobIdVal,
              companyName: (job["company"] ?? "Company").toString(),
              jobTitle: (job["title"] ?? "Job Title").toString(),
              companyFullName: (job["companyFullName"] ?? job["company"] ?? "Company").toString(),
              rating: (job["rating"] is num) ? (job["rating"] as num).toDouble() : 4.2,
              reviewCount: (job["reviewCount"] ?? "3.5k reviews").toString(),
              distance: (job["distance"] ?? "Nearby").toString(),
              salary: (job["salary"] ?? "Competitive").toString(),
              experience: (job["experience"] ?? "1-2 years").toString(),
              logoText: (job["logoText"] ?? "J").toString(),
              logoColor: (job["logoColor"] is Color) ? job["logoColor"] as Color : GenZ.coral,
              skills: (job["skills"] is List) ? List<String>.from(job["skills"]) : const ["Flutter"],
              description: (job["description"] ?? "Job description").toString(),
              totalVacancies: (job["totalVacancies"] is int) ? job["totalVacancies"] as int : 1,
              remainingVacancies: (job["remainingVacancies"] is int) ? job["remainingVacancies"] as int : 1,
              postedDate: (job["postedDate"] ?? "Recently").toString(),
            ),
          ),
        );
      },
      builder: (pressed) {
        return Container(
          width: 155,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7F6),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(
              color: GenZ.coral.withOpacity(pressed ? 0.40 : 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: GenZ.coral.withOpacity(0.06),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22.8),
              topRight: Radius.circular(22.8),
              bottomLeft: Radius.circular(2.8),
              bottomRight: Radius.circular(2.8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: GenZ.coral),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text("🔥", style: TextStyle(fontSize: 11)),
                            SizedBox(width: 2),
                            Text(
                              "URGENT",
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: GenZ.coral,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job["title"] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          job["company"] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          job["salary"] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: GenZ.coral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 3) RECOMMENDED FOR YOU — Super-Rounded Oval Squircle Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _recommendedForYouCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
  }) {
    final String company = (job["company"] ?? "Company").toString();
    final String title = (job["title"] ?? "Job Opening").toString();
    final String salary = (job["salary"] ?? "Competitive").toString();

    return Tap3D(
      onTap: () {
        final rawMap = (job["raw"] is Map<String, dynamic>)
            ? job["raw"] as Map<String, dynamic>
            : job;
        final recentJob = RecentJobModel.fromJson(rawMap);
        _recentJobController.navigateToJobDetails(context, recentJob);
      },
      builder: (pressed) {
        return Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFAF8FF), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: GenZ.purple.withValues(alpha: pressed ? 0.35 : 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: GenZ.purple.withValues(alpha: 0.06),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: GenZ.purple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 9,
                      color: Colors.white,
                    ),
                    SizedBox(width: 2),
                    Text(
                      "AI PICK",
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                company,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                salary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: GenZ.purple,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 4) RECENTLY POSTED — Sharp Minimal Rectangular Ticket Shape (NO GREEN NEW BADGE)
  // ══════════════════════════════════════════════════════════════════
  Widget _recentlyPostedCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
    double width = 195,
  }) {
    final String company = (job["company"] ?? "Company").toString();
    final String initial = company.trim().isNotEmpty
        ? company.trim().substring(0, 1).toUpperCase()
        : "C";
    final String title = (job["title"] ?? "Job Opening").toString();
    final String salary = (job["salary"] ?? "Competitive").toString();
    final Color cardLogoColor = (job["logoColor"] is Color)
        ? job["logoColor"] as Color
        : const Color(0xFF1D4ED8);
    final String badge = badgeText ?? "JUST IN";
    final Color badgeBgColor = badgeColor ?? const Color(0xFF3B82F6);

    return Tap3D(
      onTap: () {
        final rawMap = (job["raw"] is Map<String, dynamic>)
            ? job["raw"] as Map<String, dynamic>
            : job;
        final recentJob = RecentJobModel.fromJson(rawMap);
        _recentJobController.navigateToJobDetails(context, recentJob);
      },
      builder: (pressed) {
        return Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(
              color: const Color(0xFF64748B).withValues(alpha: pressed ? 0.30 : 0.14),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cardLogoColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: cardLogoColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    salary,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: cardLogoColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 5) WALK-IN INTERVIEWS — Dashed Border Event Pass Coupon Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _walkInCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
  }) {
    const indigo = Color(0xFF4F46E5);
    return Tap3D(
      onTap: () {
        final jobIdVal = job["id"] is int
            ? job["id"] as int
            : int.tryParse(job["id"]?.toString() ?? '1') ?? 1;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDescriptionPage(
              jobPostId: jobIdVal,
              companyName: (job["company"] ?? "Company").toString(),
              jobTitle: (job["title"] ?? "Job Title").toString(),
              companyFullName: (job["companyFullName"] ?? job["company"] ?? "Company").toString(),
              rating: (job["rating"] is num) ? (job["rating"] as num).toDouble() : 4.2,
              reviewCount: (job["reviewCount"] ?? "3.5k reviews").toString(),
              distance: (job["distance"] ?? "Nearby").toString(),
              salary: (job["salary"] ?? "Competitive Salary").toString(),
              experience: (job["experience"] ?? "1-2 years").toString(),
              skills: (job["skills"] is List) ? List<String>.from(job["skills"]) : const ["Communication"],
              description: (job["description"] ?? "Job description").toString(),
              logoText: (job["logoText"] ?? "J").toString(),
              logoColor: (job["logoColor"] is Color) ? job["logoColor"] as Color : indigo,
              totalVacancies: (job["totalVacancies"] is int) ? job["totalVacancies"] as int : 1,
              remainingVacancies: (job["remainingVacancies"] is int) ? job["remainingVacancies"] as int : 1,
              postedDate: (job["postedDate"] ?? "Recently").toString(),
            ),
          ),
        );
      },
      builder: (pressed) {
        return Container(
          width: 185,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F3FF),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(
              color: indigo.withOpacity(pressed ? 0.40 : 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: indigo.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: indigo,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.confirmation_number_rounded,
                          size: 9.5,
                          color: Colors.white,
                        ),
                        SizedBox(width: 2),
                        Text(
                          "WALK-IN",
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                (job["title"] ?? "Job Opening").toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                (job["company"] ?? "Company").toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                (job["salary"] ?? "Competitive Salary").toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: indigo,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 6) PART-TIME JOBS — Bubble Pill Capsule Oval Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _partTimeCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
  }) {
    const amber = Color(0xFFD97706);
    return Tap3D(
      onTap: () {
        final jobIdVal = job["id"] is int
            ? job["id"] as int
            : int.tryParse(job["id"]?.toString() ?? '1') ?? 1;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDescriptionPage(
              jobPostId: jobIdVal,
              companyName: (job["company"] ?? "Company").toString(),
              jobTitle: (job["title"] ?? "Job Title").toString(),
              companyFullName: (job["companyFullName"] ?? job["company"] ?? "Company").toString(),
              rating: (job["rating"] is num) ? (job["rating"] as num).toDouble() : 4.2,
              reviewCount: (job["reviewCount"] ?? "3.5k reviews").toString(),
              distance: (job["distance"] ?? "Nearby").toString(),
              salary: (job["salary"] ?? "Competitive Salary").toString(),
              experience: (job["experience"] ?? "1-2 years").toString(),
              skills: (job["skills"] is List) ? List<String>.from(job["skills"]) : const ["Communication"],
              description: (job["description"] ?? "Job description").toString(),
              logoText: (job["logoText"] ?? "J").toString(),
              logoColor: (job["logoColor"] is Color) ? job["logoColor"] as Color : amber,
              totalVacancies: (job["totalVacancies"] is int) ? job["totalVacancies"] as int : 1,
              remainingVacancies: (job["remainingVacancies"] is int) ? job["remainingVacancies"] as int : 1,
              postedDate: (job["postedDate"] ?? "Recently").toString(),
            ),
          ),
        );
      },
      builder: (pressed) {
        return Container(
          width: 195,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: amber.withOpacity(pressed ? 0.35 : 0.16),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: amber.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: amber.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: amber,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      (job["title"] ?? "Job Opening").toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      (job["company"] ?? "Company").toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (job["salary"] ?? "Competitive Salary").toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
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
  }

  // ══════════════════════════════════════════════════════════════════
  // 7) WORK FROM HOME — Diagonal Cut Corner Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _wfhCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
    double width = 195,
  }) {
    final title = (job["title"] ?? "Job Opening").toString();
    final company = (job["company"] ?? (job["companyName"] ?? "Company")).toString();
    final salary = (job["salary"] ?? "Competitive Salary").toString();

    return Tap3D(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDescriptionPage(
              jobPostId: (job["id"] is int)
                  ? job["id"] as int
                  : int.tryParse(job["id"]?.toString() ?? '1') ?? 1,
              jobTitle: title,
              companyName: company,
              companyFullName: (job["companyFullName"] ?? company).toString(),
              rating: (job["rating"] is num) ? (job["rating"] as num).toDouble() : 4.2,
              reviewCount: (job["reviewCount"] ?? "3.5k reviews").toString(),
              distance: (job["distance"] ?? "Remote").toString(),
              salary: salary,
              experience: (job["experience"] ?? "1-2 years").toString(),
              skills: (job["skills"] is List)
                  ? List<String>.from(job["skills"])
                  : const ["Communication"],
              description: (job["description"] ?? "Work from home job opportunity.").toString(),
              logoText: (job["logoText"] ?? (company.isNotEmpty ? company.substring(0, 1).toUpperCase() : "J")).toString(),
              logoColor: (job["logoColor"] is Color) ? job["logoColor"] as Color : GenZ.mint,
              totalVacancies: (job["totalVacancies"] is int) ? job["totalVacancies"] as int : 1,
              remainingVacancies: (job["remainingVacancies"] is int) ? job["remainingVacancies"] as int : 1,
              postedDate: (job["postedDate"] ?? "Recently").toString(),
            ),
          ),
        );
      },
      builder: (pressed) {
        return Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              topLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(
              color: GenZ.mint.withOpacity(pressed ? 0.35 : 0.16),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: GenZ.mint.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: GenZ.mint.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_rounded,
                  size: 22,
                  color: GenZ.mint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor ?? GenZ.mint,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText ??
                          (job["isWFH"] == true
                              ? "WORK FROM HOME"
                              : (job["employmentType"] != null &&
                                      job["employmentType"].toString().trim().isNotEmpty
                                  ? job["employmentType"].toString().trim().toUpperCase()
                                  : "WORK FROM HOME")),
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    salary,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: GenZ.mint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 8) JOBS MATCHING YOUR SKILLS — Inverted Top-Left Corner Badge Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _compactJobCard2(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
  }) {
    final List<String> skills = (job["skills"] as List?)?.cast<String>() ?? [];
    final String firstSkill = skills.isNotEmpty ? skills.first : "Skill Match";

    final String titleLower = (job["title"] as String? ?? "").toLowerCase();
    String bgImgUrl =
        "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400&auto=format&fit=crop";
    if (titleLower.contains("developer") ||
        titleLower.contains("flutter") ||
        titleLower.contains("code") ||
        titleLower.contains("tech")) {
      bgImgUrl =
          "https://images.unsplash.com/photo-1634017839464-5c339ebe3cb4?q=80&w=400&auto=format&fit=crop";
    } else if (titleLower.contains("design") ||
        titleLower.contains("ui") ||
        titleLower.contains("ux")) {
      bgImgUrl =
          "https://images.unsplash.com/photo-1618005198143-e5283b519a7f?q=80&w=400&auto=format&fit=crop";
    } else if (titleLower.contains("sales") ||
        titleLower.contains("marketing") ||
        titleLower.contains("manager")) {
      bgImgUrl =
          "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=400&auto=format&fit=crop";
    } else if (titleLower.contains("delivery") ||
        titleLower.contains("driver")) {
      bgImgUrl =
          "https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=400&auto=format&fit=crop";
    }

    return Tap3D(
      onTap: () {},
      builder: (pressed) {
        return Container(
          width: 195,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            image: DecorationImage(
              image: NetworkImage(bgImgUrl),
              fit: BoxFit.cover,
              opacity: 0.28,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E1B4B), // Deep Indigo
                Color(0xFF3B0764), // Deep Purple
              ],
            ),
            border: Border.all(
              color: GenZ.lavender.withOpacity(pressed ? 0.50 : 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: GenZ.lavender.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      job["title"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      job["company"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFC7D2FE), // light indigo
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        firstSkill,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
  }

  // ══════════════════════════════════════════════════════════════════
  // 9) TOP LOCAL EMPLOYERS — Dynamic Company Cards
  // ══════════════════════════════════════════════════════════════════
  Widget _employerCard(CompanyModel company, int index) {
    final List<Color> accentColors = [
      GenZ.purple,
      GenZ.coral,
      GenZ.pink,
      GenZ.mint,
      GenZ.lavender,
    ];
    final color = accentColors[index % accentColors.length];

    String? logoUrl;
    if (company.companyLogo != null && company.companyLogo!.trim().isNotEmpty) {
      final raw = company.companyLogo!.trim();
      if (raw.startsWith('http://') || raw.startsWith('https://')) {
        logoUrl = raw;
      } else {
        final base = ApiService.baseUrl.replaceAll('/api', '');
        final clean = raw.startsWith('/') ? raw.substring(1) : raw;
        logoUrl = '$base/$clean';
      }
    }

    final initial = company.businessName.trim().isNotEmpty
        ? company.businessName.trim().substring(0, 1).toUpperCase()
        : "C";

    String badgeText;
    if (company.activeJobsCount > 0) {
      badgeText = "${company.activeJobsCount} open";
    } else if (company.establishmentYear != null &&
        company.establishmentYear!.trim().isNotEmpty) {
      badgeText = "Est. ${company.establishmentYear!.trim()}";
    } else if (company.industry != null &&
        company.industry!.trim().isNotEmpty) {
      badgeText = company.industry!.trim();
    } else {
      badgeText = "Verified";
    }

    return TapScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CategoriesPage()),
        );
      },
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.15), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              clipBehavior: Clip.antiAlias,
              child: logoUrl != null && logoUrl.isNotEmpty
                  ? Image.network(
                      logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            Text(
              company.businessName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 10) CAREER TIPS — Micro-article Ticket Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _careerTipCard(Map<String, dynamic> tip) {
    final color = tip["color"] as Color;
    return TapScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LearningCareerPage()),
        );
      },
      child: Container(
        width: 190,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.12),
                  ),
                  child: Icon(tip["icon"] as IconData, color: color, size: 16),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "2 min read",
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tip["title"] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tip["subtitle"] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 11) PREMIUM JOBS — Gold Beveled VIP Frame Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _premiumJobCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
  }) {
    const gold = Color(0xFFB8860B);
    const goldDark = Color(0xFF8B6508);

    return Tap3D(
      onTap: () {
        final jobIdVal = job["id"] is int
            ? job["id"] as int
            : int.tryParse(job["id"]?.toString() ?? '1') ?? 1;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDescriptionPage(
              jobPostId: jobIdVal,
              companyName: (job["company"] ?? "Company").toString(),
              jobTitle: (job["title"] ?? "Job Title").toString(),
              companyFullName: (job["companyFullName"] ?? job["company"] ?? "Company").toString(),
              rating: (job["rating"] is num) ? (job["rating"] as num).toDouble() : 4.2,
              reviewCount: (job["reviewCount"] ?? "3.5k reviews").toString(),
              distance: (job["distance"] ?? "Nearby").toString(),
              salary: (job["salary"] ?? "Competitive").toString(),
              experience: (job["experience"] ?? "1-2 years").toString(),
              logoText: (job["logoText"] ?? "J").toString(),
              logoColor: (job["logoColor"] is Color) ? job["logoColor"] as Color : const Color(0xFFB8860B),
              skills: (job["skills"] is List) ? List<String>.from(job["skills"]) : const ["Flutter"],
              description: (job["description"] ?? "Job description").toString(),
              totalVacancies: (job["totalVacancies"] is int) ? job["totalVacancies"] as int : 1,
              remainingVacancies: (job["remainingVacancies"] is int) ? job["remainingVacancies"] as int : 1,
              postedDate: (job["postedDate"] ?? "Recently").toString(),
            ),
          ),
        );
      },
      builder: (pressed) {
        return Container(
          width: 165,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFDF5), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(
              color: gold.withOpacity(pressed ? 0.45 : 0.22),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: gold.withOpacity(0.08),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [gold, goldDark]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("👑", style: TextStyle(fontSize: 9)),
                        SizedBox(width: 2),
                        Text(
                          "PREMIUM",
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job["title"] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                job["company"] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                job["salary"] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: goldDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── JOB CARD HELPER — 3D NEUMORPHIC / "POP-OUT" STYLE (used in search results) ──
  Widget _jobCard({
    required String title,
    required String company,
    required String distance,
    required String salary,
    required String logoText,
    required Color logoColor,
    required String logoUrl,
  }) {
    return Tap3D(
      onTap: () {},
      builder: (pressed) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: logoColor.withOpacity(pressed ? 0.30 : 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: logoColor,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  logoUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: Text(
                        logoText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        logoText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  },
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
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          "$company • ",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: logoColor,
                        ),
                        const SizedBox(width: 1),
                        Text(
                          distance,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: logoColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.currency_rupee_rounded,
                            size: 13,
                            color: logoColor,
                          ),
                          Text(
                            salary.replaceAll("₹", ""),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: logoColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TapScale(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoriesPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: logoColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 16,
                        color: logoColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TapScale(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: logoColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_border_rounded,
                        size: 16,
                        color: logoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
                return Transform.scale(scale: 1 + (value * 0.15), child: child);
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

  // ── DRAWER TILE HELPER (colorful purple-shade icon chip) ────────────
  static Widget _drawerTile(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return TapScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWebsite() async {
    final uri = Uri.parse("https://webmediaindia.com");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class AutoScrollJobList extends StatefulWidget {
  final List<Map<String, dynamic>> jobs;
  final Widget Function(Map<String, dynamic>) cardBuilder;
  final double height;

  const AutoScrollJobList({
    super.key,
    required this.jobs,
    required this.cardBuilder,
    this.height = 150,
  });

  @override
  State<AutoScrollJobList> createState() => _AutoScrollJobListState();
}

class _AutoScrollJobListState extends State<AutoScrollJobList> {
  late final ScrollController _controller;
  Timer? _timer;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_controller.hasClients || _userInteracting) return;

      final maxScroll = _controller.position.maxScrollExtent;
      final current = _controller.offset;

      if (current >= maxScroll) {
        _controller.jumpTo(0);
      } else {
        _controller.jumpTo(current + 2.2); // scroll speed — kami/jast kar
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            _userInteracting = true;
          } else if (notification is ScrollEndNotification) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) _userInteracting = false;
            });
          }
          return false;
        },
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: widget.jobs.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: widget.cardBuilder(widget.jobs[index]),
          ),
        ),
      ),
    );
  }
}

/// ── DASHED BORDER PAINTER ─────────────────────────────────────────────
/// Used by the "Walk-in Interviews" card to give it a dashed-outline look
/// that visually differentiates it from every other section's card style.
// ignore: unused_element
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.7, 0.7, size.width - 1.4, size.height - 1.4),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

// ── SLIDER VIDEO PLAYER WIDGET ───────────────────────────────────────────
class SliderVideoPlayer extends StatefulWidget {
  final String videoPath;
  final bool isAsset;
  final bool isNetwork;

  const SliderVideoPlayer({
    super.key,
    required this.videoPath,
    this.isAsset = false,
    this.isNetwork = false,
  });

  @override
  State<SliderVideoPlayer> createState() => _SliderVideoPlayerState();
}

class _SliderVideoPlayerState extends State<SliderVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      if (widget.isNetwork) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
      } else if (widget.isAsset) {
        _controller = VideoPlayerController.asset(widget.videoPath);
      } else if (!kIsWeb) {
        _controller = VideoPlayerController.file(File(widget.videoPath));
      } else {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
      }

      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        _controller.setVolume(0.0); // Muted by default for sliders
        _controller.play();
      }
    } catch (e) {
      debugPrint("Error initializing video player: $e");
    }
  }

  @override
  void didUpdateWidget(covariant SliderVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      _controller.dispose();
      _isInitialized = false;
      _initPlayer();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black26,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
            ),
          ),
        ),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
