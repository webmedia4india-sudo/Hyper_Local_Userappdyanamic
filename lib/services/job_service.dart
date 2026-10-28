import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/job/job_model.dart';

class JobService {
  final ApiService _apiService = ApiService();

  // GET /api/jobpost/public or /api/jobs -> Fetch all active/published jobs
  Future<List<JobModel>> getJobs({int? cityId}) async {
    try {
      final queryParam = (cityId != null && cityId > 0) ? '?city_id=$cityId' : '';
      var response = await _apiService.getRequest('/jobpost/public$queryParam');
      if (response['jobPosts'] == null && response['data'] == null && response['jobs'] == null) {
        response = await _apiService.getRequest('/jobs$queryParam');
      }
      debugPrint("JOB API RESPONSE: $response");

      List<dynamic>? dataList;
      if (response['jobPosts'] is List) {
        dataList = response['jobPosts'];
      } else if (response['data'] is List) {
        dataList = response['data'];
      } else if (response['jobs'] is List) {
        dataList = response['jobs'];
      }

      if (dataList != null) {
        var list = dataList
            .map((json) => JobModel.fromJson(Map<String, dynamic>.from(json)))
            .where((job) {
              final s = job.status.toLowerCase().trim();
              return s == 'active' || s == 'published' || s.isEmpty;
            });

        if (cityId != null && cityId > 0) {
          list = list.where((job) => job.cityId == cityId);
        }

        return list.toList();
      }
      return [];
    } catch (e) {
      debugPrint("GET JOBS ERROR: $e");
      return [];
    }
  }

  // GET /api/jobpost/GetById/:id or /api/jobs/:id -> Fetch single job details
  Future<JobModel?> getJobById(int id) async {
    try {
      var response = await _apiService.getRequest('/jobpost/GetById/$id');
      if (response['jobPost'] == null && response['data'] == null) {
        response = await _apiService.getRequest('/jobs/$id');
      }
      if (response['jobPost'] is Map) {
        return JobModel.fromJson(Map<String, dynamic>.from(response['jobPost']));
      } else if (response['data'] is Map) {
        return JobModel.fromJson(Map<String, dynamic>.from(response['data']));
      }
      return null;
    } catch (e) {
      debugPrint("GET JOB BY ID ERROR: $e");
      return null;
    }
  }
}
