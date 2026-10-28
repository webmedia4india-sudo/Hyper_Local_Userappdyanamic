import 'package:flutter/material.dart';
import 'package:hyper_local/Screen/login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../utils/app_colors.dart';
import '../widgets/onboarding_page.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();

  bool isLastPage = false;

  // ── BUTTON PRESS ANIMATION STATE ─────────────────────────
  double _buttonScale = 1.0;

  void _onButtonTapDown(TapDownDetails details) {
    setState(() => _buttonScale = 0.95);
  }

  void _onButtonTapUp(TapUpDetails details) {
    setState(() => _buttonScale = 1.0);
  }

  void _onButtonTapCancel() {
    setState(() => _buttonScale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller,

                onPageChanged: (index) {
                  setState(() {
                    isLastPage = index == 1;
                  });
                },

                children: const [
                  OnboardingPage(
                    image: "assets/images/screen_112.png",
                    title: "Find Jobs Near You",
                    subtitle:
                        "Discover thousands of local job opportunities tailored to your skills and location.",
                    titleFontSize: 16,
                    subtitleFontSize: 14,
                  ),

                  OnboardingPage(
                    image: "assets/images/screen_222.png",
                    title: "Apply & Get Hired Fast",
                    subtitle:
                        "Connect directly with employers and get hired quickly without any hassle.",
                    titleFontSize: 16,
                    subtitleFontSize: 14,
                  ),
                ],
              ),
            ),

            SmoothPageIndicator(
              controller: controller,
              count: 2,

              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.primary,
                dotColor: AppColors.unselected,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),

            const SizedBox(height: 35),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),

              child: GestureDetector(
                onTapDown: _onButtonTapDown,
                onTapUp: _onButtonTapUp,
                onTapCancel: _onButtonTapCancel,
                onTap: () {
                  if (isLastPage) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  } else {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                },

                child: AnimatedScale(
                  scale: _buttonScale,
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
                            _buttonScale == 1.0 ? 0.3 : 0.15,
                          ),
                          blurRadius: _buttonScale == 1.0 ? 12 : 6,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            isLastPage ? "Get Started" : "Next",
                            key: ValueKey(isLastPage),

                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.buttonText,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.buttonText,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}