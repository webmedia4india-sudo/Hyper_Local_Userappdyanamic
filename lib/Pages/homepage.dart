import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applicationtrackerpage.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';
import 'package:hyper_local/Pages/profilepage.dart';
import 'package:hyper_local/Pages/recommendedjpbpage.dart';
import 'package:hyper_local/utils/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Company {
  final String name;
  final String location;
  final String industry;
  final String employees;
  final String founded;
  final String openJobs;
  final String about;
  final String address;
  final String logoUrl;
  final String bannerUrl;
  final int matchScore;
  final List<String> technologies;

  Company({
    required this.name,
    required this.location,
    required this.industry,
    required this.employees,
    required this.founded,
    required this.openJobs,
    required this.about,
    required this.address,
    required this.logoUrl,
    required this.bannerUrl,
    required this.matchScore,
    required this.technologies,
  });
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final int _selectedIndex = 0;
  final List<Company> _companies = [
    Company(
      name: "Turing Tech Labs",
      location: "Pune, MH",
      industry: "IT Services & Consulting",
      employees: "50-150 Employees",
      founded: "2019",
      openJobs: "4 Openings",
      about:
          "Turing Tech Labs is a premier IT consulting firm providing high-performance full-stack web systems and hybrid mobile app solutions.",
      address: "Kothrud, Pune, Maharashtra",
      logoUrl:
          "https://ui-avatars.com/api/?name=Turing+Tech&background=1E3AE2&color=fff&size=200&bold=true",
      bannerUrl:
          "https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=600&auto=format&fit=crop",
      matchScore: 94,
      technologies: ["Flutter", "React", "Node.js", "MongoDB"],
    ),
    Company(
      name: "CloudScale Analytics",
      location: "Nagpur, MH",
      industry: "Cloud & DevOps Solutions",
      employees: "50-100 Employees",
      founded: "2020",
      openJobs: "5 Openings",
      about:
          "We specialize in cloud migration, serverless microservices architecture, and fully automated CI/CD DevOps workflows on AWS and GCP.",
      address: "Sadar, Nagpur, Maharashtra",
      logoUrl:
          "https://ui-avatars.com/api/?name=CloudScale&background=3DDC97&color=1A1A1A&size=200&bold=true",
      bannerUrl:
          "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?q=80&w=600&auto=format&fit=crop",
      matchScore: 91,
      technologies: ["AWS", "Docker", "Kubernetes", "Terraform"],
    ),
    Company(
      name: "PixelCraft Web Studio",
      location: "Mumbai, MH",
      industry: "UI/UX & Web Development",
      employees: "20-50 Employees",
      founded: "2021",
      openJobs: "2 Openings",
      about:
          "An award-winning agency focused on crafting modern, responsive web experiences and brand identity systems using NextJS and Tailwind.",
      address: "Andheri West, Mumbai, Maharashtra",
      logoUrl:
          "https://ui-avatars.com/api/?name=PixelCraft&background=A6D608&color=1A1A1A&size=200&bold=true",
      bannerUrl:
          "https://images.unsplash.com/photo-1531403009284-440f080d1e12?q=80&w=600&auto=format&fit=crop",
      matchScore: 88,
      technologies: ["Figma", "Next.js", "React", "Tailwind CSS"],
    ),
    Company(
      name: "HyperLink Systems",
      location: "Nashik, MH",
      industry: "Mobile & AI Development",
      employees: "100-250 Employees",
      founded: "2017",
      openJobs: "3 Openings",
      about:
          "HyperLink Systems builds smart mobile applications with embedded machine learning models, offering seamless experiences on iOS & Android.",
      address: "College Road, Nashik, Maharashtra",
      logoUrl:
          "https://ui-avatars.com/api/?name=HyperLink&background=F48FB1&color=fff&size=200&bold=true",
      bannerUrl:
          "https://images.unsplash.com/photo-1555066931-4365d14bab8c?q=80&w=600&auto=format&fit=crop",
      matchScore: 85,
      technologies: ["Flutter", "Dart", "Python", "Firebase"],
    ),
    Company(
      name: "Synergy Software Systems",
      location: "Mumbai, MH",
      industry: "Enterprise Software Development",
      employees: "500+ Employees",
      founded: "2015",
      openJobs: "6 Openings",
      about:
          "Synergy builds custom enterprise resource planning (ERP) platforms and database systems for scalability and high-concurrency.",
      address: "Andheri East, Mumbai, Maharashtra",
      logoUrl:
          "https://ui-avatars.com/api/?name=Synergy+Software&background=FF8A75&color=fff&size=200&bold=true",
      bannerUrl:
          "https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=600&auto=format&fit=crop",
      matchScore: 79,
      technologies: ["Java", "Spring Boot", "PostgreSQL", "Angular"],
    ),
  ];

  late List<Company> _stack;

  // Drag state
  Offset _dragOffset = Offset.zero;
  double _angle = 0;
  bool _isDragging = false;

  // Overlay label opacity (LIKE / NOPE)
  double _likeOpacity = 0;
  double _nopeOpacity = 0;

  static const double _swipeThreshold = 120;

  @override
  void initState() {
    super.initState();
    _stack = List.from(_companies);
  }

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _angle = _dragOffset.dx / 300; // subtle rotation
      if (_dragOffset.dx > 0) {
        _likeOpacity = (_dragOffset.dx / _swipeThreshold).clamp(0, 1);
        _nopeOpacity = 0;
      } else {
        _nopeOpacity = (-_dragOffset.dx / _swipeThreshold).clamp(0, 1);
        _likeOpacity = 0;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragOffset.dx > _swipeThreshold) {
      _completeSwipe(isRight: true);
    } else if (_dragOffset.dx < -_swipeThreshold) {
      _completeSwipe(isRight: false);
    } else {
      // snap back
      setState(() {
        _isDragging = false;
        _dragOffset = Offset.zero;
        _angle = 0;
        _likeOpacity = 0;
        _nopeOpacity = 0;
      });
    }
  }

  void _completeSwipe({required bool isRight}) {
    final screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      _dragOffset = Offset(
        isRight ? screenWidth * 1.5 : -screenWidth * 1.5,
        _dragOffset.dy,
      );
      _isDragging = false;
    });

    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() {
        if (_stack.isNotEmpty) {
          final removed = _stack.removeLast();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(milliseconds: 700),
              behavior: SnackBarBehavior.floating,
              backgroundColor: isRight ? AppColors.success : AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              content: Text(
                isRight
                    ? "${removed.name} - Shortlisted"
                    : "${removed.name} - Skipped",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }
        _dragOffset = Offset.zero;
        _angle = 0;
        _likeOpacity = 0;
        _nopeOpacity = 0;
      });
    });
  }

  void _buttonSwipe({required bool isRight}) {
    if (_stack.isEmpty) return;
    setState(() {
      _dragOffset = Offset(isRight ? 40 : -40, 0);
    });
    _completeSwipe(isRight: isRight);
  }

  void _resetStack() {
    setState(() {
      _stack = List.from(_companies);
      _dragOffset = Offset.zero;
      _angle = 0;
      _likeOpacity = 0;
      _nopeOpacity = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.scaffoldBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F8FF), Color(0xFFECEEFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── TOP LOGO HEADER WITH HOME BUTTON ──
              // Added extra top padding + switched to a Stack so the logo
              // stays perfectly centered regardless of the button's width.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/new_onboarding_logo.png',
                        height: 28,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppColors.mainGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.business_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardPage(),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.35),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.30),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.keyboard_double_arrow_right_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _stack.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          const SizedBox(height: 16), // <-- extra space
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  for (int i = 0; i < _stack.length; i++)
                                    _buildCard(i),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              if (_stack.isNotEmpty) _buildActionButtons(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                    children: [
                      _bottomNavItem(
                        Icons.layers_rounded,
                        "Cards",
                        0,
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                      _bottomNavItem(
                        Icons.space_dashboard_rounded,
                        "Dashboard",
                        1,
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardPage(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                      _bottomNavItem(
                        Icons.work_outline_rounded,
                        "Jobs",
                        2,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RecommendedJobPage(),
                            ),
                          );
                        },
                      ),
                      _bottomNavItem(
                        Icons.description_outlined,
                        "History",
                        3,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ApplicationTrackerPage(),
                            ),
                          );
                        },
                      ),
                      _bottomNavItem(
                        Icons.person_outline_rounded,
                        "Profile",
                        4,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: AppColors.mainGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.business_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No more companies",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You've reviewed all companies in the queue",
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: _resetStack,
            child: Container(
              width: 150,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.buttonPrimary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                "Reload Companies",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.buttonText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final isTopCard = index == _stack.length - 1;
    final company = _stack[index];
    final accentColor = AppColors.accents[index % AppColors.accents.length];

    // Slight stacked scale/offset for cards behind top card
    final depth = (_stack.length - 1) - index;
    final scale = 1 - (depth * 0.045).clamp(0.0, 0.09);
    final topOffset = depth * 12.0;

    Widget card = _CompanyCard(
      key: ValueKey(company.name),
      company: company,
      accentColor: accentColor,
      animate: isTopCard,
    );

    if (isTopCard) {
      return AnimatedContainer(
        duration: _isDragging
            ? Duration.zero
            : const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(_dragOffset.dx, _dragOffset.dy)
          ..rotateZ(_angle),
        transformAlignment: Alignment.center,
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Stack(
            children: [
              card,
              // LIKE stamp
              Positioned(
                top: 40,
                left: 24,
                child: Opacity(
                  opacity: _likeOpacity,
                  child: Transform.rotate(
                    angle: -pi / 12,
                    child: _stampLabel("SHORTLIST", AppColors.success),
                  ),
                ),
              ),
              // NOPE stamp
              Positioned(
                top: 40,
                right: 24,
                child: Opacity(
                  opacity: _nopeOpacity,
                  child: Transform.rotate(
                    angle: pi / 12,
                    child: _stampLabel("SKIP", AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Cards underneath — static, slightly scaled/shifted
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      transform: Matrix4.identity()
        ..translate(0.0, topOffset)
        ..scale(scale),
      transformAlignment: Alignment.center,
      child: card,
    );
  }

  Widget _stampLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3.5),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    // Dynamic scale values based on horizontal drag offset
    final double leftScale = _dragOffset.dx < 0
        ? 1.0 + (-_dragOffset.dx / _swipeThreshold).clamp(0, 1) * 0.3
        : 1.0;
    final double rightScale = _dragOffset.dx > 0
        ? 1.0 + (_dragOffset.dx / _swipeThreshold).clamp(0, 1) * 0.3
        : 1.0;

    final double leftGlow = _dragOffset.dx < 0
        ? (-_dragOffset.dx / _swipeThreshold).clamp(0, 1)
        : 0.0;
    final double rightGlow = _dragOffset.dx > 0
        ? (_dragOffset.dx / _swipeThreshold).clamp(0, 1)
        : 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.identity()..scale(leftScale),
          transformAlignment: Alignment.center,
          child: _circleButton(
            icon: Icons.close_rounded,
            color: AppColors.error,
            size: 48,
            iconSize: 22,
            glowIntensity: leftGlow,
            onTap: () => _buttonSwipe(isRight: false),
          ),
        ),
        const SizedBox(width: 28),
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.identity()..scale(rightScale),
          transformAlignment: Alignment.center,
          child: _circleButton(
            icon: Icons.favorite_rounded,
            color: AppColors.success,
            size: 48,
            iconSize: 22,
            glowIntensity: rightGlow,
            onTap: () => _buttonSwipe(isRight: true),
          ),
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 56,
    double iconSize = 26,
    double glowIntensity = 0.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18 + (glowIntensity * 0.25)),
              blurRadius: 12 + (glowIntensity * 12),
              spreadRadius: glowIntensity * 4,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }

  // ── BOTTOM NAV ITEM HELPER (FULLY ANIMATED WITH HEADER GRADIENT ON ACTIVE) ──
  Widget _bottomNavItem(
    IconData icon,
    String label,
    int index, {
    VoidCallback? onTap,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? GenZ.headerGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: GenZ.purple.withOpacity(0.25),
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
              tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(scale: 1 + (value * 0.15), child: child);
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? Colors.white : AppColors.unselected,
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
                        duration: const Duration(milliseconds: 220),
                        opacity: isSelected ? 1 : 0,
                        child: Text(
                          label,
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
  }
}

class _CompanyCard extends StatefulWidget {
  final Company company;
  final Color accentColor;
  final bool animate;

  const _CompanyCard({
    super.key,
    required this.company,
    required this.accentColor,
    this.animate = false,
  });

  @override
  State<_CompanyCard> createState() => _CompanyCardState();
}

class _CompanyCardState extends State<_CompanyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    if (widget.animate) {
      _entryController.forward();
    } else {
      _entryController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final company = widget.company;
    final accentColor = widget.accentColor;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top banner / logo / highlighted name section inside the card
              SizedBox(
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      company.bannerUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentColor, AppColors.primaryDeep],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    // Gradient overlay for header name readability
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black38,
                            Colors.transparent,
                            Colors.black87,
                          ],
                          stops: [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                    // Company Name highlight + logo inside the header overlay
                    Positioned(
                      left: 16,
                      bottom: 12,
                      right: 16,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              company.logoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: accentColor,
                                    child: const Icon(
                                      Icons.business,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              company.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(blurRadius: 6, color: Colors.black87),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom info details section inside the card
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.97),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  company.industry,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.bolt_rounded,
                                      color: AppColors.success,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      "${company.matchScore}% Match",
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: accentColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                company.location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              company.address,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                Icons.calendar_today_outlined,
                                "Founded",
                                company.founded,
                                GenZ.coral,
                              ),
                              _buildStatItem(
                                Icons.people_outline_rounded,
                                "Employees",
                                company.employees,
                                GenZ.mint,
                              ),
                              _buildStatItem(
                                Icons.work_outline_rounded,
                                "Open Jobs",
                                company.openJobs,
                                GenZ.pink,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 14),
                          const Text(
                            "About Company",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            company.about,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "Tech Stack",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: company.technologies
                                .map(
                                  (tech) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.15),
                                      ),
                                    ),
                                    child: Text(
                                      tech,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 18),
                          // Custom GenZ Gradient Button Container
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accentColor,
                                  accentColor.withOpacity(0.8),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RecommendedJobPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Tops Jobs",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
