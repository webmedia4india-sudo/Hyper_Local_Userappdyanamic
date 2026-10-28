import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applicationtrackerpage.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';
import 'package:hyper_local/Pages/homepage.dart';
import 'package:hyper_local/Pages/profilepage.dart';
import 'package:hyper_local/Pages/recommendedjpbpage.dart';
import 'package:hyper_local/utils/app_colors.dart';

/// Item configuration model for [CommonBottomBar]
class CommonBottomNavItem {
  final IconData icon;
  final String label;
  final Widget Function()? pageBuilder;

  const CommonBottomNavItem({
    required this.icon,
    required this.label,
    this.pageBuilder,
  });
}

/// ── COMMON BOTTOM NAVIGATION BAR ─────────────────────────────────────────
/// Reusable bottom bar that can be called across any page or inside [MainNavigationScreen].
///
/// Usage on any page:
/// ```dart
/// Scaffold(
///   body: ...,
///   bottomNavigationBar: const CommonBottomBar(currentIndex: 0),
/// )
/// ```
class CommonBottomBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<CommonBottomNavItem>? items;

  const CommonBottomBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.items,
  });

  /// Default 5 App Tabs:
  /// Index 0: Cards (HomePage)
  /// Index 1: Dashboard (DashboardPage)
  /// Index 2: Jobs (RecommendedJobPage)
  /// Index 3: History (ApplicationTrackerPage)
  /// Index 4: Profile (ProfilePage)
  static final List<CommonBottomNavItem> defaultItems = [
    CommonBottomNavItem(
      icon: Icons.layers_rounded,
      label: "Cards",
      pageBuilder: () => const HomePage(),
    ),
    CommonBottomNavItem(
      icon: Icons.space_dashboard_rounded,
      label: "Dashboard",
      pageBuilder: () => const DashboardPage(),
    ),
    CommonBottomNavItem(
      icon: Icons.work_outline_rounded,
      label: "Jobs",
      pageBuilder: () => const RecommendedJobPage(),
    ),
    CommonBottomNavItem(
      icon: Icons.description_outlined,
      label: "History",
      pageBuilder: () => const ApplicationTrackerPage(),
    ),
    CommonBottomNavItem(
      icon: Icons.person_outline_rounded,
      label: "Profile",
      pageBuilder: () => const ProfilePage(),
    ),
  ];

  @override
  State<CommonBottomBar> createState() => _CommonBottomBarState();
}

class _CommonBottomBarState extends State<CommonBottomBar> {
  // Electric / Royal Blue Gradient matching app theme
  static const LinearGradient _activeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF001090), // Deep royal navy
      Color(0xFF0020C2), // Rich electric blue
      Color(0xFF004AE0), // Vibrant blue
    ],
  );

  void _handleTabTap(int index) {
    // If a custom onTap callback is provided, invoke it
    if (widget.onTap != null) {
      widget.onTap!(index);
      return;
    }

    // Default Navigation logic
    if (widget.currentIndex == index) {
      return; // Already on this tab
    }

    final items = widget.items ?? CommonBottomBar.defaultItems;
    if (index >= items.length) return;

    final targetPageBuilder = items[index].pageBuilder;
    if (targetPageBuilder == null) return;

    // Route to the selected page
    if (index == 0 || index == 1) {
      // Home & Dashboard clear the stack to avoid stack buildup
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => targetPageBuilder()),
        (route) => false,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => targetPageBuilder()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final navItems = widget.items ?? CommonBottomBar.defaultItems;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FB),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final isSelected = widget.currentIndex == index;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _handleTabTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 16 : 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected ? _activeGradient : null,
                        color: isSelected ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: isSelected ? 1 : 0,
                            ),
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 1 + (value * 0.15),
                                child: child,
                              );
                            },
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                              child: Icon(
                                item.icon,
                                key: ValueKey(isSelected),
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.unselected,
                                size: 23,
                              ),
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            child: isSelected
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 220),
                                      opacity: isSelected ? 1 : 0,
                                      child: Text(
                                        item.label,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ── MAIN NAVIGATION SCREEN (ALL-IN-ONE NAVIGATION SHELL) ─────────────────
/// Can be used as the root screen after login to switch between tabs
/// without reloading or rebuilding screens.
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomePage(),
    DashboardPage(),
    RecommendedJobPage(),
    ApplicationTrackerPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CommonBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
