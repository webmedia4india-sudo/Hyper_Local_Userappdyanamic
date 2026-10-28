import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/job/saved_job_model.dart';

class SavedJobService {
  final ApiService _apiService = ApiService();

  /// Save a job for a user
  Future<Map<String, dynamic>> saveJob({
    required int userId,
    required int jobPostId,
  }) async {
    try {
      final response = await _apiService.postRequest(
        '/saved-jobs/add',
        {
          'user_id': userId,
          'job_post_id': jobPostId,
        },
      );
      return response;
    } catch (e) {
      debugPrint("SAVE JOB API ERROR: $e");
      return {
        'success': false,
        'message': 'Failed to save job: $e',
      };
    }
  }

  /// Fetch all saved jobs for a specific user
  Future<List<SavedJobModel>> getSavedJobsByUser(int userId) async {
    try {
      final response = await _apiService.getRequest('/saved-jobs/user/$userId');
      debugPrint("GET SAVED JOBS RESPONSE: $response");

      if (response['success'] == true && response['saved_jobs'] is List) {
        final List<dynamic> list = response['saved_jobs'];
        return list
            .map((json) => SavedJobModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("GET SAVED JOBS ERROR: $e");
      return [];
    }
  }

  /// Remove a saved job for a user
  Future<Map<String, dynamic>> deleteSavedJob({
    required int userId,
    required int jobPostId,
  }) async {
    try {
      final response = await _apiService.deleteRequest(
        '/saved-jobs/$jobPostId',
        body: {'user_id': userId},
      );
      return response;
    } catch (e) {
      debugPrint("DELETE SAVED JOB API ERROR: $e");
      return {
        'success': false,
        'message': 'Failed to remove saved job: $e',
      };
    }
  }
}
