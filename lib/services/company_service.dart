import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/company/company_model.dart';

class CompanyService {
  final ApiService _apiService = ApiService();

  /// GET /api/company-profiles — Fetches dynamically registered companies
  Future<List<CompanyModel>> getCompanies() async {
    try {
      var response = await _apiService.getRequest('/company-profiles');

      // Fallback to /employee/companies if needed
      if (response['success'] != true || response['companies'] == null) {
        response = await _apiService.getRequest('/employee/companies');
      }

      final bool isSuccess = response['success'] == true ||
          response['status'] == true ||
          response['status'] == 200 ||
          response['companies'] is List;

      if (isSuccess && response['companies'] != null) {
        final list = response['companies'];
        if (list is List) {
          return list
              .map((item) =>
                  CompanyModel.fromJson(Map<String, dynamic>.from(item)))
              .where((c) => c.businessName.isNotEmpty)
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error in CompanyService.getCompanies: $e");
      try {
        final fallbackRes = await _apiService.getRequest('/employee/companies');
        if (fallbackRes['companies'] is List) {
          final list = fallbackRes['companies'] as List;
          return list
              .map((item) =>
                  CompanyModel.fromJson(Map<String, dynamic>.from(item)))
              .where((c) => c.businessName.isNotEmpty)
              .toList();
        }
      } catch (e2) {
        debugPrint("CompanyService fallback failed: $e2");
      }
      return [];
    }
  }
}
