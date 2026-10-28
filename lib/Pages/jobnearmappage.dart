import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/saved_job_service.dart';
import '../services/job_application_service.dart';
import '../services/location_service.dart';
import '../models/location/city_model.dart';
import '../utils/session_manager.dart';
import 'applicationtrackerpage.dart';
import 'jobdescriptipnpage.dart';

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

  double _maxTravelRadius = 50.0; // Radius selection (default 50 km to show all nearby jobs)
  bool _isHeatmapView = true; // Local hiring heatmap mode enabled by default
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
  double _filterMinSalary = 0; // Default 0 to prevent accidental job filtering
  bool _filterOnlyUrgent = false;
  bool _filterOnlyVerified = false;

  // User's selected city and location services
  int? _selectedCityId;
  String _selectedCityName = "Amravati";
  final LocationService _locationService = LocationService();

  // Known city coordinates dictionary matching backend CITY_COORDINATES
  static const Map<String, (double, double)> _cityCenterCoords = {
    'amravati': (20.9374, 77.7796),
    'sai nagar': (20.9380, 77.7800),
    'mumbai': (19.0760, 72.8777),
    'pune': (18.5204, 73.8567),
    'nagpur': (21.1458, 79.0882),
    'delhi': (28.6139, 77.2090),
    'bangalore': (12.9716, 77.5946),
    'hyderabad': (17.3850, 78.4867),
    'chennai': (13.0827, 80.2707),
    'kolkata': (22.5726, 88.3639),
    'ahmedabad': (23.0225, 72.5714),
    'jaipur': (26.9124, 75.7873),
    'lucknow': (26.8467, 80.9462),
    'indore': (22.7196, 75.8577),
    'bhopal': (23.2599, 77.4126),
    'chandigarh': (30.7333, 76.7794),
    'surat': (21.1702, 72.8311),
    'nashik': (19.9975, 73.7898),
    'aurangabad': (19.8762, 75.3433),
    'solapur': (17.6599, 75.9064),
    'kolhapur': (16.7050, 74.2433),
    'akola': (20.7002, 77.0082),
    'jalgaon': (21.0077, 75.5626),
    'nanded': (19.1383, 77.3210),
    'satara': (17.6805, 73.9998),
    'sangli': (16.8524, 74.5815),
  };

  // Candidate coordinates (dynamically centered on selected city / GPS)
  double _candidateLat = 20.9374;
  double _candidateLng = 77.7796;
  bool _hasCandidateCoordinates = false;

  // Dynamic list loaded from API
  List<Map<String, dynamic>> _nearbyJobs = [];
  bool _isLoading = true;
  String? _errorMessage;

  /// Loads the selected city from SessionManager or Profile API and initiates nearby jobs fetch
  Future<void> _loadCityAndInitLocation() async {
    try {
      int? savedId = await SessionManager.getSelectedCityId();
      String? savedName = await SessionManager.getSelectedCityName();

      if (savedId == null || savedId <= 0 || savedName == null || savedName.trim().isEmpty) {
        // Fetch from user profile API: GET /api/user/profile
        try {
          final profileRes = await ApiService().getRequest('/user/profile');
          if (profileRes['status'] == true && profileRes['data'] != null) {
            final data = profileRes['data'] as Map<String, dynamic>;
            final profileCityId = data['city_id'];
            final profileCityName = data['city_name'];
            if (profileCityId != null) {
              final parsedId = profileCityId is int
                  ? profileCityId
                  : int.tryParse(profileCityId.toString());
              if (parsedId != null && parsedId > 0) {
                savedId = parsedId;
                savedName = profileCityName?.toString() ?? 'Amravati';
                await SessionManager.saveSelectedCity(
                  cityId: savedId,
                  cityName: savedName,
                );
              }
            }
          }
        } catch (e) {
          debugPrint('Error fetching profile city in JobNearMapPage: $e');
        }
      }

      // Default to Amravati (357) if no city is configured
      if (savedId == null || savedId <= 0) {
        savedId = 357;
        savedName = "Amravati";
        await SessionManager.saveSelectedCity(
          cityId: savedId,
          cityName: savedName,
        );
      }

      if (mounted) {
        setState(() {
          _selectedCityId = savedId;
          _selectedCityName = savedName ?? "Amravati";
        });
      }

      await _resolveCoordinatesForCity(savedId, savedName ?? "Amravati");
      await _fetchNearbyJobs();
    } catch (e) {
      debugPrint("Error loading city in JobNearMapPage: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load location data.";
        });
      }
    }
  }

  /// Resolves latitude/longitude for the selected city, prioritizing actual GPS
  /// if the user is in that city, and falling back to city center coordinates.
  Future<void> _resolveCoordinatesForCity(int cityId, String cityName) async {
    final cityLower = cityName.trim().toLowerCase();
    final (double, double)? center = _cityCenterCoords[cityLower];

    double defaultLat = center?.$1 ?? 20.9374;
    double defaultLng = center?.$2 ?? 77.7796;

    // Try GPS first if enabled and permitted
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
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 3),
          );

          // If GPS is within reasonable proximity (< 70km) of city center, use exact GPS
          double distFromCenter = _distanceKm(
            pos.latitude,
            pos.longitude,
            defaultLat,
            defaultLng,
          );
          if (center == null || distFromCenter <= 70) {
            if (mounted) {
              setState(() {
                _candidateLat = pos.latitude;
                _candidateLng = pos.longitude;
                _hasCandidateCoordinates = true;
              });
            }
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("GPS location check failed or unavailable: $e");
    }

    // Default to city center coordinates
    if (mounted) {
      setState(() {
        _candidateLat = defaultLat;
        _candidateLng = defaultLng;
        _hasCandidateCoordinates = true;
      });
    }
  }

  /// Updates selected city in local state, SessionManager, backend profile,
  /// resolves new coordinates, and refreshes nearby jobs.
  Future<void> _updateProfileCity({
    required int cityId,
    required String cityName,
  }) async {
    // 1. Save selected city locally
    await SessionManager.saveSelectedCity(
      cityId: cityId,
      cityName: cityName,
    );

    // 2. Clear old jobs and update UI immediately to prevent stale data
    if (mounted) {
      setState(() {
        _selectedCityId = cityId;
        _selectedCityName = cityName;
        _nearbyJobs.clear();
        _selectedJobIndex = 0;
        _isLoading = true;
        _errorMessage = null;
      });
    }

    // 3. Save new city_id to users.city_id via PUT /api/user/update-profile
    try {
      final token = await SessionManager.getToken();
      if (token != null && token.isNotEmpty) {
        final res = await ApiService().putRequest(
          '/user/update-profile',
          {"city_id": cityId},
        );
        debugPrint("JobNearMapPage profile city update (city_id: $cityId): $res");
      }
    } catch (e) {
      debugPrint("Error updating city in profile: $e");
    }

    // 4. Resolve coordinates for the newly selected city
    await _resolveCoordinatesForCity(cityId, cityName);

    // 5. Refresh nearby jobs API using the updated city_id
    await _fetchNearbyJobs();
  }

  /// Shows the city selection dialog to let the user switch cities
  void _showLocationSelectionDialog() {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
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
                "Select City",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                          color: GenZ.purple,
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
                                  color: GenZ.purple,
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
                                        final isSelected = _selectedCityId == city.id ||
                                            _selectedCityName.toLowerCase() ==
                                                city.cityName.toLowerCase();

                                        return ListTile(
                                          dense: true,
                                          leading: Icon(
                                            Icons.location_city_rounded,
                                            color: isSelected
                                                ? GenZ.purple
                                                : AppColors.unselected,
                                          ),
                                          title: Text(
                                            city.cityName,
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              color: isSelected
                                                  ? GenZ.purple
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
                                                  color: GenZ.purple,
                                                  size: 20,
                                                )
                                              : null,
                                          onTap: () async {
                                            final selectedId = city.id;
                                            final selectedName = city.cityName;
                                            Navigator.pop(dialogCtx);
                                            await _updateProfileCity(
                                              cityId: selectedId,
                                              cityName: selectedName,
                                            );
                                          },
                                        );
                                      },
                                    ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Navigates to the existing JobDescriptionPage with actual job details
  void _navigateToJobDescription(Map<String, dynamic> job, double? distanceKm) {
    final int numericJobId = int.tryParse(job["id"]?.toString() ?? '0') ?? 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDescriptionPage(
          jobPostId: numericJobId,
          companyName: (job["company"] ?? "Company").toString(),
          jobTitle: (job["title"] ?? "Job Title").toString(),
          salary: (job["salary"] ?? "").toString(),
          experience: (job["experience"] ?? "").toString(),
          distance: _formatDistance(distanceKm),
          description: (job["description"] ?? "").toString(),
          skills: (job["requiredSkills"] is List)
              ? (job["requiredSkills"] as List).map((e) => e.toString()).toList()
              : const ["Communication", "Problem Solving"],
          rating: (job["ratings"] as num?)?.toDouble() ?? 4.2,
          reviewCount: "${job['reviews']} reviews",
          logoText: (job["logoText"] ?? "J").toString(),
          logoColor: (job["logoColor"] is Color) ? job["logoColor"] as Color : GenZ.purple,
          totalVacancies: (job["vacancies"] as num?)?.toInt() ?? 1,
          remainingVacancies: (job["remaining_vacancies"] as num?)?.toInt() ?? 1,
          postedDate: (job["postedTime"] ?? "Recently").toString(),
        ),
      ),
    );
  }

  Future<void> _fetchUserSavedJobs() async {
    try {
      final userDetails = await SessionManager.getUserDetails();
      final userId = (userDetails['id'] is int)
          ? userDetails['id'] as int
          : int.tryParse(userDetails['id']?.toString() ?? '0') ?? 0;
      if (userId > 0) {
        final savedJobs = await SavedJobService().getSavedJobsByUser(userId);
        if (mounted) {
          setState(() {
            _savedJobIds.clear();
            for (final sj in savedJobs) {
              _savedJobIds.add(sj.jobPostId.toString());
              if (sj.jobPost.id > 0) {
                _savedJobIds.add(sj.jobPost.id.toString());
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching saved jobs for user: $e");
    }
  }

  Future<void> _fetchUserApplications() async {
    try {
      final userDetails = await SessionManager.getUserDetails();
      final userId = (userDetails['id'] is int)
          ? userDetails['id'] as int
          : int.tryParse(userDetails['id']?.toString() ?? '0') ?? 0;
      if (userId > 0) {
        final apps = await JobApplicationService().getUserApplications(userId);
        if (mounted) {
          setState(() {
            _appliedJobIds.clear();
            for (final app in apps) {
              if (app.jobPostId > 0) {
                _appliedJobIds.add(app.jobPostId.toString());
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching applications for user: $e");
    }
  }

  Future<void> _fetchNearbyJobs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _fetchUserSavedJobs();
    _fetchUserApplications();

    try {
      final cityId = _selectedCityId;
      if (cityId == null || cityId <= 0) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Please select a city to see nearby jobs.";
            _nearbyJobs = [];
          });
        }
        return;
      }

      // 1. Fetch nearby job posts via API (/jobpost/nearby) with cityId filter
      final response = await ApiService().getNearbyJobs(
        _candidateLat,
        _candidateLng,
        radius: _maxTravelRadius,
        cityId: cityId,
      );

      List<dynamic> rawJobs = [];
      if (response != null && (response['success'] == true || response['status'] == true)) {
        if (response['data'] is List) {
          rawJobs = response['data'];
        } else if (response['jobPosts'] is List) {
          rawJobs = response['jobPosts'];
        } else if (response['jobs'] is List) {
          rawJobs = response['jobs'];
        }
      } else if (response != null && response['message'] != null) {
        _errorMessage = response['message'].toString();
      }

      // 2. Parse dynamic job posts and ensure strict city_id match (no fallback to other cities)
      final List<Map<String, dynamic>> parsed = [];
      for (int i = 0; i < rawJobs.length; i++) {
        final item = rawJobs[i];
        if (item is Map<String, dynamic>) {
          final jobCityId = item['city_id'] ?? item['cityId'];
          final parsedJobCityId = jobCityId is int
              ? jobCityId
              : int.tryParse(jobCityId?.toString() ?? '');
          // Strictly verify city_id
          if (parsedJobCityId == null || parsedJobCityId == cityId) {
            parsed.add(_parseJobMap(item, i, rawJobs.length));
          }
        }
      }

      if (mounted) {
        setState(() {
          _nearbyJobs = parsed;
          _isLoading = false;
          _selectedJobIndex = 0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching dynamic nearby jobs: $e");
      if (mounted) {
        setState(() {
          _nearbyJobs = [];
          _isLoading = false;
          _errorMessage = "Failed to load jobs for $_selectedCityName. Please check your connection.";
        });
      }
    }
  }

  Map<String, dynamic> _parseJobMap(
    Map<String, dynamic> json,
    int index,
    int total,
  ) {
    final String jobId =
        (json['id'] ?? json['_id'] ?? 'job_$index').toString();
    final String title = (json['title'] ??
            json['job_title'] ??
            json['jobTitle'] ??
            'Job Opening')
        .toString();
    final String company = (json['company'] ??
            json['company_name'] ??
            json['companyName'] ??
            json['job_category'] ??
            'Employer')
        .toString();

    final String logoText = company.trim().isNotEmpty
        ? company.trim().substring(0, 1).toUpperCase()
        : 'J';

    final List<Color> logoColors = [
      const Color(0xFF1E3A8A),
      const Color(0xFF007ACC),
      const Color(0xFFE11D48),
      const Color(0xFF6D28D9),
      const Color(0xFFEA580C),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
    ];
    final Color logoColor = logoColors[index % logoColors.length];

    final int minSalaryVal = json['min_salary'] is num
        ? (json['min_salary'] as num).toInt()
        : (json['salary_min'] is num
            ? (json['salary_min'] as num).toInt()
            : int.tryParse(
                    json['min_salary']?.toString() ??
                        json['salary_min']?.toString() ??
                        '25000',
                  ) ??
                25000);

    final int maxSalaryVal = json['max_salary'] is num
        ? (json['max_salary'] as num).toInt()
        : (json['salary_max'] is num
            ? (json['salary_max'] as num).toInt()
            : int.tryParse(
                    json['max_salary']?.toString() ??
                        json['salary_max']?.toString() ??
                        '45000',
                  ) ??
                45000);

    final String salary = json['salary'] != null
        ? json['salary'].toString()
        : "₹${minSalaryVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} - ₹${maxSalaryVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

    final String experience = (json['experience'] ??
            json['experience_required'] ??
            json['experienceRequired'] ??
            'Fresher')
        .toString();

    final String employmentType = (json['employmentType'] ??
            json['employment_type'] ??
            json['job_type'] ??
            'Full-time')
        .toString();

    final String location = (json['location'] ??
            json['city'] ??
            json['address'] ??
            json['locality'] ??
            'Nearby')
        .toString();

    final String postedTime = (json['postedTime'] ??
            json['posted_on'] ??
            json['created_at'] ??
            'Recently')
        .toString();

    final bool isVerified = json['isVerified'] == true ||
        json['is_verified'] == true ||
        json['is_verified'] == 1 ||
        json['verified'] == true;

    final bool isUrgent = json['isUrgent'] == true ||
        json['is_urgent'] == true ||
        json['is_urgent'] == 1 ||
        json['urgent'] == true;

    // Lat / Lng parsing
    final rawJobLat = json['latitude'] ?? json['lat'];
    final rawJobLng = json['longitude'] ?? json['lng'];
    final double? parsedJobLat = rawJobLat is num
        ? rawJobLat.toDouble()
        : double.tryParse(rawJobLat?.toString() ?? '');
    final double? parsedJobLng = rawJobLng is num
        ? rawJobLng.toDouble()
        : double.tryParse(rawJobLng?.toString() ?? '');
    final bool hasValidCoords = parsedJobLat != null &&
        parsedJobLng != null &&
        parsedJobLat.isFinite &&
        parsedJobLng.isFinite;

    final double jobLat = hasValidCoords
        ? parsedJobLat
        : (_candidateLat + (index - total / 2) * 0.02);

    final double jobLng = hasValidCoords
        ? parsedJobLng
        : (_candidateLng + ((index * 3) % 7 - 3) * 0.02);

    // Dynamic screen pin vector layout (dx, dy between 0.15 and 0.85)
    double dx;
    double dy;

    if (json['dx'] is num && json['dy'] is num) {
      dx = (json['dx'] as num).toDouble();
      dy = (json['dy'] as num).toDouble();
    } else {
      double dLat = jobLat - _candidateLat;
      double dLng = jobLng - _candidateLng;

      dx = (0.5 + dLng * 4.0).clamp(0.15, 0.85);
      dy = (0.5 - dLat * 4.0).clamp(0.15, 0.85);

      if (total > 1 && (dx - 0.5).abs() < 0.02 && (dy - 0.5).abs() < 0.02) {
        double angle = (2 * math.pi * index) / total;
        double r = 0.25;
        dx = (0.5 + r * math.cos(angle)).clamp(0.15, 0.85);
        dy = (0.5 + r * math.sin(angle)).clamp(0.15, 0.85);
      }
    }

    final String description = (json['description'] ??
            json['job_summary'] ??
            'We are looking for a qualified candidate to join our growing team.')
        .toString();

    List<String> responsibilities = [];
    if (json['responsibilities'] is List) {
      responsibilities = (json['responsibilities'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (json['responsibilities'] is String) {
      responsibilities = [json['responsibilities'].toString()];
    } else {
      responsibilities = [
        "Collaborate with cross-functional teams.",
        "Perform regular daily duties and assigned projects.",
        "Maintain high standards of accuracy and performance.",
      ];
    }

    List<String> requiredSkills = [];
    if (json['requiredSkills'] is List) {
      requiredSkills = (json['requiredSkills'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (json['skills'] is List) {
      requiredSkills =
          (json['skills'] as List).map((e) => e.toString()).toList();
    } else if (json['skills'] is String) {
      requiredSkills = (json['skills'] as String)
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      requiredSkills = ["Communication", "Problem Solving", "Teamwork"];
    }

    return {
      "id": jobId,
      "title": title,
      "company": company,
      "logoText": logoText,
      "logoColor": logoColor,
      "salary": salary,
      "minSalaryVal": minSalaryVal,
      "experience": experience,
      "employmentType": employmentType,
      "location": location,
      "postedTime": postedTime,
      "isVerified": isVerified,
      "isUrgent": isUrgent,
      "lat": jobLat,
      "lng": jobLng,
      "rawLat": parsedJobLat,
      "rawLng": parsedJobLng,
      "hasValidCoords": hasValidCoords,
      "dx": dx,
      "dy": dy,
      "description": description,
      "responsibilities": responsibilities,
      "requiredSkills": requiredSkills,
      "qualification": (json['qualification'] ?? 'Graduate').toString(),
      "incentives":
          (json['incentives'] ?? 'Performance bonuses & health benefits')
              .toString(),
      "vacancies": num.tryParse(
            json['vacancies']?.toString() ??
                json['number_of_vacancies']?.toString() ??
                '1',
          )?.toInt() ??
          1,
      "shift": (json['shift'] ?? 'Day Shift').toString(),
      "workingHours": (json['workingHours'] ?? '9:00 AM - 6:00 PM').toString(),
      "weeklyOff": (json['weeklyOff'] ?? 'Sunday').toString(),
      "benefits":
          (json['benefits'] ?? 'Health insurance, paid leave').toString(),
      "deadline": (json['deadline'] ?? 'Open until filled').toString(),
      "companyProfile": (json['companyProfile'] ??
              '$company is a verified hiring employer.')
          .toString(),
      "companySize": (json['companySize'] ?? '50+ employees').toString(),
      "ratings": double.tryParse(
            json['ratings']?.toString() ??
                json['rating']?.toString() ??
                '4.2',
          ) ??
          4.2,
      "reviews": int.tryParse(
            json['reviews']?.toString() ??
                json['reviews_count']?.toString() ??
                '25',
          ) ??
          25,
      "isClosed": json['isClosed'] == true || json['status'] == 'Closed',
      "isExpired": json['isExpired'] == true || json['status'] == 'Expired',
    };
  }

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

    _loadCityAndInitLocation();
    _fetchUserSavedJobs();
    _fetchUserApplications();

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

  double? _getJobDistanceKm(Map<String, dynamic> job) {
    if (!_hasCandidateCoordinates) {
      return null;
    }
    final bool hasValid = job["hasValidCoords"] == true;
    if (!hasValid) {
      return null;
    }
    final double? jLat = job["rawLat"] as double?;
    final double? jLng = job["rawLng"] as double?;
    if (jLat == null || jLng == null) return null;
    return _distanceKm(_candidateLat, _candidateLng, jLat, jLng);
  }

  String _formatDistance(double? km) {
    if (km == null || km.isNaN || km.isInfinite) {
      return "Distance unavailable";
    }
    if (km.abs() < 0.0001) {
      return "0 m away";
    }
    if (km < 1.0) {
      final meters = (km * 1000).round();
      return "$meters m away";
    }
    return "${km.toStringAsFixed(1)} km away";
  }

  @override
  Widget build(BuildContext context) {
    // Filter jobs list based on travel radius, search queries, and filters sheet
    final filteredJobs = _nearbyJobs.where((job) {
      final double? distance = _getJobDistanceKm(job);

      // Distance limit constraint (Radius Selection)
      if (distance != null && distance > _maxTravelRadius) return false;

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
    final double? distanceKm = job != null ? _getJobDistanceKm(job) : null;

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
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: GestureDetector(
          onTap: _showLocationSelectionDialog,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "Live Map & Commute Radar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$_selectedCityName • ${_maxTravelRadius.toInt()} KM Radial Grid",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // City Change Pill
          GestureDetector(
            onTap: _showLocationSelectionDialog,
            child: Container(
              margin: const EdgeInsets.only(top: 11, bottom: 11, right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 13, color: Colors.white),
                  const SizedBox(width: 3),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 75),
                    child: Text(
                      _selectedCityName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 14, color: Colors.white),
                ],
              ),
            ),
          ),

          // Pins Count Pill Badge
          Container(
            margin: const EdgeInsets.only(right: 6, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF00D2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                "${filteredJobs.length} Pins",
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Heatmap Switch Button
          IconButton(
            icon: Icon(
              _isHeatmapView
                  ? Icons.local_fire_department_rounded
                  : Icons.local_fire_department_outlined,
              color: _isHeatmapView ? const Color(0xFFFF4D4D) : Colors.white,
            ),
            tooltip: "Toggle Heatmap",
            onPressed: () {
              setState(() {
                _isHeatmapView = !_isHeatmapView;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isHeatmapView
                        ? "🔥 Heatmap Mode Enabled (Red = High Job Density)"
                        : "📍 Standard Pin Mode Enabled",
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
                jobOffsets: filteredJobs
                    .map((j) => Offset(j["dx"] as double, j["dy"] as double))
                    .toList(),
              ),
            ),

            // ── CURRENT LOCATION INDICATOR ──
            const Center(child: _CurrentLocationIndicator()),

            // ── LOADING INDICATOR ──
            if (_isLoading)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: GenZ.purple,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Loading nearby jobs from API...",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: GenZ.purpleDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── EMPTY STATE IF 0 DYNAMIC JOBS IN DATABASE FOR SELECTED CITY ──
            if (!_isLoading && _nearbyJobs.isEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: GenZ.lavenderSoft.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.work_off_rounded,
                          size: 30,
                          color: GenZ.purple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage ?? "No jobs found in $_selectedCityName",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "There are currently no job openings matching $_selectedCityName within ${_maxTravelRadius.toInt()} km.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _showLocationSelectionDialog,
                            icon: const Icon(Icons.location_city_rounded, size: 16),
                            label: const Text("Change City"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: GenZ.purple,
                              side: const BorderSide(color: GenZ.purple),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _fetchNearbyJobs,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text("Refresh"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GenZ.purple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // ── JOB PINS (Rich callout pills matching live commute radar reference) ──
            if (hasResults)
              LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: List.generate(filteredJobs.length, (i) {
                      final j = filteredJobs[i];
                      final isSelected = i == _selectedJobIndex;
                      final double? distance = _getJobDistanceKm(j);
                      final double rating = (j["ratings"] as num?)?.toDouble() ?? 4.5;
                      final double dx = j["dx"] as double;
                      final double dy = j["dy"] as double;

                      final double leftPos = (constraints.maxWidth * dx - 55).clamp(8.0, constraints.maxWidth - 130.0);
                      final double topPos = (constraints.maxHeight * dy - 40).clamp(8.0, constraints.maxHeight - 55.0);

                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        left: leftPos,
                        top: topPos,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 400 + (i * 70)),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedJobIndex = i),
                            child: _mapPinCallout(
                              isSelected: isSelected,
                              title: j["title"] as String,
                              company: j["company"] as String,
                              logoText: j["logoText"] as String,
                              logoColor: j["logoColor"] as Color,
                              distanceKm: distance,
                              rating: rating,
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
                    onTap: () async {
                      setState(() => _isSearchingThisArea = true);
                      await _fetchNearbyJobs();
                      if (!mounted) return;
                      setState(() => _isSearchingThisArea = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Refreshed jobs in this area from API"),
                          duration: Duration(seconds: 1),
                        ),
                      );
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
    required List<Offset> jobOffsets,
  }) {
    return Container(
      color: const Color(0xFFEDF1F5),
      child: CustomPaint(
        painter: _FakeMapPainter(
          drawHeatmap: drawHeatmap,
          radiusKm: radiusKm,
          jobOffsets: jobOffsets,
        ),
        child: Container(),
      ),
    );
  }

  // Styled Callout Map Pin (matching reference screenshot)
  Widget _mapPinCallout({
    required bool isSelected,
    required String title,
    required String company,
    required String logoText,
    required Color logoColor,
    required double? distanceKm,
    required double rating,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? GenZ.purple : const Color(0xFF3B82F6).withOpacity(0.5),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? GenZ.purple.withOpacity(0.35)
                    : Colors.black.withOpacity(0.12),
                blurRadius: isSelected ? 10 : 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar circle with initial letter
              Container(
                width: isSelected ? 24 : 20,
                height: isSelected ? 24 : 20,
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
                      fontSize: isSelected ? 12 : 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Title & Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 105),
                    child: Text(
                      company.isNotEmpty ? "$logoText • $company" : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSelected ? 11.5 : 10.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDistance(distanceKm),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star_rounded,
                        size: 10,
                        color: Color(0xFFF59E0B),
                      ),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Pin Stem Pointer
        CustomPaint(
          size: const Size(12, 6),
          painter: _PinStemPainter(
            color: isSelected ? GenZ.purple : Colors.white,
          ),
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

  // Job Card preview (matching reference screenshot bottom card)
  Widget _jobBottomCard(Map<String, dynamic> job, double? distanceKm) {
    final double rating = (job["ratings"] as num?)?.toDouble() ?? 4.5;
    final int bikeMins = distanceKm != null ? (distanceKm * 3.0).round().clamp(2, 90) : 15;

    return GestureDetector(
      onTap: () => _navigateToJobDescription(job, distanceKm),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
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
              // Avatar circle with logo text
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: job["logoColor"] as Color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    job["logoText"] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title / Company / Position
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
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
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
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating & Distance (Right side)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDistance(distanceKm),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Divider
          Divider(color: Colors.grey.withOpacity(0.18), height: 1),
          const SizedBox(height: 10),

          // Location & Commute time badge
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 15,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job["location"] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_bike_rounded,
                      size: 14,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "~$bikeMins mins bike",
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _openJobDetailsBottomSheet(job, distanceKm),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: GenZ.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "View Job",
                    style: TextStyle(
                      fontSize: 12,
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
  void _openJobDetailsBottomSheet(Map<String, dynamic> job, double? distanceKm) {
    final String jobId = job["id"] as String;
    final int numericJobId = int.tryParse(jobId) ?? 0;

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
        bool isSavingJob = false;
        bool isApplyingJob = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bool isApplied = _appliedJobIds.contains(jobId) ||
                (numericJobId > 0 && _appliedJobIds.contains(numericJobId.toString()));
            final bool isSaved = _savedJobIds.contains(jobId) ||
                (numericJobId > 0 && _savedJobIds.contains(numericJobId.toString()));
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
                        icon: isSavingJob
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: GenZ.purpleDark,
                                ),
                              )
                            : Icon(
                                isSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                              ),
                        color: isSaved ? GenZ.purpleDark : Colors.grey,
                        onPressed: isSavingJob
                            ? null
                            : () async {
                                final userDetails =
                                    await SessionManager.getUserDetails();
                                final userId = (userDetails['id'] is int)
                                    ? userDetails['id'] as int
                                    : int.tryParse(
                                            userDetails['id']?.toString() ??
                                                '0') ??
                                        0;

                                if (userId == 0) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Please log in to save jobs."),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                  return;
                                }

                                setSheetState(() {
                                  isSavingJob = true;
                                });

                                try {
                                  if (isSaved) {
                                    final res = await SavedJobService()
                                        .deleteSavedJob(
                                      userId: userId,
                                      jobPostId: numericJobId,
                                    );
                                    if (res['success'] == true) {
                                      setState(() {
                                        _savedJobIds.remove(jobId);
                                        _savedJobIds
                                            .remove(numericJobId.toString());
                                      });
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Job removed from saved jobs"),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(res['message']
                                                    ?.toString() ??
                                                "Failed to remove saved job"),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    final res = await SavedJobService().saveJob(
                                      userId: userId,
                                      jobPostId: numericJobId,
                                    );
                                    if (res['success'] == true) {
                                      setState(() {
                                        _savedJobIds.add(jobId);
                                        _savedJobIds
                                            .add(numericJobId.toString());
                                      });
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Job saved successfully!"),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(res['message']
                                                    ?.toString() ??
                                                "Failed to save job"),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error: $e"),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                } finally {
                                  setSheetState(() {
                                    isSavingJob = false;
                                  });
                                }
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            }).toList(),
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
                                backgroundColor:
                                    GenZ.purple.withOpacity(0.12),
                                padding: EdgeInsets.zero,
                              );
                            }).toList(),
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

                  // Actions Panel (Apply, Directions, Share — Message & Report removed)
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
                        const SizedBox(width: 10),

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
                        const SizedBox(width: 14),

                        // Primary Action Button (Apply Now / Expired / Closed / Applied)
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
                              onPressed: (canApply && !isApplyingJob)
                                  ? () async {
                                      final userDetails =
                                          await SessionManager.getUserDetails();
                                      final userId = (userDetails['id'] is int)
                                          ? userDetails['id'] as int
                                          : int.tryParse(
                                                  userDetails['id']
                                                          ?.toString() ??
                                                      '0') ??
                                              0;

                                      if (userId == 0) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Please log in to apply for this job."),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      // Resume completion check (>= 75%)
                                      final isResumeValid =
                                          await JobApplicationService()
                                              .validateResumeCompletion(
                                                  context);
                                      if (!isResumeValid) return;

                                      setSheetState(() {
                                        isApplyingJob = true;
                                      });

                                      try {
                                        final res = await JobApplicationService()
                                            .applyForJob(
                                          userId: userId,
                                          jobPostId: numericJobId,
                                        );

                                        if (res['success'] == true) {
                                          setState(() {
                                            _appliedJobIds.add(jobId);
                                            _appliedJobIds
                                                .add(numericJobId.toString());
                                          });

                                          if (context.mounted) {
                                            Navigator.pop(
                                                context); // Close bottom sheet
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  res['message']?.toString() ??
                                                      "Application submitted successfully to ${job["company"]}!",
                                                ),
                                                backgroundColor:
                                                    AppColors.success,
                                              ),
                                            );
                                            // Navigate to Application Tracker page and refresh when returning
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const ApplicationTrackerPage(),
                                              ),
                                            );
                                            _fetchUserApplications();
                                          }
                                        } else {
                                          final msg = res['message']
                                                  ?.toString() ??
                                              "Failed to apply for job";
                                          if (msg
                                              .toLowerCase()
                                              .contains("already applied")) {
                                            setState(() {
                                              _appliedJobIds.add(jobId);
                                              _appliedJobIds
                                                  .add(numericJobId.toString());
                                            });
                                          }
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                              ..hideCurrentSnackBar()
                                              ..showSnackBar(
                                                SnackBar(
                                                  content: Text(msg),
                                                  backgroundColor:
                                                      AppColors.error,
                                                ),
                                              );
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "Error submitting application: $e"),
                                              backgroundColor:
                                                  AppColors.error,
                                            ),
                                          );
                                        }
                                      } finally {
                                        setSheetState(() {
                                          isApplyingJob = false;
                                        });
                                      }
                                    }
                                  : (isApplied
                                      ? () async {
                                          Navigator.pop(context);
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const ApplicationTrackerPage(),
                                            ),
                                          );
                                          _fetchUserApplications();
                                        }
                                      : null),
                              child: isApplyingJob
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
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

/// ── Pin Stem Triangle Pointer ──
class _PinStemPainter extends CustomPainter {
  final Color color;
  _PinStemPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinStemPainter oldDelegate) => oldDelegate.color != color;
}

/// ── FAKE MAP PAINTER WITH RADIAL GRID & HEATMAP ──
class _FakeMapPainter extends CustomPainter {
  final bool drawHeatmap;
  final double radiusKm;
  final List<Offset> jobOffsets;

  _FakeMapPainter({
    required this.drawHeatmap,
    required this.radiusKm,
    required this.jobOffsets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);

    // 1. Draw Map background grid roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5;

    final thinRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2;

    for (double y = size.height * 0.12; y < size.height; y += size.height * 0.18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }

    for (double x = size.width * 0.15; x < size.width; x += size.width * 0.22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), thinRoadPaint);
    }

    // Soft green park area
    final parkPaint = Paint()..color = const Color(0xFFD9EAD3);
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.58, size.height * 0.60, size.width * 0.32, size.height * 0.22),
      parkPaint,
    );

    // Soft blue water area
    final waterPaint = Paint()..color = const Color(0xFFCFE2F3);
    canvas.drawOval(
      Rect.fromLTWH(-size.width * 0.15, size.height * 0.02, size.width * 0.45, size.height * 0.16),
      waterPaint,
    );

    // 2. Draw Concentric Radial Grid Circles (5 KM & Selected Radius)
    final double px5km = 5.0 * 18.0;
    final double pxMaxRadius = radiusKm * 18.0;

    final dashPaint5km = Paint()
      ..color = const Color(0xFF1E3AE2).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dashPaintMaxRadius = Paint()
      ..color = const Color(0xFF1E3AE2).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = const Color(0xFF1E3AE2).withOpacity(0.04)
      ..style = PaintingStyle.fill;

    // Translucent fill & outer radial circle
    canvas.drawCircle(center, pxMaxRadius, fillPaint);
    _drawDashedCircle(canvas, center, pxMaxRadius, dashPaintMaxRadius, dashCount: 48);

    // Inner 5km circle
    if (pxMaxRadius > px5km) {
      _drawDashedCircle(canvas, center, px5km, dashPaint5km, dashCount: 36);
    }

    // 3. Draw Local Hiring Heatmap Overlays (Red core -> Orange ring -> Yellow glow)
    if (drawHeatmap) {
      for (final offset in jobOffsets) {
        final pt = Offset(size.width * offset.dx, size.height * offset.dy);

        final yellowHeat = Paint()
          ..color = const Color(0xFFFBBF24).withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

        final orangeHeat = Paint()
          ..color = const Color(0xFFF97316).withOpacity(0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

        final redHeat = Paint()
          ..color = const Color(0xFFEF4444).withOpacity(0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

        canvas.drawCircle(pt, 50, yellowHeat);
        canvas.drawCircle(pt, 34, orangeHeat);
        canvas.drawCircle(pt, 20, redHeat);
      }
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint, {int dashCount = 40}) {
    final double sweepAngle = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweepAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FakeMapPainter oldDelegate) {
    return oldDelegate.drawHeatmap != drawHeatmap ||
        oldDelegate.radiusKm != radiusKm ||
        oldDelegate.jobOffsets != jobOffsets;
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
