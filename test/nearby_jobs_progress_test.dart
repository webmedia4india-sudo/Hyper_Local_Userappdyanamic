import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Nearby Jobs Progress Calculation Tests', () {
    // Formula under test:
    // progressPercentage = min(availableJobsCount * 10, 100)
    // progressValue = (progressPercentage / 100.0).clamp(0.0, 1.0)
    // progressText = "$progressPercentage%"
    Map<String, dynamic> calculateNearbyJobsProgress(int availableJobsCount) {
      final int nearbyPct = math.min(availableJobsCount * 10, 100).clamp(0, 100);
      final double nearbyProg = (nearbyPct / 100.0).clamp(0.0, 1.0);
      return {
        'count': availableJobsCount,
        'percentage': nearbyPct,
        'value': nearbyProg,
        'text': '$nearbyPct%',
      };
    }

    test('0-job scenario: returns 0%, progress 0.0 (empty bar)', () {
      final res = calculateNearbyJobsProgress(0);
      expect(res['percentage'], equals(0));
      expect(res['value'], equals(0.0));
      expect(res['text'], equals('0%'));
    });

    test('1-job scenario: returns 10%, progress 0.1', () {
      final res = calculateNearbyJobsProgress(1);
      expect(res['percentage'], equals(10));
      expect(res['value'], equals(0.1));
      expect(res['text'], equals('10%'));
    });

    test('2-job scenario: returns 20%, progress 0.2', () {
      final res = calculateNearbyJobsProgress(2);
      expect(res['percentage'], equals(20));
      expect(res['value'], equals(0.2));
      expect(res['text'], equals('20%'));
    });

    test('3-job scenario: returns 30%, progress 0.3', () {
      final res = calculateNearbyJobsProgress(3);
      expect(res['percentage'], equals(30));
      expect(res['value'], equals(0.3));
      expect(res['text'], equals('30%'));
    });

    test('4-job scenario: returns 40%, progress 0.4', () {
      final res = calculateNearbyJobsProgress(4);
      expect(res['percentage'], equals(40));
      expect(res['value'], equals(0.4));
      expect(res['text'], equals('40%'));
    });

    test('5-job scenario: returns 50%, progress 0.5', () {
      final res = calculateNearbyJobsProgress(5);
      expect(res['percentage'], equals(50));
      expect(res['value'], equals(0.5));
      expect(res['text'], equals('50%'));
    });

    test('10-job scenario: returns 100%, progress 1.0', () {
      final res = calculateNearbyJobsProgress(10);
      expect(res['percentage'], equals(100));
      expect(res['value'], equals(1.0));
      expect(res['text'], equals('100%'));
    });

    test('Over 10 jobs (15 jobs): clamps to 100%, progress 1.0', () {
      final res = calculateNearbyJobsProgress(15);
      expect(res['percentage'], equals(100));
      expect(res['value'], equals(1.0));
      expect(res['text'], equals('100%'));
    });

    test('City filtering: only counts jobs matching selected city_id', () {
      final rawJobs = [
        {'id': 1, 'job_title': 'Job 1', 'city_id': 357},
        {'id': 2, 'job_title': 'Job 2', 'city_id': 1}, // Different city
        {'id': 3, 'job_title': 'Job 3', 'city_id': 357},
        {'id': 4, 'job_title': 'Job 4', 'city_id': 357},
        {'id': 5, 'job_title': 'Job 5', 'city_id': 999}, // Different city
      ];

      const int selectedCityId = 357;
      final parsedJobs = rawJobs.where((item) {
        final jobCityId = item['city_id'];
        final parsedJobCityId = jobCityId is int
            ? jobCityId
            : int.tryParse(jobCityId?.toString() ?? '');
        return parsedJobCityId == selectedCityId;
      }).toList();

      expect(parsedJobs.length, equals(3));
      final res = calculateNearbyJobsProgress(parsedJobs.length);
      expect(res['percentage'], equals(30));
      expect(res['value'], equals(0.3));
      expect(res['text'], equals('30%'));
    });
  });

  group('Nearby Jobs Card Widget Tests (0, 1, 3, 10 jobs)', () {
    Widget buildCardTestWidget({
      required double progressValue,
      required String progressText,
      required String locationName,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nearby Jobs"),
                      Text("In $locationName"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Progress"),
                          Text(
                            progressText,
                            key: const ValueKey("nearby_jobs_progress_text"),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                        width: double.infinity,
                        child: FractionallySizedBox(
                          key: const ValueKey("nearby_jobs_progress_bar"),
                          alignment: Alignment.centerLeft,
                          widthFactor: progressValue,
                          child: Container(color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('0-job UI test: displays 0% and empty progress bar (widthFactor 0.0)', (tester) async {
      final res = math.min(0 * 10, 100);
      final double progressVal = (res / 100.0).clamp(0.0, 1.0);
      final String progressTxt = "$res%";

      await tester.pumpWidget(buildCardTestWidget(
        progressValue: progressVal,
        progressText: progressTxt,
        locationName: "Amravati",
      ));

      final textFinder = find.byKey(const ValueKey("nearby_jobs_progress_text"));
      expect(textFinder, findsOneWidget);
      expect(tester.widget<Text>(textFinder).data, equals("0%"));

      final barFinder = find.byKey(const ValueKey("nearby_jobs_progress_bar"));
      expect(barFinder, findsOneWidget);
      expect(tester.widget<FractionallySizedBox>(barFinder).widthFactor, equals(0.0));
    });

    testWidgets('1-job UI test: displays 10% and progress bar widthFactor 0.1', (tester) async {
      final res = math.min(1 * 10, 100);
      final double progressVal = (res / 100.0).clamp(0.0, 1.0);
      final String progressTxt = "$res%";

      await tester.pumpWidget(buildCardTestWidget(
        progressValue: progressVal,
        progressText: progressTxt,
        locationName: "Pune",
      ));

      final textFinder = find.byKey(const ValueKey("nearby_jobs_progress_text"));
      expect(textFinder, findsOneWidget);
      expect(tester.widget<Text>(textFinder).data, equals("10%"));

      final barFinder = find.byKey(const ValueKey("nearby_jobs_progress_bar"));
      expect(barFinder, findsOneWidget);
      expect(tester.widget<FractionallySizedBox>(barFinder).widthFactor, equals(0.1));
    });

    testWidgets('3-job UI test: displays 30% and progress bar widthFactor 0.3', (tester) async {
      final res = math.min(3 * 10, 100);
      final double progressVal = (res / 100.0).clamp(0.0, 1.0);
      final String progressTxt = "$res%";

      await tester.pumpWidget(buildCardTestWidget(
        progressValue: progressVal,
        progressText: progressTxt,
        locationName: "Nagpur",
      ));

      final textFinder = find.byKey(const ValueKey("nearby_jobs_progress_text"));
      expect(textFinder, findsOneWidget);
      expect(tester.widget<Text>(textFinder).data, equals("30%"));

      final barFinder = find.byKey(const ValueKey("nearby_jobs_progress_bar"));
      expect(barFinder, findsOneWidget);
      expect(tester.widget<FractionallySizedBox>(barFinder).widthFactor, equals(0.3));
    });

    testWidgets('10-job UI test: displays 100% and progress bar widthFactor 1.0', (tester) async {
      final res = math.min(10 * 10, 100);
      final double progressVal = (res / 100.0).clamp(0.0, 1.0);
      final String progressTxt = "$res%";

      await tester.pumpWidget(buildCardTestWidget(
        progressValue: progressVal,
        progressText: progressTxt,
        locationName: "Mumbai",
      ));

      final textFinder = find.byKey(const ValueKey("nearby_jobs_progress_text"));
      expect(textFinder, findsOneWidget);
      expect(tester.widget<Text>(textFinder).data, equals("100%"));

      final barFinder = find.byKey(const ValueKey("nearby_jobs_progress_bar"));
      expect(barFinder, findsOneWidget);
      expect(tester.widget<FractionallySizedBox>(barFinder).widthFactor, equals(1.0));
    });
  });
}
