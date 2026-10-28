import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/job/missed_opportunity_model.dart';

class MissedOpportunityService {
  final ApiService _apiService = ApiService();

  /// Fetch missed opportunities for a user by userId
  Future<Map<String, dynamic>> getMissedOpportunitiesByUser(int userId) async {
    try {
      var response = await _apiService.getRequest('/missed-opportunities/user/$userId');
      
      if (response['success'] != true && response['missed_opportunities'] == null) {
        response = await _apiService.getRequest('/missedOpportunity/user/$userId');
      }

      debugPrint("GET MISSED OPPORTUNITIES API RESPONSE: $response");

      if (response['success'] == true) {
        final List<dynamic> list = response['missed_opportunities'] ?? [];
        final items = list
            .map((json) => MissedOpportunityModel.fromJson(Map<String, dynamic>.from(json)))
            .where((m) => m.isWithinRetentionPeriod)
            .toList();

        return {
          'success': true,
          'totalCount': items.length,
          'items': items,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch missed opportunities',
          'totalCount': 0,
          'items': <MissedOpportunityModel>[],
        };
      }
    } catch (e) {
      debugPrint("GET MISSED OPPORTUNITIES ERROR: $e");
      return {
        'success': false,
        'message': 'Error loading missed opportunities: $e',
        'totalCount': 0,
        'items': <MissedOpportunityModel>[],
      };
    }
  }
}
