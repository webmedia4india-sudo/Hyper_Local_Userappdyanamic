import 'package:flutter/material.dart';
import '../models/job/job_model.dart';
import '../services/job_service.dart';

class JobController extends ChangeNotifier {
  final JobService _jobService = JobService();

  List<JobModel> jobs = [];
  List<JobModel> filteredJobs = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  String selectedJobType = 'All';

  Future<void> loadJobs({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final fetched = await _jobService.getJobs();
      jobs = fetched;
      applyFilters();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("JobController loadJobs error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    searchQuery = query;
    applyFilters();
    notifyListeners();
  }

  void setJobType(String jobType) {
    selectedJobType = jobType;
    applyFilters();
    notifyListeners();
  }

  void applyFilters() {
    List<JobModel> result = [...jobs];

    // Filter by Job Type
    if (selectedJobType != 'All') {
      result = result.where((j) =>
        (j.jobTypeId ?? '').toLowerCase() == selectedJobType.toLowerCase()
      ).toList();
    }

    // Filter by Search Query
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      result = result.where((job) {
        final titleMatch = job.title.toLowerCase().contains(q);
        final companyMatch = job.companyName.toLowerCase().contains(q);
        final locMatch = (job.location ?? '').toLowerCase().contains(q);
        final skillsMatch = job.skills.any((s) => s.toLowerCase().contains(q));
        final typeMatch = (job.jobTypeId ?? '').toLowerCase().contains(q);
        return titleMatch || companyMatch || locMatch || skillsMatch || typeMatch;
      }).toList();
    }

    filteredJobs = result;
  }
}
