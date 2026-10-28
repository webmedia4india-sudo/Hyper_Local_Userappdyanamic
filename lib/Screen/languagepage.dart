import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';
import 'package:hyper_local/Screen/onboarding_screen.dart';
import '../models/location/city_model.dart';
import '../services/location_service.dart';
import '../utils/app_colors.dart';
import '../utils/session_manager.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage>
    with SingleTickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  List<CityModel> _allCities = [];
  List<CityModel> _filteredCities = [];
  CityModel? _selectedCity;
  bool _isLoading = true;
  String? _errorMessage;

  // ── Pulsing animation for location icon ───────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ── Continue button press animation ────────────────────────
  double _continueButtonScale = 1.0;

  void _onContinueTapDown(TapDownDetails details) {
    setState(() => _continueButtonScale = 0.95);
  }

  void _onContinueTapUp(TapUpDetails details) {
    setState(() => _continueButtonScale = 1.0);
  }

  void _onContinueTapCancel() {
    setState(() => _continueButtonScale = 1.0);
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cities = await _locationService.getCities();
      final savedCityId = await SessionManager.getSelectedCityId();
      final savedCityName = await SessionManager.getSelectedCityName();

      CityModel? defaultSelection;
      if (savedCityId != null && savedCityId != 0) {
        try {
          defaultSelection = cities.firstWhere((c) => c.id == savedCityId);
        } catch (_) {}
      }
      if (defaultSelection == null && savedCityName != null && savedCityName.isNotEmpty) {
        try {
          defaultSelection = cities.firstWhere(
            (c) => c.cityName.toLowerCase() == savedCityName.toLowerCase(),
          );
        } catch (_) {}
      }
      if (defaultSelection == null && cities.isNotEmpty) {
        defaultSelection = cities.first;
      }

      if (mounted) {
        setState(() {
          _allCities = cities;
          _filteredCities = cities;
          _selectedCity = defaultSelection;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load cities. Please check your connection.";
          _isLoading = false;
        });
      }
    }
  }

  void _filterCities(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredCities = _allCities;
      } else {
        _filteredCities = _allCities
            .where((city) =>
                city.cityName.toLowerCase().contains(q) ||
                (city.stateName != null &&
                    city.stateName!.toLowerCase().contains(q)))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── BACK ARROW → ONBOARDING SCREEN ───────────────────────
  void _handleBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  Future<void> _handleContinue() async {
    if (_selectedCity != null) {
      await SessionManager.saveSelectedCity(
        cityId: _selectedCity!.id,
        cityName: _selectedCity!.cityName,
      );
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 44),

              // Top row: Back button (left) + Logo (center)
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/new_onboarding_logo.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _handleBack,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Subtitle
              Center(
                child: Text(
                  "Select your preferred city",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 8, 8, 8),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Search field to quickly filter cities
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterCities,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Search your city...",
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.unselected,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // City options list
              Expanded(
                child: _buildContent(),
              ),

              // Continue button
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: GestureDetector(
                  onTapDown: _onContinueTapDown,
                  onTapUp: _onContinueTapUp,
                  onTapCancel: _onContinueTapCancel,
                  onTap: _handleContinue,
                  child: AnimatedScale(
                    scale: _continueButtonScale,
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.buttonPrimary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: _continueButtonScale == 1.0 ? 0.3 : 0.15,
                            ),
                            blurRadius: _continueButtonScale == 1.0 ? 12 : 6,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.buttonText,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.buttonText,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchCities,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredCities.isEmpty) {
      return const Center(
        child: Text(
          "No cities found",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredCities.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final city = _filteredCities[index];
        final isSelected = _selectedCity?.id == city.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCity = city;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Animated pulsing location icon
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 20,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.unselected,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      city.cityName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.selected,
                    size: 22,
                  )
                else
                  Icon(
                    Icons.circle_outlined,
                    color: AppColors.unselected,
                    size: 22,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}