import 'package:flutter/material.dart';
import '../models/job/recent_job_model.dart';
import '../services/api_service.dart';
import '../utils/api_constants.dart';
import '../Pages/jobdescriptipnpage.dart';
import '../Pages/recommendedjpbpage.dart';

class RecentJobController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<RecentJobModel> recentJobs = [];
  bool isLoading = false;
  String? errorMessage;

  /// Loads recently posted jobs from backend API route with optional city filter
  Future<void> loadRecentJobs({bool silent = false, int? cityId}) async {
    if (!silent) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final queryParam = (cityId != null && cityId > 0) ? '?city_id=$cityId' : '';
      // 1. Fetch from recent jobs route (/jobpost/public)
      var response = await _apiService.getRequest('${ApiConstants.recentJobs}$queryParam');

      // 2. Fallback to /jobs route if primary response is empty
      if (response['jobPosts'] == null && response['data'] == null && response['jobs'] == null) {
        response = await _apiService.getRequest('${ApiConstants.recentJobsFallback}$queryParam');
      }

      List<dynamic>? rawList;
      if (response['jobPosts'] is List) {
        rawList = response['jobPosts'];
      } else if (response['data'] is List) {
        rawList = response['data'];
      } else if (response['jobs'] is List) {
        rawList = response['jobs'];
      }

      if (rawList != null && rawList.isNotEmpty) {
        List<RecentJobModel> parsed = [];

        for (int i = 0; i < rawList.length; i++) {
          final item = rawList[i];
          if (item is Map<String, dynamic>) {
            final st = (item['status'] ?? '').toString().toLowerCase().trim();
            // Include active/published or unflagged jobs
            if (st == 'published' || st == 'active' || st.isEmpty) {
              parsed.add(RecentJobModel.fromJson(item, i));
            }
          }
        }

        // Apply strict city filter if cityId is specified
        if (cityId != null && cityId > 0) {
          parsed = parsed.where((j) => j.cityId == cityId).toList();
        }

        // Sort newest first by created_at / id descending
        parsed.sort((a, b) {
          if (a.createdAt != null && b.createdAt != null) {
            final dtA = DateTime.tryParse(a.createdAt!);
            final dtB = DateTime.tryParse(b.createdAt!);
            if (dtA != null && dtB != null) {
              return dtB.compareTo(dtA);
            }
          }
          return b.id.compareTo(a.id);
        });

        recentJobs = parsed;
        errorMessage = null;
      } else {
        recentJobs = [];
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("RecentJobController loadRecentJobs error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Dedicated route to Job Description Page for a recently posted job
  void navigateToJobDetails(BuildContext context, RecentJobModel job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDescriptionPage(
          jobPostId: job.id,
          companyName: job.company,
          jobTitle: job.title,
          companyFullName: job.companyFullName,
          rating: job.rating,
          reviewCount: job.reviewCount,
          distance: job.distance,
          salary: job.salary,
          experience: job.experience,
          logoText: job.companyInitial,
          logoColor: job.logoColor,
          logoImageUrl: job.logoUrl,
          skills: job.skills,
          description: job.description,
          totalVacancies: job.totalVacancies,
          remainingVacancies: job.remainingVacancies,
          postedDate: job.postedDate,
        ),
      ),
    );
  }

  /// Dedicated route to View All Recently Posted Jobs (Recommended Job Page)
  void navigateToAllRecentJobs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecommendedJobPage(),
      ),
    );
  }
}
