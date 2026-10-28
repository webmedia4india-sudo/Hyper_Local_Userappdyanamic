import 'package:flutter/material.dart';
import '../models/category/category_model.dart';
import '../services/category_service.dart';

class CategoryController extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> categories = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadCategories({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final fetched = await _categoryService.getCategories();
      categories = fetched;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      if (!silent) {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}
