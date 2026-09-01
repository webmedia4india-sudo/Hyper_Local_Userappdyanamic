import 'package:flutter/material.dart';
import 'package:hyper_local/Screen/login_screen.dart';
import 'package:hyper_local/Screen/onboarding_screen.dart';
import '../utils/app_colors.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<String> _cities = [
    "Amravati",
    "Akola",
    "Nagpur",
    "Yavatmal",
    "Digras",
  ];

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── BACK ARROW → ONBOARDING SCREEN ───────────────────────
  void _handleBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
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
                        // child: const Icon(
                        //   Icons.arrow_back,
                        //   color: AppColors.textPrimary,
                        // ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Title
              Center(
                // child: Text(
                //   "Select City",
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.bold,
                //     color: AppColors.textPrimary,
                //   ),
                // ),
              ),

              const SizedBox(height: 6),

              // Subtitle
              Center(
                child: Text(
                  "Select your preferred city",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 8, 8, 8),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // City options list
              Expanded(
                child: ListView.separated(
                  itemCount: _cities.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedIndex == index;
                    final city = _cities[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.08)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
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
                                  city,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
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
                ),
              ),

              // Continue button
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: GestureDetector(
                  onTapDown: _onContinueTapDown,
                  onTapUp: _onContinueTapUp,
                  onTapCancel: _onContinueTapCancel,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
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
                            color: AppColors.primary.withOpacity(
                              _continueButtonScale == 1.0 ? 0.3 : 0.15,
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
}