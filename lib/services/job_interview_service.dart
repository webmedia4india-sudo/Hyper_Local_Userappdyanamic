import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/job/job_interview_model.dart';

class JobInterviewService {
  final ApiService _apiService = ApiService();

  /// GET /api/job-interviews/my-interviews
  /// Fetch all interviews for the currently authenticated candidate
  Future<List<JobInterviewModel>> getMyInterviews() async {
    try {
      final response = await _apiService.getRequest('/job-interviews/my-interviews');
      debugPrint('GET MY INTERVIEWS RESPONSE: $response');

      if (response['success'] == true) {
        final rawData = response['data'];
        if (rawData is List) {
          return rawData
              .map((item) => JobInterviewModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
        return [];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch candidate interviews');
      }
    } catch (e) {
      debugPrint('Error fetching my interviews: $e');
      rethrow;
    }
  }

  /// GET /api/job-interviews/:interviewId
  Future<JobInterviewModel?> getInterviewDetails(int interviewId) async {
    try {
      final response = await _apiService.getRequest('/job-interviews/$interviewId');
      if (response['success'] == true && response['data'] != null) {
        return JobInterviewModel.fromJson(Map<String, dynamic>.from(response['data']));
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching interview details: $e');
      return null;
    }
  }

  /// GET /api/job-interviews/application/:applicationId
  Future<JobInterviewModel?> getInterviewByApplicationId(int applicationId) async {
    try {
      final response = await _apiService.getRequest('/job-interviews/application/$applicationId');
      if (response['success'] == true && response['data'] != null) {
        return JobInterviewModel.fromJson(Map<String, dynamic>.from(response['data']));
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching interview by application ID: $e');
      return null;
    }
  }

  /// PATCH /api/job-interviews/:interviewId/respond
  /// Candidate accepts or rejects interview invitation
  Future<Map<String, dynamic>> respondToInterview({
    required int interviewId,
    required String responseStatus, // 'accepted' or 'rejected'
    String? remark,
  }) async {
    try {
      final payload = {
        'response_status': responseStatus,
        if (remark != null && remark.trim().isNotEmpty) 'remark': remark.trim(),
      };

      final response = await _apiService.patchRequest(
        '/job-interviews/$interviewId/respond',
        payload,
      );

      debugPrint('RESPOND TO INTERVIEW RESPONSE: $response');
      if (response['success'] == true) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Failed to update interview response');
      }
    } catch (e) {
      debugPrint('Error responding to interview: $e');
      rethrow;
    }
  }

  /// PATCH /api/job-interviews/:interviewId/cancel
  Future<Map<String, dynamic>> cancelInterview({
    required int interviewId,
    required String reason,
  }) async {
    try {
      final payload = {'remark': reason};
      final response = await _apiService.patchRequest(
        '/job-interviews/$interviewId/cancel',
        payload,
      );
      debugPrint('CANCEL INTERVIEW RESPONSE: $response');
      if (response['success'] == true) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Failed to cancel interview');
      }
    } catch (e) {
      debugPrint('Error cancelling interview: $e');
      rethrow;
    }
  }

  /// PATCH /api/job-interviews/:interviewId/reschedule
  Future<Map<String, dynamic>> rescheduleInterview({
    required int interviewId,
    required String proposedDate,
    required String proposedTime,
    String? remark,
    String? interviewMode,
    String? venue,
    String? meetingLink,
  }) async {
    try {
      final payload = {
        'interviewDate': proposedDate,
        'interviewTime': proposedTime,
        'interviewMode': interviewMode ?? 'offline',
        if (venue != null && venue.isNotEmpty) 'venue': venue,
        if (meetingLink != null && meetingLink.isNotEmpty) 'meetingLink': meetingLink,
        if (remark != null && remark.isNotEmpty) 'remark': remark,
      };
      final response = await _apiService.patchRequest(
        '/job-interviews/$interviewId/reschedule',
        payload,
      );
      debugPrint('RESCHEDULE INTERVIEW RESPONSE: $response');
      if (response['success'] == true) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Failed to reschedule interview');
      }
    } catch (e) {
      debugPrint('Error rescheduling interview: $e');
      rethrow;
    }
  }
}
