import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';
import 'package:hyper_local/Screen/login_screen.dart';
import '../utils/app_colors.dart';

class FindBestJobPage extends StatefulWidget {
  const FindBestJobPage({super.key});

  @override
  State<FindBestJobPage> createState() => _FindBestJobPageState();
}

class _FindBestJobPageState extends State<FindBestJobPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;

  late Animation<double> _imageFade;
  late Animation<double> _imageScale;

  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_titleFade);

    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_subtitleFade);

    _imageFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
    );
    _imageScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_buttonFade);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "Find Jobs",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Title
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: const Text(
                    "Find Best Jobs\nin Your Area",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              FadeTransition(
                opacity: _subtitleFade,
                child: SlideTransition(
                  position: _subtitleSlide,
                  child: Text(
                    "Explore thousands of jobs near your location",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Illustration (animated entrance)
              Expanded(
                child: FadeTransition(
                  opacity: _imageFade,
                  child: ScaleTransition(
                    scale: _imageScale,
                    child: Center(
                      child: Image.asset(
                        'assets/images/screen_222 (2).png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Login / Register button
              FadeTransition(
                opacity: _buttonFade,
                child: SlideTransition(
                  position: _buttonSlide,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.buttonPrimary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Login / Register",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.buttonText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Continue as Guest
              FadeTransition(
                opacity: _buttonFade,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Continue as Guest",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
