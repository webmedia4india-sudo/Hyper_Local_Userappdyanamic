import 'job_model.dart';

class SavedJobModel {
  final int savedJobId;
  final int userId;
  final int jobPostId;
  final String? savedAt;
  final JobModel jobPost;

  SavedJobModel({
    required this.savedJobId,
    required this.userId,
    required this.jobPostId,
    this.savedAt,
    required this.jobPost,
  });

  factory SavedJobModel.fromJson(Map<String, dynamic> json) {
    final sId = json['saved_job_id'] is int
        ? json['saved_job_id'] as int
        : int.tryParse(json['saved_job_id']?.toString() ?? '0') ?? 0;

    final uId = json['user_id'] is int
        ? json['user_id'] as int
        : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0;

    final jpId = json['job_post_id'] is int
        ? json['job_post_id'] as int
        : (json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['job_post_id']?.toString() ?? json['id']?.toString() ?? '0') ?? 0);

    return SavedJobModel(
      savedJobId: sId,
      userId: uId,
      jobPostId: jpId,
      savedAt: json['saved_at']?.toString() ?? json['created_at']?.toString(),
      jobPost: JobModel.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saved_job_id': savedJobId,
      'user_id': userId,
      'job_post_id': jobPostId,
      'saved_at': savedAt,
      'job_post': jobPost.toJson(),
    };
  }
}
