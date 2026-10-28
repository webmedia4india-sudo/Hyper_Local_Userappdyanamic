import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applicationtrackerpage.dart';
import 'package:hyper_local/Pages/jobdescriptipnpage.dart';
import 'package:hyper_local/models/job/saved_job_model.dart';
import 'package:hyper_local/services/saved_job_service.dart';
import 'package:hyper_local/utils/session_manager.dart';
import '../utils/app_colors.dart';

/// Saved Jobs page — dynamic saved jobs from backend API:
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

  // ── DYNAMIC SAVED JOBS DATA ─────────────────────────────
  List<SavedJobModel> _apiSavedJobs = [];
  bool _isLoadingSavedJobs = true;
  String? _errorMessage;

  // ── RECENTLY VIEWED JOBS ─────────────────────────────────
  final List<Map<String, dynamic>> _recentlyViewedJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchSavedJobs();
  }

  Future<void> _fetchSavedJobs() async {
    setState(() {
      _isLoadingSavedJobs = true;
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
            _apiSavedJobs = [];
            _isLoadingSavedJobs = false;
            _errorMessage = "Please log in to view saved jobs.";
          });
        }
        return;
      }

      final savedJobs = await SavedJobService().getSavedJobsByUser(userId);

      if (mounted) {
        setState(() {
          _apiSavedJobs = savedJobs;
          _isLoadingSavedJobs = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching saved jobs: $e");
      if (mounted) {
        setState(() {
          _isLoadingSavedJobs = false;
          _errorMessage = "Failed to load saved jobs. Please try again.";
        });
      }
    }
  }

  Future<void> _unsaveJob(SavedJobModel savedJob) async {
    try {
      final userDetails = await SessionManager.getUserDetails();
      final userId = (userDetails['id'] is int)
          ? userDetails['id'] as int
          : int.tryParse(userDetails['id']?.toString() ?? '0') ?? 0;

      if (userId == 0) return;

      final res = await SavedJobService().deleteSavedJob(
        userId: userId,
        jobPostId: savedJob.jobPostId,
      );

      if (res['success'] == true) {
        setState(() {
          _apiSavedJobs.removeWhere(
            (item) =>
                item.savedJobId == savedJob.savedJobId ||
                item.jobPostId == savedJob.jobPostId,
          );
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Job removed from saved jobs"),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res['message']?.toString() ?? "Failed to remove saved job",
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error unsaving job: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── FILTERED SAVED JOBS ─────────────────────────────────
  List<SavedJobModel> get _filteredSavedJobs {
    if (_searchQuery.trim().isEmpty) return _apiSavedJobs;
    final query = _searchQuery.toLowerCase();
    return _apiSavedJobs.where((savedJob) {
      final title = savedJob.jobPost.title.toLowerCase();
      final company = savedJob.jobPost.companyName.toLowerCase();
      return title.contains(query) || company.contains(query);
    }).toList();
  }

  // ── FILTERED RECENTLY VIEWED JOBS ───────────────────────
  List<Map<String, dynamic>> get _filteredRecentlyViewedJobs {
    if (_searchQuery.trim().isEmpty) return _recentlyViewedJobs;
    final query = _searchQuery.toLowerCase();
    return _recentlyViewedJobs.where((job) {
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
      body: Column(
        children: [
          const SizedBox(height: 16),

          // ── SEGMENTED TAB CONTROL ────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _segmentedTabs(),
          ),
          const SizedBox(height: 16),

          // ── JOB LIST / CONTENT ────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedTab == 0) {
      if (_isLoadingSavedJobs) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (_errorMessage != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchSavedJobs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  "Retry",
                  style: TextStyle(color: AppColors.buttonText),
                ),
              ),
            ],
          ),
        );
      }

      final savedJobs = _filteredSavedJobs;

      if (savedJobs.isEmpty) {
        return RefreshIndicator(
          onRefresh: _fetchSavedJobs,
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isSearching && _searchQuery.isNotEmpty) ...[
                        const Icon(
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
                      ] else ...[
                        const Icon(
                          Icons.bookmark_border_rounded,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No saved jobs yet.",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Jobs you save will appear here",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _fetchSavedJobs,
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: savedJobs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _savedJobCard(savedJobs[index]),
        ),
      );
    } else {
      final recentJobs = _filteredRecentlyViewedJobs;

      if (recentJobs.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSearching && _searchQuery.isNotEmpty) ...[
                const Icon(
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
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: recentJobs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _recentlyViewedJobCard(recentJobs[index]),
      );
    }
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
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
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

  // ── DYNAMIC SAVED JOB CARD ────────────────────────────────
  Widget _savedJobCard(SavedJobModel savedJob) {
    final job = savedJob.jobPost;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDescriptionPage(
              jobPostId: job.id,
              companyName: job.companyName,
              jobTitle: job.title,
              companyFullName: job.companyName,
              rating: job.displayRating,
              reviewCount: job.displayReviewCount,
              distance: job.formattedDistance,
              salary: job.formattedSalary,
              experience: job.experienceRequired ?? "1-2 years",
              logoText: job.logoLetter,
              logoColor: job.logoColor,
              skills: job.skills.isNotEmpty
                  ? job.skills
                  : const ["Flutter", "Dart"],
              description: job.description ?? "No description available.",
              totalVacancies: job.totalVacancies,
              remainingVacancies: job.remainingVacancies,
              postedDate: job.formattedPostedDate,
            ),
          ),
        ).then((_) => _fetchSavedJobs());
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: job.logoColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  job.logoLetter,
                  style: const TextStyle(
                    color: AppColors.buttonText,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                  Text(
                    "${job.companyName} · ${job.formattedDistance}",
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
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
                        "${job.displayRating}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.formattedSalary,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                  child: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 22),
                InkWell(
                  onTap: () => _unsaveJob(savedJob),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── RECENTLY VIEWED JOB CARD ──────────────────────────────
  Widget _recentlyViewedJobCard(Map<String, dynamic> job) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Text(
                  "${job["company"]} · ${job["distance"]}",
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job["salary"] as String,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                child: const Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 22),
              InkWell(
                onTap: () {},
                child: const Icon(
                  Icons.bookmark_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
