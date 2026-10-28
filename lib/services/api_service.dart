import 'dart:convert';
import 'dart:typed_data' show Uint8List;
import 'package:http/http.dart' as http;
import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../utils/session_manager.dart';

class ApiService {
  // Android Emulator साठी
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5000/api";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:5000/api"; // Android emulator
    } else {
      return "http://localhost:5000/api"; // iOS simulator / desktop
    }
  }


//  static String get baseUrl {
//     if (kIsWeb) {
//       return 'https://api.hihr.app/api';
//     } else if (Platform.isAndroid) {
//       return  'https://api.hihr.app/api'; // Android emulator
//     } else {
//       return  'https://api.hihr.app/api'; // iOS simulator / desktop
//     }
//   }
  /// Dynamic headers with Bearer Token if logged in
 Future<Map<String, String>> _getHeaders({bool isJson = true}) async {
  final token = await SessionManager.getToken();
  print('DEBUG TOKEN: $token'); // 👈 he temporary add kar
  final headers = <String, String>{
    'Accept': 'application/json',
    if (isJson) 'Content-Type': 'application/json',
  };
  if (token != null && token.isNotEmpty) {
    headers['Authorization'] = 'Bearer $token';
  }
  return headers;
}

  Future<Map<String, dynamic>> getRequest(String endpoint) async {
    try {
      final url = '$baseUrl$endpoint';
      print('==============================');
      print('API GET URL: $url');
      print('==============================');

      final headers = await _getHeaders(isJson: false);
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print('JSON PARSE ERROR: $e');
        return {
          'success': false,
          'message':
              'Endpoint sapadla nahi ki server madhe error ahe (status ${response.statusCode}). URL check kara: $url',
        };
      }

      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      print('API ERROR: $e');
      return {
        'success': false,
        'message': 'Something went wrong: $e',
      };
    }
  }

  Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = '$baseUrl$endpoint';

      print('==============================');
      print('API URL: $url');
      print('REQUEST BODY: $body');
      print('==============================');

      final headers = await _getHeaders(isJson: true);
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print('JSON PARSE ERROR: $e');
        return {
          'success': false,
          'message':
              'Endpoint sapadla nahi ki server madhe error ahe (status ${response.statusCode}). URL check kara: $url',
        };
      }

      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      print('API ERROR: $e');

      return {
        'success': false,
        'message': 'Something went wrong: $e',
      };
    }
  }

  Future<Map<String, dynamic>> putRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = '$baseUrl$endpoint';

      print('==============================');
      print('API PUT URL: $url');
      print('REQUEST BODY: $body');
      print('==============================');

      final headers = await _getHeaders(isJson: true);
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print('JSON PARSE ERROR: $e');
        return {
          'success': false,
          'message':
              'Endpoint sapadla nahi ki server madhe error ahe (status ${response.statusCode}). URL check kara: $url',
        };
      }

      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      print('API ERROR: $e');
      return {
        'success': false,
        'message': 'Something went wrong: $e',
      };
    }
  }

  Future<Map<String, dynamic>> patchRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = '$baseUrl$endpoint';

      print('==============================');
      print('API PATCH URL: $url');
      print('REQUEST BODY: $body');
      print('==============================');

      final headers = await _getHeaders(isJson: true);
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print('JSON PARSE ERROR: $e');
        return {
          'success': false,
          'message':
              'Endpoint sapadla nahi ki server madhe error ahe (status ${response.statusCode}). URL check kara: $url',
        };
      }

      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      print('API ERROR: $e');
      return {
        'success': false,
        'message': 'Something went wrong: $e',
      };
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required String fileField,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('==============================');
      print('API MULTIPART POST URL: $url');
      print('FIELDS: $fields');
      print('==============================');

      final headers = await _getHeaders(isJson: false);
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      if (fileBytes != null && fileBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: fileName ?? 'profile_photo.jpg',
          ),
        );
      } else if (file != null && !kIsWeb) {
        request.files.add(
          await http.MultipartFile.fromPath(fileField, file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print('JSON PARSE ERROR: $e');
        return {
          'success': false,
          'message': 'JSON parse error (status ${response.statusCode})',
        };
      }

      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      print('API MULTIPART ERROR: $e');
      return {
        'success': false,
        'message': 'Something went wrong: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteRequest(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final url = '$baseUrl$endpoint';
      print('==============================');
      print('API DELETE URL: $url');
      if (body != null) print('DELETE BODY: $body');
      print('==============================');

      final headers = await _getHeaders(isJson: body != null);
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print('JSON PARSE ERROR: $e');
        return {
          'success': false,
          'message':
              'Endpoint sapadla nahi ki server madhe error ahe (status ${response.statusCode}). URL check kara: $url',
        };
      }

      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      print('API ERROR: $e');
      return {
        'success': false,
        'message': 'Something went wrong: $e',
      };
    }
  }

  Future<Map<String, dynamic>?> getNearbyJobsCount(
    double lat,
    double lng, {
    double radius = 10,
  }) async {
    try {
      final url = '$baseUrl/jobpost/nearby-count?lat=$lat&lng=$lng&radius=$radius';
      final headers = await _getHeaders(isJson: false);
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 5));

      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting nearby jobs count: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getNearbyJobs(
    double lat,
    double lng, {
    double radius = 50,
    int? cityId,
  }) async {
    try {
      String url = '$baseUrl/jobpost/nearby?lat=$lat&lng=$lng&radius=$radius';
      if (cityId != null && cityId > 0) {
        url += '&city_id=$cityId';
      }
      final headers = await _getHeaders(isJson: false);
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else if (decoded is List) {
          return {'success': true, 'data': decoded};
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting nearby jobs: $e');
      return null;
    }
  }

  /// Update job promotion settings (is_featured, is_premium, is_urgent_hiring, is_walk_in_interview, etc.)
  Future<Map<String, dynamic>> updateJobPromotions(
    int jobId,
    Map<String, dynamic> promotions,
  ) async {
    try {
      final url = '$baseUrl/jobpost/$jobId/promotions';
      final headers = await _getHeaders(isJson: true);
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(promotions),
      );
      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'success': response.statusCode >= 200 && response.statusCode < 300};
    } catch (e) {
      debugPrint('updateJobPromotions error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}