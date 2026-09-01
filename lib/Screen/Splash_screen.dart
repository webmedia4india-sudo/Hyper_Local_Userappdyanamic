import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';
import 'package:hyper_local/Screen/onboarding_screen.dart';
import 'package:hyper_local/utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Simple entrance animation (fade + scale for logo, fade + slide for text)
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    // लोगो आणि लोडिंग ॲनिमेशन दाखवून २.५ सेकंद थांबा
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // secure auth token चेक करण्यासाठी
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("auth_token");

    Widget nextScreen;
    if (token != null && token.isNotEmpty) {
      nextScreen = const DashboardPage();
    } else {
      nextScreen = const OnboardingScreen();
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo with fade + scale entrance
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/images/new_splash_logo.png',
                    width: 240,
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // App name (fade + slide up)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: child,
                    ),
                  );
                },
                // child: const Text(
                //   'Hyper Local',
                //   style: TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.white,
                //     letterSpacing: 0.5,
                //   ),
                // ),
              ),

              const SizedBox(height: 8),

              // Tagline (fade + slide up)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: child,
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Colors.white.withOpacity(0.85),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Find Jobs. Get Hired. Near You.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Simple loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Text(
              //   'Setting things up...',
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: Colors.white.withOpacity(0.7),
              //     fontWeight: FontWeight.w400,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}