import 'package:flutter/material.dart';
import 'api_service.dart';
import '../models/job/job_application_model.dart';
import '../Pages/resumeuploded.dart';
import '../utils/app_colors.dart';

class JobApplicationService {
  final ApiService _apiService = ApiService();

  /// Apply for a job post
  Future<Map<String, dynamic>> applyForJob({
    required int userId,
    required int jobPostId,
    int? resumeId,
    String? coverLetter,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'user_id': userId,
        'job_post_id': jobPostId,
      };
      if (resumeId != null) {
        body['resume_id'] = resumeId;
      }
      if (coverLetter != null && coverLetter.trim().isNotEmpty) {
        body['cover_letter'] = coverLetter.trim();
      }

      final response = await _apiService.postRequest(
        '/job-applications/apply',
        body,
      );
      debugPrint("APPLY FOR JOB RESPONSE: $response");
      return response;
    } catch (e) {
      debugPrint("APPLY FOR JOB ERROR: $e");
      return {
        'success': false,
        'message': 'Failed to submit job application: $e',
      };
    }
  }

  /// Fetch applications for a logged in user
  Future<List<JobApplicationModel>> getUserApplications(int userId) async {
    try {
      final response = await _apiService.getRequest('/job-applications/user/$userId');
      debugPrint("GET USER APPLICATIONS RESPONSE: $response");

      List<dynamic>? list;
      if (response['applications'] is List) {
        list = response['applications'];
      } else if (response['data'] is List) {
        list = response['data'];
      } else if (response['jobApplications'] is List) {
        list = response['jobApplications'];
      }

      if (list != null) {
        return list
            .map((json) => JobApplicationModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("GET USER APPLICATIONS ERROR: $e");
      return [];
    }
  }

  /// Withdraw an application
  Future<bool> withdrawApplication(int applicationId, int userId) async {
    try {
      final response = await _apiService.patchRequest(
        '/job-applications/$applicationId/withdraw',
        {'user_id': userId},
      );
      debugPrint("WITHDRAW APPLICATION RESPONSE: $response");
      return response['success'] == true;
    } catch (e) {
      debugPrint("WITHDRAW APPLICATION ERROR: $e");
      return false;
    }
  }

  /// Get current user's resume completion percentage via GET /api/resume
  Future<int?> getResumeCompletionPercentage() async {
    try {
      final response = await _apiService.getRequest('/resume');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        if (data['completion_percentage'] != null) {
          return (data['completion_percentage'] as num).toInt();
        }
      }
      return null;
    } catch (e) {
      debugPrint("GET RESUME COMPLETION ERROR: $e");
      return null;
    }
  }

  /// Validates if resume completion is >= 75%.
  /// If percentage < 75%, shows popup and returns false.
  /// If percentage API fails, shows error and returns false.
  /// If percentage >= 75%, returns true.
  Future<bool> validateResumeCompletion(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final completionPercent = await getResumeCompletionPercentage();

    if (context.mounted) {
      Navigator.pop(context);
    }

    if (completionPercent == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to verify resume completion. Please try again."),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }

    if (completionPercent < 75) {
      if (context.mounted) {
        _showIncompleteResumeDialog(context, completionPercent);
      }
      return false;
    }

    return true;
  }

  void _showIncompleteResumeDialog(BuildContext context, int percentage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Complete Your Resume",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            "Your resume is currently $percentage% complete. Please complete at least 75% of your resume before applying for this job.",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResumeUploadedPage(),
                  ),
                );
              },
              child: const Text(
                "Complete Resume",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


