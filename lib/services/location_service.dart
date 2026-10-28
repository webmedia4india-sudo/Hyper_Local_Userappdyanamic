import 'api_service.dart';
import '../models/location/city_model.dart';

class LocationService {
  final ApiService _apiService = ApiService();
  static List<CityModel>? _cachedCities;

  /// GET /api/location/cities — Fetch available cities from backend
  Future<List<CityModel>> getCities({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCities != null && _cachedCities!.isNotEmpty) {
      return _cachedCities!;
    }

    final response = await _apiService.getRequest('/location/cities');

    final bool isSuccess = response['success'] == true ||
        response['status'] == true ||
        response['status'] == 200 ||
        response['status'] == 'success' ||
        (response['data'] is List && response['success'] != false);

    if (isSuccess) {
      final listData = response['data'] ?? response['cities'];
      if (listData is List) {
        final cities = listData
            .map((item) => CityModel.fromJson(Map<String, dynamic>.from(item)))
            .where((city) => city.cityName.isNotEmpty)
            .toList();

        _cachedCities = cities;
        return cities;
      }
      return [];
    } else {
      throw Exception(response['message'] ?? 'Failed to load cities');
    }
  }

  /// Synchronously get cached cities if available
  List<CityModel>? get cachedCities => _cachedCities;
}
