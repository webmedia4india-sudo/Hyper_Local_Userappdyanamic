import 'package:flutter/material.dart';
import '../models/banner/banner_model.dart';
import '../services/banner_service.dart';

class BannerController extends ChangeNotifier {
  final BannerService _bannerService = BannerService();

  List<BannerModel> banners = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadBanners({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      // 1. Primary: Load active banners from http://localhost:5000/api/banners
      List<BannerModel> fetched = await _bannerService.getBanners();

      // 2. Fallback: If /banners is empty, try /banners/all
      if (fetched.isEmpty) {
        fetched = await _bannerService.getAllBanners();
      }

      final hasChanged = fetched.length != banners.length ||
          !_areBannerListsEqual(fetched, banners);

      if (hasChanged || !silent) {
        banners = fetched;
        debugPrint("Updated banners in controller: count=${banners.length}");
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Banner Controller Error: $e");
    } finally {
      if (!silent) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  bool _areBannerListsEqual(List<BannerModel> a, List<BannerModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].imageUrl != b[i].imageUrl) {
        return false;
      }
    }
    return true;
  }
}