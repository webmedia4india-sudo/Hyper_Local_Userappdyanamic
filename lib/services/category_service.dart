import 'api_service.dart';
import '../models/category/category_model.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  /// GET /api/categories — Fetch list of categories from admin panel backend
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiService.getRequest('/categories');

    final bool isSuccess = response['success'] == true ||
        response['status'] == true ||
        response['status'] == 200 ||
        response['status'] == 'success' ||
        (response['categories'] is List && response['success'] != false) ||
        (response['data'] is List && response['success'] != false);

    if (isSuccess) {
      final listData = response['categories'] ?? response['data'];
      if (listData != null && listData is List) {
        return listData
            .map((json) => CategoryModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
      return [];
    } else {
      throw Exception(response['message'] ?? 'Failed to load categories');
    }
  }
}
