import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/saved_job_service.dart';
import '../models/job/saved_job_model.dart';
import 'session_manager.dart';

class SavedJobsManager {
  static const String _savedJobsKey = 'saved_user_jobs';
  static final SavedJobService _savedJobService = SavedJobService();

  static final List<Map<String, dynamic>> defaultSavedJobs = [
    {
      "id": 101,
      "job_post_id": 101,
      "title": "Frontend Developer",
      "company": "Infosys",
      "distance": "3.2 km",
      "rating": 4.4,
      "salary": "₹35,000 - ₹50,000",
      "logoText": "I",
      "logoColor": 0xFF007CC3,
    },
    {
      "id": 102,
      "job_post_id": 102,
      "title": "Backend Developer",
      "company": "TCS",
      "distance": "2.9 km",
      "rating": 4.2,
      "salary": "₹38,000 - ₹55,000",
      "logoText": "T",
      "logoColor": 0xFF0F62FE,
    },
    {
      "id": 103,
      "job_post_id": 103,
      "title": "Flutter Developer",
      "company": "Zoho Corporation",
      "distance": "1.8 km",
      "rating": 4.6,
      "salary": "₹40,000 - ₹60,000",
      "logoText": "Z",
      "logoColor": 0xFFE23744,
    },
    {
      "id": 104,
      "job_post_id": 104,
      "title": "Full Stack Developer",
      "company": "Wipro",
      "distance": "4.1 km",
      "rating": 4.1,
      "salary": "₹45,000 - ₹65,000",
      "logoText": "W",
      "logoColor": 0xFF341E5F,
    },
  ];

  /// Get saved jobs (from API if user is logged in, else local/default storage)
  static Future<List<Map<String, dynamic>>> getSavedJobs() async {
    try {
      final userDetails = await SessionManager.getUserDetails();
      final int? userId = userDetails['id'];

      if (userId != null && userId > 0) {
        final List<SavedJobModel> apiSavedJobs =
            await _savedJobService.getSavedJobsByUser(userId);

        final mapped = apiSavedJobs.map((sj) {
          final job = sj.jobPost;
          return {
            "id": sj.jobPostId,
            "job_post_id": sj.jobPostId,
            "saved_job_id": sj.savedJobId,
            "title": job.title,
            "company": job.companyName,
            "companyFullName": "${job.companyName} Pvt. Ltd.",
            "distance": job.formattedDistance,
            "rating": job.displayRating,
            "reviewCount": job.displayReviewCount,
            "salary": job.formattedSalary,
            "experience": job.experienceRequired ?? "1-2 years",
            "logoText": job.logoLetter,
            "logoColor": job.logoColor.toARGB32(),
            "skills": job.skills,
            "description": job.description ?? "",
            "totalVacancies": job.totalVacancies,
            "remainingVacancies": job.remainingVacancies,
            "postedDate": job.formattedPostedDate,
          };
        }).toList();

        // Save in prefs for offline caching
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_savedJobsKey, jsonEncode(mapped));
        return mapped;
      }
    } catch (e) {
      debugPrint("Error fetching saved jobs from API: $e");
    }

    // Fallback for guest user or network error
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_savedJobsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return List<Map<String, dynamic>>.from(defaultSavedJobs);
  }

  /// Check if a job is saved (supports checking by jobPostId or title+company)
  static Future<bool> isJobSaved(String title, String company, {int? jobPostId}) async {
    final jobs = await getSavedJobs();
    if (jobPostId != null && jobPostId > 0) {
      final found = jobs.any((j) {
        final idVal = j['id'] ?? j['job_post_id'];
        return idVal != null && (idVal == jobPostId || idVal.toString() == jobPostId.toString());
      });
      if (found) return true;
    }
    return jobs.any((j) =>
        (j['title']?.toString().toLowerCase() == title.toLowerCase()) &&
        (j['company']?.toString().toLowerCase() == company.toLowerCase()));
  }

  /// Toggle saving a job (calls API if logged in, updates local storage, returns new boolean state)
  static Future<bool> toggleSaveJob(Map<String, dynamic> job, {int? jobPostId}) async {
    final userDetails = await SessionManager.getUserDetails();
    final int? userId = userDetails['id'];
    final int? idToUse = jobPostId ?? (job['id'] is int ? job['id'] : int.tryParse(job['id']?.toString() ?? ''));

    final String title = job['title']?.toString() ?? '';
    final String company = job['company']?.toString() ?? '';

    bool currentlySaved = await isJobSaved(title, company, jobPostId: idToUse);
    bool nextSavedState = !currentlySaved;

    if (userId != null && userId > 0 && idToUse != null && idToUse > 0) {
      if (currentlySaved) {
        await _savedJobService.deleteSavedJob(userId: userId, jobPostId: idToUse);
      } else {
        await _savedJobService.saveJob(userId: userId, jobPostId: idToUse);
      }
    }

    final prefs = await SharedPreferences.getInstance();

    if (userId != null && userId > 0) {
      await getSavedJobs();
    } else {
      final jobs = await getSavedJobs();
      final index = jobs.indexWhere((j) {
        if (idToUse != null && idToUse > 0) {
          final jId = j['id'] ?? j['job_post_id'];
          if (jId != null && (jId == idToUse || jId.toString() == idToUse.toString())) return true;
        }
        return (j['title']?.toString().toLowerCase() == title.toLowerCase()) &&
            (j['company']?.toString().toLowerCase() == company.toLowerCase());
      });

      if (currentlySaved && index >= 0) {
        jobs.removeAt(index);
      } else if (!currentlySaved && index < 0) {
        jobs.insert(0, job);
      }
      await prefs.setString(_savedJobsKey, jsonEncode(jobs));
    }

    return nextSavedState;
  }

  /// Explicitly save a job
  static Future<void> saveJob(Map<String, dynamic> job, {int? jobPostId}) async {
    final userDetails = await SessionManager.getUserDetails();
    final int? userId = userDetails['id'];
    final int? idToUse = jobPostId ?? (job['id'] is int ? job['id'] : int.tryParse(job['id']?.toString() ?? ''));

    if (userId != null && userId > 0 && idToUse != null && idToUse > 0) {
      await _savedJobService.saveJob(userId: userId, jobPostId: idToUse);
      await getSavedJobs();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final jobs = await getSavedJobs();
      final String title = job['title']?.toString() ?? '';
      final String company = job['company']?.toString() ?? '';

      final index = jobs.indexWhere((j) =>
          (j['title']?.toString().toLowerCase() == title.toLowerCase()) &&
          (j['company']?.toString().toLowerCase() == company.toLowerCase()));

      if (index < 0) {
        jobs.insert(0, job);
      } else {
        jobs[index] = job;
      }
      await prefs.setString(_savedJobsKey, jsonEncode(jobs));
    }
  }

  /// Remove a saved job
  static Future<void> removeSavedJob(String title, String company, {int? jobPostId}) async {
    final userDetails = await SessionManager.getUserDetails();
    final int? userId = userDetails['id'];
    final int? idToUse = jobPostId;

    if (userId != null && userId > 0 && idToUse != null && idToUse > 0) {
      await _savedJobService.deleteSavedJob(userId: userId, jobPostId: idToUse);
      await getSavedJobs();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final jobs = await getSavedJobs();
      jobs.removeWhere((j) {
        if (idToUse != null && idToUse > 0) {
          final jId = j['id'] ?? j['job_post_id'];
          if (jId != null && (jId == idToUse || jId.toString() == idToUse.toString())) return true;
        }
        return (j['title']?.toString().toLowerCase() == title.toLowerCase()) &&
            (j['company']?.toString().toLowerCase() == company.toLowerCase());
      });
      await prefs.setString(_savedJobsKey, jsonEncode(jobs));
    }
  }
}
