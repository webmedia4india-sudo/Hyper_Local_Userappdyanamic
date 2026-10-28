import 'dart:io';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/banner/banner_model.dart';

class BannerService {
  final ApiService _apiService = ApiService();

  // GET /api/banners  → Flutter dashboard sathi (active banners)
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _apiService.getRequest('/banners');

      if (response['success'] == true && response['banners'] != null) {
        final List<dynamic> data = response['banners'];
        return data
            .map((json) => BannerModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // GET /api/banners/all  → Admin panel sathi (active + inactive)
 Future<List<BannerModel>> getAllBanners() async {
  try {
    final response =
        await _apiService.getRequest('/banners/getall');

    debugPrint("BANNER API RESPONSE: $response");

    if (response['success'] == true &&
        response['banners'] != null) {
      
      final List<dynamic> data = response['banners'];

      return data
          .map(
            (json) => BannerModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    }

    return [];
  } catch (e) {
    debugPrint("GET ALL BANNERS ERROR: $e");
    return [];
  }
}

  // POST /api/banners  → naveen banner create (image sह)
  Future<Map<String, dynamic>> createBanner({
    required String title,
    String? subtitle,
    String? tag,
    String? buttonText,
    String? redirectType,
    String? redirectValue,
    int sortOrder = 0,
    required File imageFile,
  }) async {
    try {
      final fields = {
        'title': title,
        'subtitle': ?subtitle,
        'tag': ?tag,
        'button_text': ?buttonText,
        'redirect_type': ?redirectType,
        'redirect_value': ?redirectValue,
        'sort_order': sortOrder.toString(),
      };

      final response = await _apiService.postMultipart(
        '/banners',
        fields: fields,
        fileField: 'image',
        file: imageFile,
      );

      return response;
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong: $e'};
    }
  }

  // DELETE /api/banners/:id  → banner delete
  Future<bool> deleteBanner(int id) async {
    try {
      final response = await _apiService.deleteRequest('/banners/$id');
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
}