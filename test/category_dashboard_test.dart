import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyper_local/models/category/category_model.dart';
import 'package:hyper_local/services/category_service.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';

// 1x1 transparent PNG
final Uint8List transparentPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=');

String mockCategoriesResponseJson = jsonEncode({
  'success': true,
  'categories': [
    {
      'id': 101,
      'title': 'Tech & Engineering',
      'subtitle': '42 Openings',
      'background_img': 'https://example.com/tech_bg.jpg',
      'icon_img': 'https://example.com/tech_icon.png',
    },
    {
      'id': 102,
      'title': 'Hospitality',
      'subtitle': '18 Openings',
      'background_img': null,
      'icon_img': null,
    },
  ]
});

int mockCategoriesStatusCode = 200;

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _TestHttpClient();
  }
}

class _TestHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}
  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}
  @override
  set authenticate(Future<bool> Function(Uri url, String scheme, String? realm)? f) {}
  @override
  set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String? realm)? f) {}
  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {}
  @override
  void close({bool force = false}) {}
  @override
  set findProxy(String Function(Uri url)? f) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _TestHttpClientRequest(url);
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _TestHttpClientRequest(url);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestHttpClientRequest implements HttpClientRequest {
  @override
  final Uri uri;
  _TestHttpClientRequest(this.uri);

  @override
  bool followRedirects = true;
  @override
  int maxRedirects = 5;
  @override
  bool persistentConnection = true;
  @override
  int contentLength = 0;
  @override
  bool bufferOutput = true;

  @override
  final HttpHeaders headers = _TestHttpHeaders();

  @override
  void add(List<int> data) {}

  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable objects, [String separator = ""]) {}

  @override
  void writeln([Object? object = ""]) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream<List<int>> stream) async => stream.drain();

  @override
  Future flush() async {}

  @override
  Future<HttpClientResponse> get done => close();

  @override
  Future<HttpClientResponse> close() async {
    final path = uri.path;
    if (uri.toString().endsWith('.png') ||
        uri.toString().endsWith('.jpg') ||
        uri.toString().contains('images.unsplash.com')) {
      return _TestHttpClientResponse(200, transparentPng);
    }

    if (path.contains('/categories')) {
      if (mockCategoriesStatusCode != 200) {
        return _TestHttpClientResponse(
          mockCategoriesStatusCode,
          utf8.encode(jsonEncode({'success': false, 'message': 'Internal Server Error'})),
        );
      }
      return _TestHttpClientResponse(200, utf8.encode(mockCategoriesResponseJson));
    }

    // Default response for banners, jobs, profile, etc.
    final defaultJson = jsonEncode({'success': true, 'data': [], 'banners': [], 'jobs': []});
    return _TestHttpClientResponse(200, utf8.encode(defaultJson));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  final int statusCode;
  final List<int> _bodyBytes;

  _TestHttpClientResponse(this.statusCode, this._bodyBytes);

  @override
  bool get isRedirect => false;

  @override
  String get reasonPhrase => 'OK';

  @override
  bool get persistentConnection => false;

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  List<Cookie> get cookies => const [];

  @override
  int get contentLength => _bodyBytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  final HttpHeaders headers = _TestHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(_bodyBytes).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = {};

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _headers.forEach(action);
  }

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers.putIfAbsent(name, () => []).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[name] = [value.toString()];
  }

  @override
  List<String>? operator [](String name) => _headers[name];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('CategoryModel Mapping & Parsing Tests', () {
    test('Correctly maps standard admin panel category fields', () {
      final json = {
        'id': 101,
        'title': 'Healthcare & Medical',
        'subtitle': '45 Openings',
        'background_img': '/uploads/medical_bg.jpg',
        'icon_img': '/uploads/medical_icon.png',
      };

      final cat = CategoryModel.fromJson(json);

      expect(cat.id, 101);
      expect(cat.title, 'Healthcare & Medical');
      expect(cat.subtitle, '45 Openings');
      expect(cat.backgroundImg, '/uploads/medical_bg.jpg');
      expect(cat.iconImg, '/uploads/medical_icon.png');
    });

    test('Correctly maps alternative admin panel fields (category_name, category_id, etc.)', () {
      final json = {
        'category_id': '202',
        'category_name': 'Information Technology',
        'openings': '120 Jobs Available',
        'bgImage': 'https://example.com/tech_bg.jpg',
        'icon': 'https://example.com/tech_icon.png',
      };

      final cat = CategoryModel.fromJson(json);

      expect(cat.id, 202);
      expect(cat.title, 'Information Technology');
      expect(cat.subtitle, '120 Jobs Available');
      expect(cat.backgroundImg, 'https://example.com/tech_bg.jpg');
      expect(cat.iconImg, 'https://example.com/tech_icon.png');
    });

    test('Handles missing optional fields gracefully', () {
      final json = {'id': 303, 'name': 'Finance'};
      final cat = CategoryModel.fromJson(json);

      expect(cat.id, 303);
      expect(cat.title, 'Finance');
      expect(cat.subtitle, isNull);
      expect(cat.backgroundImg, isNull);
      expect(cat.iconImg, isNull);
    });
  });

  group('CategoryService API Tests', () {
    test('Returns categories when API returns successful response', () async {
      mockCategoriesStatusCode = 200;
      mockCategoriesResponseJson = jsonEncode({
        'success': true,
        'categories': [
          {'id': 1, 'title': 'IT Jobs'},
          {'id': 2, 'title': 'Design Jobs'},
        ]
      });

      final service = CategoryService();
      final list = await service.getCategories();

      expect(list.length, 2);
      expect(list[0].id, 1);
      expect(list[0].title, 'IT Jobs');
      expect(list[1].id, 2);
      expect(list[1].title, 'Design Jobs');
    });

    test('Returns empty list when API returns empty categories list', () async {
      mockCategoriesStatusCode = 200;
      mockCategoriesResponseJson = jsonEncode({
        'success': true,
        'categories': [],
      });

      final service = CategoryService();
      final list = await service.getCategories();

      expect(list, isEmpty);
    });

    test('Throws exception when API returns error response', () async {
      mockCategoriesStatusCode = 500;
      final service = CategoryService();

      expect(() => service.getCategories(), throwsA(isA<Exception>()));
    });
  });

  group('Top Categories Dashboard Widget Integration Tests', () {
    testWidgets('Displays real categories when API provides them', (WidgetTester tester) async {
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        prevOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      mockCategoriesStatusCode = 200;
      mockCategoriesResponseJson = jsonEncode({
        'success': true,
        'categories': [
          {
            'id': 501,
            'title': 'Engineering',
            'subtitle': '30 Openings',
          },
          {
            'id': 502,
            'title': 'Marketing',
            'subtitle': '12 Openings',
          },
        ]
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify that Section header says "Top Categories"
      expect(find.text('Top Categories'), findsOneWidget);

      // Verify only real categories from API are displayed
      expect(find.text('Engineering'), findsOneWidget);
      expect(find.text('Marketing'), findsOneWidget);

      // Verify dummy categories are NOT present
      expect(find.text('Delivery & Courier'), findsNothing);
      expect(find.text('Retail & Store'), findsNothing);
      expect(find.text('Hotel & Hospitality'), findsNothing);
    });

    testWidgets('Displays "No Categories Found" when API returns empty list', (WidgetTester tester) async {
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        prevOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      mockCategoriesStatusCode = 200;
      mockCategoriesResponseJson = jsonEncode({
        'success': true,
        'categories': [],
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Top Categories'), findsOneWidget);
      expect(find.text('No Categories Found'), findsOneWidget);

      // No dummy categories should appear
      expect(find.text('Engineering'), findsNothing);
      expect(find.text('Delivery & Courier'), findsNothing);
      expect(find.text('Retail & Store'), findsNothing);
    });

    testWidgets('Displays error state with Retry button on API failure', (WidgetTester tester) async {
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        prevOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      mockCategoriesStatusCode = 500;

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Top Categories'), findsOneWidget);
      expect(find.text('Failed to load categories'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // No dummy categories should appear on failure
      expect(find.text('Delivery & Courier'), findsNothing);
    });
  });
}
