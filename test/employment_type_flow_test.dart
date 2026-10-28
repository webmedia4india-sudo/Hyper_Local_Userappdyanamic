import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_local/models/job/job_model.dart';
import 'package:hyper_local/models/job/recent_job_model.dart';

void main() {
  group('Employment Type and Part-Time Dashboard Flow Tests', () {
    test('JobModel.fromJson correctly parses Part-time and Full-time', () {
      final partTimeJson = {
        'id': 4,
        'job_title': 'Junior Flutter Assistant (Part-Time)',
        'company_name': 'TechHub Solutions',
        'employment_type': 'Part-time',
        'min_salary': 15000,
        'max_salary': 20000,
        'status': 'published',
      };

      final jobA = JobModel.fromJson(partTimeJson);
      expect(jobA.employmentType, equals('Part-time'));
      expect(jobA.isPartTime, isTrue);

      final fullTimeJson = {
        'id': 5,
        'job_title': 'Senior Flutter Architect (Full-Time)',
        'company_name': 'Apex Innovations',
        'employment_type': 'Full-time',
        'min_salary': 80000,
        'max_salary': 120000,
        'status': 'published',
      };

      final jobB = JobModel.fromJson(fullTimeJson);
      expect(jobB.employmentType, equals('Full-time'));
      expect(jobB.isPartTime, isFalse);
    });

    test('RecentJobModel.fromJson correctly parses Part-time and Full-time', () {
      final partTimeJson = {
        'id': 4,
        'job_title': 'Junior Flutter Assistant (Part-Time)',
        'company_name': 'TechHub Solutions',
        'employment_type': 'Part-time',
        'min_salary': 15000,
        'max_salary': 20000,
        'status': 'published',
      };

      final recentJobA = RecentJobModel.fromJson(partTimeJson, 0);
      expect(recentJobA.employmentType, equals('Part-time'));
      expect(recentJobA.isPartTime, isTrue);

      final mapA = recentJobA.toMap();
      expect(mapA['employmentType'], equals('Part-time'));
      expect(mapA['isPartTime'], isTrue);

      final fullTimeJson = {
        'id': 5,
        'job_title': 'Senior Flutter Architect (Full-Time)',
        'company_name': 'Apex Innovations',
        'employment_type': 'Full-time',
        'min_salary': 80000,
        'max_salary': 120000,
        'status': 'published',
      };

      final recentJobB = RecentJobModel.fromJson(fullTimeJson, 1);
      expect(recentJobB.employmentType, equals('Full-time'));
      expect(recentJobB.isPartTime, isFalse);

      final mapB = recentJobB.toMap();
      expect(mapB['employmentType'], equals('Full-time'));
      expect(mapB['isPartTime'], isFalse);
    });

    test('Dashboard part-time filter logic correctly isolates Part-time jobs', () {
      final recentJobs = [
        RecentJobModel.fromJson({
          'id': 4,
          'job_title': 'Junior Flutter Assistant (Part-Time)',
          'company_name': 'TechHub Solutions',
          'employment_type': 'Part-time',
          'min_salary': 15000,
          'max_salary': 20000,
          'status': 'published',
        }, 0),
        RecentJobModel.fromJson({
          'id': 5,
          'job_title': 'Senior Flutter Architect (Full-Time)',
          'company_name': 'Apex Innovations',
          'employment_type': 'Full-time',
          'min_salary': 80000,
          'max_salary': 120000,
          'status': 'published',
        }, 1),
      ];

      // Replicating dashboard getter logic
      final partTimeList = recentJobs
          .where((j) => j.isPartTime || (j.employmentType ?? '').toLowerCase().contains('part'))
          .map((j) => j.toMap())
          .toList();

      expect(partTimeList.length, equals(1));
      expect(partTimeList.first['id'], equals(4));
      expect(partTimeList.first['title'], contains('Part-Time'));
      expect(partTimeList.first['employmentType'], equals('Part-time'));
      expect(partTimeList.first['isPartTime'], isTrue);

      // Replicating recent jobs list logic (contains both)
      final allRecentList = recentJobs.map((j) => j.toMap()).toList();
      expect(allRecentList.length, equals(2));
      expect(allRecentList.any((j) => j['id'] == 4), isTrue);
      expect(allRecentList.any((j) => j['id'] == 5), isTrue);
    });
  });
}
