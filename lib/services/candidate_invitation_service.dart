import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/job/candidate_invitation_model.dart';

class CandidateInvitationService {
  final ApiService _apiService = ApiService();

  /// GET /api/candidate-invitations/candidate/:candidateId
  Future<List<CandidateInvitationModel>> getCandidateInvitations(
      int candidateId) async {
    try {
      final response = await _apiService.getRequest(
        '/candidate-invitations/candidate/$candidateId',
      );

      if (response['success'] == true) {
        final rawData = response['data'];
        if (rawData is List) {
          return rawData
              .map((item) => CandidateInvitationModel.fromJson(
                  Map<String, dynamic>.from(item)))
              .toList();
        }
        return [];
      } else {
        throw Exception(
            response['message'] ?? 'Failed to fetch candidate invitations');
      }
    } catch (e) {
      debugPrint('Error fetching candidate invitations: $e');
      rethrow;
    }
  }

  /// PATCH /api/candidate-invitations/:id/respond
  Future<bool> respondToInvitation({
    required int invitationId,
    required int candidateId,
    required String status, // 'accepted' or 'rejected'
  }) async {
    try {
      final response = await _apiService.patchRequest(
        '/candidate-invitations/$invitationId/respond',
        {
          'candidate_id': candidateId,
          'status': status,
        },
      );

      if (response['success'] == true) {
        return true;
      } else {
        throw Exception(
            response['message'] ?? 'Failed to update invitation status');
      }
    } catch (e) {
      debugPrint('Error responding to invitation: $e');
      rethrow;
    }
  }
}
