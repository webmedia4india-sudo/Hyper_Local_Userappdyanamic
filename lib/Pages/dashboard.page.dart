import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hyper_local/Pages/aboutapppage.dart';
import 'package:hyper_local/Pages/applicationtrackerpage.dart';
import 'package:hyper_local/Pages/homepage.dart';
import 'package:hyper_local/Pages/resumescorepage.dart';
import 'package:hyper_local/Pages/categoriespage.dart' show CategoriesPage;
import 'package:hyper_local/Pages/coverletterspage.dart';
import 'package:hyper_local/Pages/helpcenterpage.dart';
import 'package:hyper_local/Pages/hyperlocalfeaturespage.dart';
import 'package:hyper_local/Pages/learningcareerpage.dart';
import 'package:hyper_local/Pages/missopportunitypage.dart';
import 'package:hyper_local/Pages/notificationpage.dart';
import 'package:hyper_local/Pages/parttimejobpage.dart';
import 'package:hyper_local/Pages/governmentjobpage.dart';
import 'package:hyper_local/Pages/mockinterviewpage.dart';
import 'package:hyper_local/Pages/profilepage.dart';
import 'package:hyper_local/Pages/recommendedjpbpage.dart';
import 'package:hyper_local/Pages/savedjobpage.dart';
import 'package:hyper_local/Pages/settingpage.dart';
import 'package:hyper_local/Pages/supportticketspage.dart';
import 'package:hyper_local/Pages/wallectpremiumpage.dart';
import 'package:hyper_local/Pages/workfromhomepage.dart';
import 'package:hyper_local/Screen/login_screen.dart';
import 'package:hyper_local/utils/app_colors.dart';
import 'jobnearmappage.dart';
import 'dart:async';

/// ── GEN-Z PASTEL PALETTE (taken from reference collage image) ──────────
/// Purple / Lavender / Pink / Coral / Mint — soft, rounded, poppy.
/// Header + Sidebar now use a PURPLE GRADIENT (solid removed).
class GenZ {
  static const Color purple = AppColors.primary;
  static const Color purpleDark = AppColors.primaryDark;
  static const Color purpleDeep = AppColors.primaryDeep;
  static const Color lavender = AppColors.lime;
  static const Color lavenderSoft = AppColors.limeSoft;
  static const Color pink = AppColors.pink;
  static const Color pinkSoft = AppColors.pinkSoft;
  static const Color coral = AppColors.coral;
  static const Color coralSoft = AppColors.coralSoft;
  static const Color mint = AppColors.mint;
  static const Color mintSoft = AppColors.mintSoft;

  // ── BLUE GRADIENT for TOP HEADER (matching uploaded image theme, right side made darker) ──
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF001090), // Very deep navy/royal blue
      Color(0xFF0020C2), // Rich Dark Blue from image
      Color(0xFF004AE0), // Darker vibrant blue on the right (was 0xFF8AD1FC)
    ],
  );

  // ── BLUE GRADIENT for SIDEBAR/DRAWER header (matching uploaded image theme, right side made darker) ──
  static const LinearGradient drawerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF001090),
      Color(0xFF0020C2),
      Color(0xFF004AE0),
    ],
  );

  // ── SOFT GRADIENT for OVERALL PAGE BACKGROUND ──
  static const LinearGradient pageBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8ECFF), // very light blue at top
      AppColors.scaffoldBackground, // near-white blue-white
      Color(0xFFFFFFFF), // white towards bottom
    ],
  );

  // cycling accent colors for cards / logos / categories (kept multi-color)
  static const List<Color> accents = [purple, coral, mint, pink, lavender];
  static const List<Color> accentsSoft = [
    Color(0xFFDCE3FF),
    coralSoft,
    mintSoft,
    pinkSoft,
    lavenderSoft,
  ];
}

/// ── TAP-SCALE "HOVER" WRAPPER ────────────────────────────────────────
/// Mobile has no real hover, so this gives a snappy shrink-on-press feel
/// which reads as "hover/interactive" in a Gen-Z UI.
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const TapScale({super.key, required this.child, this.onTap});

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  double _scale = 1.0;

  void _setScale(double v) => setState(() => _scale = v);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setScale(0.94),
      onTapUp: (_) => _setScale(1.0),
      onTapCancel: () => _setScale(1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// ── 3D PRESS WRAPPER ──────────────────────────────────────────────────
/// Gives job cards a "pressable 3D button" feel: card sits raised with a
/// deep drop shadow; on press it sinks down and the shadow shrinks, like
/// it's physically being pushed into the screen.
class Tap3D extends StatefulWidget {
  final Widget Function(bool pressed) builder;
  final VoidCallback? onTap;
  const Tap3D({super.key, required this.builder, this.onTap});

  @override
  State<Tap3D> createState() => _Tap3DState();
}

class _Tap3DState extends State<Tap3D> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, _pressed ? 4.0 : 0.0)
          ..setEntry(3, 2, 0.0015)
          ..rotateX(_pressed ? 0.0 : -0.012)
          ..rotateY(_pressed ? 0.0 : 0.012),
        transformAlignment: Alignment.center,
        child: widget.builder(_pressed),
      ),
    );
  }
}

/// ── DECORATIVE BLOB (soft translucent circle) ─────────────────────────
/// Used behind the purple header/drawer header for extra depth & attractiveness.
class _HeaderBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _HeaderBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  int _selectedIndex = 1;

  // ── NOTIFICATION "NEW JOB POST" BLINK STATE ──────────────────────────
  bool _hasNewNotification = true; // set true whenever a new job is posted
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // ── WAVING HAND EMOJI ANIMATION ───────────────────────────────────────
  late final AnimationController _waveCtrl;
  late final Animation<double> _waveAnim;

  // ── SEARCH BAR STATE ───────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedLocation = "Amravati";
  bool _isSearchExpanded = false;

  // ── SLIDER STATE ──────────────────────────────────────────────────
  late final PageController _sliderPageController;
  Timer? _sliderTimer;
  int _currentSliderPage = 0;

  List<Map<String, dynamic>> sliderItems = [
    {
      "title": "Government Job Alerts",
      "subtitle": "Apply for latest Govt & PSU openings",
      "badge": "GOVT JOBS",
      "gradient": const LinearGradient(
        colors: [Color(0xFF3F2B96), Color(0xFFA8C0FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      "icon": Icons.gavel_rounded,
      "route": "gov",
      "image": "https://images.unsplash.com/photo-1541829011-55b2060964ff?auto=format&fit=crop&w=600&q=80",
    },
    {
      "title": "Mock Interview Prep",
      "subtitle": "Practice questions & get AI feedback",
      "badge": "AI TRAINING",
      "gradient": const LinearGradient(
        colors: [Color(0xFFF12711), Color(0xFFF5AF19)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      "icon": Icons.question_answer_rounded,
      "route": "mock",
      "image": "https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?auto=format&fit=crop&w=600&q=80",
    },
    {
      "title": "Demo Intro Video",
      "subtitle": "Watch how to build your profile",
      "badge": "WATCH VIDEO",
      "gradient": const LinearGradient(
        colors: [Color(0xFF8A2387), Color(0xFFE94057)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      "icon": Icons.play_circle_fill_rounded,
      "route": "video_demo",
      "isVideo": true,
      "isNetworkVideo": true,
      "videoUrl": "https://assets.mixkit.co/videos/preview/mixkit-working-in-a-sunny-office-40455-large.mp4",
      "image": "https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=600&q=80",
    },
    {
      "title": "Part-Time Openings",
      "subtitle": "Find flexible shift jobs near you",
      "badge": "PART-TIME",
      "gradient": const LinearGradient(
        colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      "icon": Icons.schedule_rounded,
      "route": "parttime",
      "image": "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=600&q=80",
    },
  ];

  void _showLocationSelectionDialog() {
    final List<String> cities = [
      "Amravati",
      "Akola",
      "Nagpur",
      "Pune",
      "Mumbai",
      "Nashik",
    ];
    final TextEditingController customController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Select Location",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...cities.map((city) {
                  return ListTile(
                    leading: const Icon(
                      Icons.location_city_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      city,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedLocation = city;
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customController,
                          decoration: InputDecoration(
                            hintText: "Enter custom location",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 30,
                        ),
                        onPressed: () {
                          if (customController.text.trim().isNotEmpty) {
                            setState(() {
                              _selectedLocation = customController.text.trim();
                            });
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Hand waves back and forth a few times, then stops upright
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _waveAnim = Tween<double>(
      begin: -0.28,
      end: 0.28,
    ).animate(CurvedAnimation(parent: _waveCtrl, curve: Curves.easeInOut));

    _waveCtrl.value = 0.5; // Start upright
    int waveCount = 0;
    bool isStopping = false;
    _waveCtrl.addStatusListener((status) {
      if (isStopping) return;
      if (status == AnimationStatus.completed) {
        waveCount++;
        if (waveCount >= 6) {
          isStopping = true;
          _waveCtrl.animateTo(0.5, duration: const Duration(milliseconds: 200));
        } else {
          _waveCtrl.reverse();
        }
      } else if (status == AnimationStatus.dismissed) {
        waveCount++;
        if (waveCount >= 6) {
          isStopping = true;
          _waveCtrl.animateTo(0.5, duration: const Duration(milliseconds: 200));
        } else {
          _waveCtrl.forward();
        }
      }
    });
    _waveCtrl.forward();

    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });

    // Slider auto-play timer
    _sliderPageController = PageController(initialPage: 0);
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentSliderPage < sliderItems.length - 1) {
        _currentSliderPage++;
      } else {
        _currentSliderPage = 0;
      }
      if (_sliderPageController.hasClients) {
        _sliderPageController.animateToPage(
          _currentSliderPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _sliderPageController.dispose();
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── USER INFO ────────────────────────────────────────
  static const String userFirstName = "Rahul";
  static const String userName = "Rahul Sharma";
  static const String userEmail = "rahul.sharma@email.com";

  // ── QUICK ACTIONS ROW (updated) ───────────────────────
  final quickActions = [
    {
      "label": "Candidates",
      "icon": Icons.people_alt_rounded,
      "color": GenZ.mint,
    },
    {
      "label": "Nearby Jobs",
      "icon": Icons.location_on_rounded,
      "color": GenZ.coral,
    },
    {
      "label": " Applications",
      "icon": Icons.assignment_turned_in_rounded,
      "color": GenZ.purple,
    },
    {
      "label": "Build Resume",
      "icon": Icons.description_rounded,
      "color": GenZ.pink,
    },
  ];

  // ── EXPLORE CATEGORIES (Modernized Premium Icons) ──
  final categories = [
    {
      "label": "Delivery",
      "icon": Icons.electric_moped_rounded,
      "color": GenZ.purple,
      "openings": "18 Openings",
      "bgImage": "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?auto=format&fit=crop&w=300&q=80",
    },
    {
      "label": "Retail",
      "icon": Icons.shopping_bag_rounded,
      "color": GenZ.coral,
      "openings": "12 Openings",
      "bgImage": "https://images.unsplash.com/photo-1560750588-73207b1ef5b8?auto=format&fit=crop&w=300&q=80",
    },
    {
      "label": "Hotel",
      "icon": Icons.room_service_rounded,
      "color": GenZ.pink,
      "openings": "15 Openings",
      "bgImage": "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=300&q=80",
    },
    {
      "label": "Sales",
      "icon": Icons.campaign_rounded,
      "color": GenZ.mint,
      "openings": "22 Openings",
      "bgImage": "https://images.unsplash.com/photo-1552581230-c01bc0d48473?auto=format&fit=crop&w=300&q=80",
    },
    {
      "label": "Tech",
      "icon": Icons.code_rounded,
      "color": GenZ.purple,
      "openings": "30 Openings",
      "bgImage": "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=300&q=80",
    },
    {
      "label": "Design",
      "icon": Icons.palette_rounded,
      "color": GenZ.pink,
      "openings": "8 Openings",
      "bgImage": "https://images.unsplash.com/photo-1550684848-fac1c5b4e853?auto=format&fit=crop&w=300&q=80",
    },
    {
      "label": "Office",
      "icon": Icons.business_center_rounded,
      "color": GenZ.mint,
      "openings": "14 Openings",
      "bgImage": "https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=300&q=80",
    },
    {
      "label": "Tutor",
      "icon": Icons.school_rounded,
      "color": GenZ.coral,
      "openings": "9 Openings",
      "bgImage": "https://images.unsplash.com/photo-1427504494785-3a9ca7044f45?auto=format&fit=crop&w=300&q=80",
    },
    {
      "label": "Medical",
      "icon": Icons.medical_services_rounded,
      "color": GenZ.lavender,
      "openings": "11 Openings",
      "bgImage": "https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?auto=format&fit=crop&w=300&q=80",
    },
    {
      "label": "More",
      "icon": Icons.grid_view_rounded,
      "color": GenZ.lavender,
      "openings": "All Areas",
      "bgImage": "https://images.unsplash.com/photo-1507537297725-24a1c029d3ca?auto=format&fit=crop&w=300&q=80",
    },
  ];

  // ── JOBS DATA (extended with tags used for Home Sections + Personalization) ──
  final jobs = [
    {
      "title": "UI/UX Designer",
      "company": "Zoho Corporation",
      "distance": "1.8 km",
      "salary": "₹25,000 - ₹35,000",
      "logoText": "U",
      "logoColor": GenZ.purple,
      "logoUrl": "https://logo.clearbit.com/zoho.com",
      "skills": ["Figma", "UI Design", "Prototyping"],
      "isUrgent": true,
      "isNew": true,
      "isWalkIn": false,
      "isPremium": true,
      "isPartTime": false,
      "isWFH": false,
    },
    {
      "title": "Sales Management",
      "company": "Reliance Digital",
      "distance": "2.5 km",
      "salary": "₹22,000 - ₹30,000",
      "logoText": "S",
      "logoColor": GenZ.coral,
      "logoUrl": "https://logo.clearbit.com/reliancedigital.in",
      "skills": ["Sales", "Communication"],
      "isUrgent": false,
      "isNew": false,
      "isWalkIn": true,
      "isPremium": false,
      "isPartTime": false,
      "isWFH": false,
    },
    {
      "title": "Frontend Developer",
      "company": "Infosys",
      "distance": "3.2 km",
      "salary": "₹35,000 - ₹50,000",
      "logoText": "F",
      "logoColor": GenZ.mint,
      "logoUrl": "https://logo.clearbit.com/infosys.com",
      "skills": ["Flutter", "JavaScript", "React"],
      "isUrgent": true,
      "isNew": true,
      "isWalkIn": false,
      "isPremium": true,
      "isPartTime": false,
      "isWFH": true,
    },
    {
      "title": "Backend Developer",
      "company": "TCS",
      "distance": "2.9 km",
      "salary": "₹38,000 - ₹55,000",
      "logoText": "B",
      "logoColor": GenZ.pink,
      "logoUrl": "https://logo.clearbit.com/tcs.com",
      "skills": ["Node.js", "Java"],
      "isUrgent": false,
      "isNew": false,
      "isWalkIn": false,
      "isPremium": false,
      "isPartTime": false,
      "isWFH": false,
    },
    {
      "title": "Delivery Executive",
      "company": "Swiggy",
      "distance": "1.2 km",
      "salary": "₹15,000 - ₹20,000",
      "logoText": "D",
      "logoColor": GenZ.lavender,
      "logoUrl": "https://logo.clearbit.com/swiggy.com",
      "skills": ["Driving", "Delivery"],
      "isUrgent": true,
      "isNew": false,
      "isWalkIn": true,
      "isPremium": false,
      "isPartTime": true,
      "isWFH": false,
    },
    {
      "title": "Data Entry Operator",
      "company": "Wipro",
      "distance": "4.0 km",
      "salary": "₹12,000 - ₹18,000",
      "logoText": "W",
      "logoColor": GenZ.purple,
      "logoUrl": "https://logo.clearbit.com/wipro.com",
      "skills": ["Typing", "MS Office"],
      "isUrgent": false,
      "isNew": true,
      "isWalkIn": false,
      "isPremium": false,
      "isPartTime": true,
      "isWFH": true,
    },
    {
      "title": "Customer Support Executive",
      "company": "Airtel",
      "distance": "2.1 km",
      "salary": "₹18,000 - ₹24,000",
      "logoText": "A",
      "logoColor": GenZ.coral,
      "logoUrl": "https://logo.clearbit.com/airtel.in",
      "skills": ["Calling", "English"],
      "isUrgent": false,
      "isNew": true,
      "isWalkIn": true,
      "isPremium": false,
      "isPartTime": false,
      "isWFH": false,
    },
    {
      "title": "Content Writer",
      "company": "Byju's",
      "distance": "3.5 km",
      "salary": "₹12,000 - ₹16,000",
      "logoText": "B",
      "logoColor": GenZ.purple,
      "logoUrl": "https://logo.clearbit.com/byjus.com",
      "skills": ["Writing", "SEO"],
      "isUrgent": false,
      "isNew": false,
      "isWalkIn": false,
      "isPremium": false,
      "isPartTime": true,
      "isWFH": false,
    },
    {
      "title": "Graphic Designer",
      "company": "Canva",
      "distance": "5.0 km",
      "salary": "₹20,000 - ₹28,000",
      "logoText": "C",
      "logoColor": GenZ.pink,
      "logoUrl": "https://logo.clearbit.com/canva.com",
      "skills": ["Figma", "Photoshop"],
      "isUrgent": false,
      "isNew": false,
      "isWalkIn": false,
      "isPremium": true,
      "isPartTime": false,
      "isWFH": true,
    },
    {
      "title": "Flutter Developer",
      "company": "Razorpay",
      "distance": "1.5 km",
      "salary": "₹40,000 - ₹55,000",
      "logoText": "R",
      "logoColor": GenZ.mint,
      "logoUrl": "https://logo.clearbit.com/razorpay.com",
      "skills": ["Flutter", "Dart"],
      "isUrgent": true,
      "isNew": true,
      "isWalkIn": false,
      "isPremium": true,
      "isPartTime": false,
      "isWFH": false,
    },
    {
      "title": "Telecaller",
      "company": "HDFC Bank",
      "distance": "1.9 km",
      "salary": "₹15,000 - ₹22,000",
      "logoText": "H",
      "logoColor": GenZ.purple,
      "logoUrl": "https://logo.clearbit.com/hdfcbank.com",
      "skills": ["Calling", "Sales"],
      "isUrgent": false,
      "isNew": false,
      "isWalkIn": true,
      "isPremium": false,
      "isPartTime": false,
      "isWFH": false,
    },
  ];

  // ── TOP LOCAL EMPLOYERS (static demo data) ────────────
  final topEmployers = [
    {
      "name": "Zoho",
      "logoUrl": "https://logo.clearbit.com/zoho.com",
      "openings": 12,
      "color": GenZ.purple,
    },
    {
      "name": "Infosys",
      "logoUrl": "https://logo.clearbit.com/infosys.com",
      "openings": 34,
      "color": GenZ.mint,
    },
    {
      "name": "TCS",
      "logoUrl": "https://logo.clearbit.com/tcs.com",
      "openings": 21,
      "color": GenZ.pink,
    },
    {
      "name": "Reliance",
      "logoUrl": "https://logo.clearbit.com/reliancedigital.in",
      "openings": 8,
      "color": GenZ.coral,
    },
    {
      "name": "Swiggy",
      "logoUrl": "https://logo.clearbit.com/swiggy.com",
      "openings": 15,
      "color": GenZ.lavender,
    },
    {
      "name": "Wipro",
      "logoUrl": "https://logo.clearbit.com/wipro.com",
      "openings": 19,
      "color": GenZ.purple,
    },
    {
      "name": "HDFC Bank",
      "logoUrl": "https://logo.clearbit.com/hdfcbank.com",
      "openings": 27,
      "color": GenZ.coral,
    },
    {
      "name": "Airtel",
      "logoUrl": "https://logo.clearbit.com/airtel.in",
      "openings": 14,
      "color": GenZ.mint,
    },
    {
      "name": "Tech Mahindra",
      "logoUrl": "https://logo.clearbit.com/techmahindra.com",
      "openings": 18,
      "color": GenZ.pink,
    },
    {
      "name": "Flipkart",
      "logoUrl": "https://logo.clearbit.com/flipkart.com",
      "openings": 25,
      "color": GenZ.lavender,
    },
  ];

  // ── CAREER TIPS (static demo data) ─────────────────────
  final careerTips = [
    {
      "icon": Icons.description_rounded,
      "title": "Perfect Your Resume",
      "subtitle": "Tips to make your resume stand out",
      "color": GenZ.purple,
    },
    {
      "icon": Icons.record_voice_over_rounded,
      "title": "Ace The Interview",
      "subtitle": "Common questions & how to answer",
      "color": GenZ.coral,
    },
    {
      "icon": Icons.trending_up_rounded,
      "title": "Upskill Yourself",
      "subtitle": "Courses to boost your career",
      "color": GenZ.mint,
    },
    {
      "icon": Icons.handshake_rounded,
      "title": "Networking Tips",
      "subtitle": "Build connections that matter",
      "color": GenZ.pink,
    },
  ];

  // ── HOME PERSONALIZATION: mock user profile used to drive recommendations ──
  // Real app madhe he backend/API varun yeil (candidate profile, resume, activity)
  final userProfile = {
    "skills": ["Flutter", "UI Design", "Figma"],
    "experience": "2 years",
    "education": "B.Tech Computer Science",
    "preferredRole": "Frontend Developer",
    "currentLocation": "Amravati, Maharashtra",
    "preferredLocation": "Amravati, Maharashtra",
    "radiusKm": 5,
    "salaryExpectation": 25000,
    "employmentPreference": "Full-time",
    "previousSearches": ["UI Designer", "Flutter Developer"],
    "savedJobTitles": ["Frontend Developer"],
    "appliedJobTitles": <String>[],
  };

  /// Simple scoring: skills overlap + preferred-role match.
  /// (location/radius/salary/employment-preference/search-history/saved/applied
  /// jobs can plug in here the same way once real data/API is available.)
  int _recommendationScore(Map<String, dynamic> job) {
    int score = 0;
    final jobSkills = (job["skills"] as List).cast<String>();
    final userSkills = (userProfile["skills"] as List).cast<String>();
    score += jobSkills.where((s) => userSkills.contains(s)).length * 2;
    if (job["title"] == userProfile["preferredRole"]) score += 3;
    if (job["isPremium"] == true) score += 1;
    return score;
  }

  List<Map<String, dynamic>> get _recommendedJobs {
    final sorted = List<Map<String, dynamic>>.from(jobs);
    sorted.sort(
      (a, b) => _recommendationScore(b).compareTo(_recommendationScore(a)),
    );
    return sorted.take(3).toList();
  }

  List<Map<String, dynamic>> get _skillMatchedJobs {
    final userSkills = (userProfile["skills"] as List).cast<String>();
    return jobs
        .where(
          (j) => (j["skills"] as List).cast<String>().any(
            (s) => userSkills.contains(s),
          ),
        )
        .take(2)
        .toList();
  }

  List<Map<String, dynamic>> get _jobsNearYou => jobs.take(3).toList();
  List<Map<String, dynamic>> get _urgentJobs =>
      jobs.where((j) => j["isUrgent"] == true).take(4).toList();
  List<Map<String, dynamic>> get _recentJobs =>
      jobs.where((j) => j["isNew"] == true).take(3).toList();
  List<Map<String, dynamic>> get _walkInJobs =>
      jobs.where((j) => j["isWalkIn"] == true).take(2).toList();
  List<Map<String, dynamic>> get _partTimeJobsList =>
      jobs.where((j) => j["isPartTime"] == true).take(3).toList();
  List<Map<String, dynamic>> get _wfhJobsList =>
      jobs.where((j) => j["isWFH"] == true).take(2).toList();
  List<Map<String, dynamic>> get _premiumJobsList =>
      jobs.where((j) => j["isPremium"] == true).take(3).toList();

  @override
  Widget build(BuildContext context) {
    // ── LIVE SEARCH: filter jobs by title or company as you type ──
    final filteredJobs = _searchQuery.isEmpty
        ? jobs
        : jobs.where((job) {
            final title = (job["title"] as String).toLowerCase();
            final company = (job["company"] as String).toLowerCase();
            return title.contains(_searchQuery) ||
                company.contains(_searchQuery);
          }).toList();

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarOverlapSpacer = (132.0 + statusBarHeight) - 28.0;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 72.0,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          child: Container(
            decoration: const BoxDecoration(gradient: GenZ.headerGradient),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TapScale(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
        leadingWidth: 58,
        centerTitle: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/new_splash_logo.png",
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 14),
          ],
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── NOTIFICATION BUTTON ──
              TapScale(
                onTap: () {
                  setState(() => _hasNewNotification = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationPage()),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        if (_hasNewNotification)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (context, child) {
                                return Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: GenZ.coral.withOpacity(
                                          _pulseAnim.value * 0.9,
                                        ),
                                        blurRadius: 6 * _pulseAnim.value,
                                        spreadRadius: 1 * _pulseAnim.value,
                                      ),
                                    ],
                                    color: GenZ.coral.withOpacity(
                                      _pulseAnim.value,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // ── LOCATION BUTTON ──
              TapScale(
                onTap: () {
                  _showLocationSelectionDialog();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      width: 60,
                      child: Text(
                        _selectedLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: 8.0,
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: !_isSearchExpanded
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Hi, $userFirstName ",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _waveAnim,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _waveAnim.value,
                                      alignment: Alignment.bottomCenter,
                                      child: child,
                                    );
                                  },
                                  child: const Text(
                                    "👋",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Find your dream job near you",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        TapScale(
                          onTap: () {
                            setState(() {
                              _isSearchExpanded = true;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: GenZ.purple.withOpacity(0.18),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: GenZ.purple.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: GenZ.purple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                              decoration: const InputDecoration(
                                hintText: "Search jobs, skills, companies...",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          TapScale(
                            onTap: () {
                              setState(() {
                                _isSearchExpanded = false;
                                _searchController.clear();
                              });
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.grey,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),

      // ── DRAWER (opens via profile avatar tap) ────────────
      drawer: Drawer(
        width: 280,
        backgroundColor: AppColors.background,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                // ── PURPLE GRADIENT (solid removed) ──
                decoration: const BoxDecoration(gradient: GenZ.drawerGradient),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ── decorative purple blobs for extra depth ──
                    Positioned(
                      top: -30,
                      right: -30,
                      child: _HeaderBlob(
                        size: 90,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: _HeaderBlob(
                        size: 70,
                        color: GenZ.lavender.withOpacity(0.18),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 1.5,
                                ),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=150&auto=format&fit=crop",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    userName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userEmail,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: AppColors.divider, height: 1, thickness: 1),

              // ── SCROLLABLE MIDDLE SECTION ─────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // _drawerTile(
                      //   Icons.home_outlined,
                      //   "Home",
                      //   AppColors.primary,
                      //   () {},
                      // ),
                      _drawerTile(
                        Icons.category_outlined,
                        "Categories",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoriesPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.thumb_up_alt_outlined,
                        "Recommended Job",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RecommendedJobPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.bookmark_border_rounded,
                        "Saved Job",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavedJobPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.account_balance_wallet_outlined,
                        "Wallect & premium",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WalletPremiumPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.school_outlined,
                        "Learning Career",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LearningCareerPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.explore_outlined,
                        "Jobs Near You",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const HyperlocalFeaturesPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.person_outline_rounded,
                        "My Profile",
                        AppColors.primary,
                        () {},
                      ),
                      _drawerTile(
                        Icons.settings_outlined,
                        "Settings",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.help_outline_rounded,
                        "help Center",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpCenterPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.confirmation_number_outlined,
                        "Support Tickets",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SupportTicketsPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.article_outlined,
                        "Cover Letters",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CoverLettersPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.info_outline_rounded,
                        "About App",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutAppPage(),
                            ),
                          );
                        },
                      ),
                      _drawerTile(
                        Icons.filter_alt_outlined,
                        "miss opportunity",
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MissOpportunityPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── FIXED BOTTOM: LOGOUT ──────────────────────
              const Divider(color: AppColors.divider, height: 1, thickness: 1),
              _drawerTile(
                Icons.logout_rounded,
                "Logout",
                const Color.fromARGB(255, 226, 30, 30),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),

      // ── OVERALL PAGE BACKGROUND: GRADIENT ──
      body: Container(
        decoration: const BoxDecoration(
          gradient: GenZ.pageBackgroundGradient,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: appBarOverlapSpacer),
                // ── VISUAL SLIDER ──
                _buildImageSlider(),

                const SizedBox(height: 18),

                // ── QUICK ACTIONS (BUILD RESUME & NEARBY JOBS STACKED VERTICALLY IN IMAGE STYLE) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Card 1: Build Resume
                      _imageStyleCard(
                        title: "Build Resume",
                        subtitle1: "AI-Powered Builder",
                        subtitle2: "Score 75% • Completed (18/24)",
                        progressValue: 0.75,
                        progressText: "75%",
                        icon: Icons.description_rounded,
                        iconColor: const Color(0xFFFF4096),
                        iconBgColor: const Color(0xFFFF4096),
                        buttonText: "Continue",
                        buttonGradient: const LinearGradient(
                          colors: [Color(0xFFFF4096), Color(0xFFC77DFF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        cardBackgroundGradient: const LinearGradient(
                          colors: [Color(0xFF3A122B), Color(0xFF1C0815)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ResumeScorePage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      // Card 2: Nearby Jobs
                      _imageStyleCard(
                        title: "Nearby Jobs",
                        subtitle1: "Explore in $_selectedLocation",
                        subtitle2: "15+ new jobs match your profile",
                        progressValue: 0.90,
                        progressText: "90%",
                        icon: Icons.location_on_rounded,
                        iconColor: const Color(0xFFFF9E00),
                        iconBgColor: const Color(0xFFFF9E00),
                        buttonText: "Explore",
                        buttonGradient: const LinearGradient(
                          colors: [Color(0xFFFF9E00), Color(0xFF00D2FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        cardBackgroundGradient: const LinearGradient(
                          colors: [Color(0xFF0B2B26), Color(0xFF051513)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JobNearMapPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tops Categories",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoriesPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "See All",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── EXPLORE CATEGORIES HORIZONTAL CARDS (Ranked) ──
                SizedBox(
                  height: 135,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      final color = item["color"] as Color;
                      final label = item["label"] as String;
                      final openings = item["openings"] as String;
                      final isFirst = true; // Make all cards use the first/large card size
                      
                      return TapScale(
                        onTap: () {
                          if (label == "More") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoriesPage(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RecommendedJobPage(),
                              ),
                            );
                          }
                        },
                        child: SizedBox(
                          width: isFirst ? 230 : 170,
                          height: 135,
                          child: Stack(
                            children: [
                              // Huge Rank Number on the left background matching the category color
                              Positioned(
                                left: 5,
                                bottom: -5,
                                child: Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                    fontSize: isFirst ? 90 : 78,
                                    fontWeight: FontWeight.w900,
                                    color: color.withOpacity(0.16),
                                    height: 1.0,
                                  ),
                                ),
                              ),
                              // The Card container overlapping the rank number
                              Positioned(
                                left: isFirst ? 55 : 45,
                                top: 4,
                                bottom: 4,
                                right: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withOpacity(0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                    gradient: LinearGradient(
                                      colors: [
                                        color,
                                        color.withOpacity(0.75),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    children: [
                                      // ── CATEGORY BACKGROUND IMAGE ──
                                      if (item["bgImage"] != null)
                                        Positioned.fill(
                                          child: Opacity(
                                            opacity: 0.22,
                                            child: Image.network(
                                              item["bgImage"] as String,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                            ),
                                          ),
                                        ),
                                      // Large background icon with low opacity
                                      Positioned(
                                        right: -10,
                                        bottom: -10,
                                        child: Icon(
                                          item["icon"] as IconData,
                                          size: isFirst ? 85 : 68,
                                          color: Colors.white.withOpacity(0.12),
                                        ),
                                      ),
                                      // Content Column placing text immediately after icon
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Top Row (Icon Badge & Arrow)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: isFirst ? 38 : 32,
                                                  height: isFirst ? 38 : 32,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.1),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    item["icon"] as IconData,
                                                    color: color,
                                                    size: isFirst ? 18 : 15,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(
                                                    Icons.arrow_forward_ios_rounded,
                                                    color: Colors.white,
                                                    size: isFirst ? 11 : 9.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: isFirst ? 12 : 8),
                                            Text(
                                              label,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: isFirst ? 15.5 : 13.5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Container(
                                                  width: isFirst ? 14 : 10,
                                                  height: 2.5,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.6),
                                                    borderRadius: BorderRadius.circular(1),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    openings,
                                                    style: TextStyle(
                                                      fontSize: isFirst ? 11.5 : 9.5,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.white.withOpacity(0.9),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 4),

                // ── SEARCH RESULTS (when typing) OR HOME SECTIONS (default) ──
                if (_searchQuery.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _sectionHeader("Search Results"),
                  ),
                  if (filteredJobs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 40,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No jobs found for "${_searchController.text}"',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredJobs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final job = filteredJobs[index];
                          return _jobCard(
                            title: job["title"] as String,
                            company: job["company"] as String,
                            distance: job["distance"] as String,
                            salary: job["salary"] as String,
                            logoText: job["logoText"] as String,
                            logoColor: job["logoColor"] as Color,
                            logoUrl: job["logoUrl"] as String,
                          );
                        },
                      ),
                    ),
                ] else ...[
                  _horizontalSection(
                    title: "Urgent Hiring",
                    sectionJobs: _urgentJobs,
                    cardBuilder: _urgentHiringCard,
                    height: 112,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommendedJobPage(),
                      ),
                    ),
                  ),
                  _verticalSection(
                    title: "Jobs Near You",
                    sectionJobs: _jobsNearYou,
                    cardBuilder: (job, {badgeColor, badgeText}) => _jobsNearYouCard(
                      job,
                      badgeText: badgeText,
                      badgeColor: badgeColor,
                      width: double.infinity,
                    ),
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JobNearMapPage()),
                    ),
                  ),
                  _horizontalSection(
                    title: "Premium Jobs",
                    sectionJobs: _premiumJobsList,
                    cardBuilder: _premiumJobCard,
                    height: 108,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WalletPremiumPage(),
                      ),
                    ),
                  ),
                  _verticalSection(
                    title: "Recently Posted",
                    sectionJobs: _recentJobs,
                    cardBuilder: (job, {badgeColor, badgeText}) => _recentlyPostedCard(
                      job,
                      badgeText: badgeText,
                      badgeColor: badgeColor,
                      width: double.infinity,
                    ),
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommendedJobPage(),
                      ),
                    ),
                  ),
                  _horizontalSection(
                    title: "Walk-in Interviews",
                    sectionJobs: _walkInJobs,
                    cardBuilder: _walkInCard,
                    height: 112,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommendedJobPage(),
                      ),
                    ),
                  ),
                  _horizontalSection(
                    title: "Part-Time Jobs",
                    sectionJobs: _partTimeJobsList,
                    cardBuilder: _partTimeCard,
                    height: 112,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PartTimeJobPage(),
                      ),
                    ),
                  ),
                  _verticalSection(
                    title: "Work From Home",
                    sectionJobs: _wfhJobsList,
                    cardBuilder: (job, {badgeColor, badgeText}) => _wfhCard(
                      job,
                      badgeText: badgeText,
                      badgeColor: badgeColor,
                      width: double.infinity,
                    ),
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkFromHomePage(),
                      ),
                    ),
                  ),
                  _horizontalSection(
                    title: "Jobs Matching Your Skills",
                    sectionJobs: _skillMatchedJobs,
                    cardBuilder: _compactJobCard2,
                    badgeText: "Skill Match",
                    badgeColor: GenZ.lavender,
                    height: 108,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommendedJobPage(),
                      ),
                    ),
                  ),

                  // ── TOP LOCAL EMPLOYERS ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _sectionHeader(
                            "Top Local Employers",
                            onViewAll: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CategoriesPage(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            clipBehavior: Clip.none,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: topEmployers.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 4),
                            itemBuilder: (context, index) =>
                                _employerCard(topEmployers[index]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── CAREER TIPS ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _sectionHeader(
                            "Career Tips",
                            onViewAll: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LearningCareerPage(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 110,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            clipBehavior: Clip.none,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: careerTips.take(2).length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 4),
                            itemBuilder: (context, index) =>
                                _careerTipCard(careerTips[index]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 70),
                ],
              ],
            ),
          ),
        ),
      ),

      // ── BOTTOM NAVIGATION BAR (FLOATING STYLE WITH GLASSMORPHISM OPACITY) ──
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

  // ── VISUAL SLIDER HELPER ───────────────────────────────────────────
  Widget _buildImageSlider() {
    return Column(
      children: [
        SizedBox(
          height: 188,
          child: PageView.builder(
            controller: _sliderPageController,
            onPageChanged: (int index) {
              setState(() {
                _currentSliderPage = index;
              });
            },
            itemCount: sliderItems.length,
            itemBuilder: (context, index) {
              final item = sliderItems[index];
              return AnimatedBuilder(
                animation: _sliderPageController,
                builder: (context, child) {
                  return TapScale(
                    onTap: () {
                      if (item["route"] == "gov") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GovernmentJobPage(),
                          ),
                        );
                      } else if (item["route"] == "mock") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MockInterviewPage(),
                          ),
                        );
                      } else if (item["route"] == "parttime") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PartTimeJobPage(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: item["gradient"] as LinearGradient,
                        borderRadius: BorderRadius.zero,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // ── BANNER POSTER BACKGROUND IMAGE OR VIDEO ──
                          Positioned.fill(
                            child: item["isVideo"] == true
                                ? SliderVideoPlayer(
                                    videoPath: item["videoUrl"] ?? item["videoPath"] ?? "",
                                    isNetwork: item["isNetworkVideo"] == true,
                                    isAsset: item["isAssetVideo"] == true,
                                  )
                                : (item["isLocalImage"] == true
                                    ? Image.file(
                                        File(item["image"] as String),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        item["image"] as String,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            color: Colors.black12,
                                            child: const Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: item["gradient"] as LinearGradient,
                                            ),
                                          );
                                        },
                                      )),
                          ),
                          // Dark gradient overlay for typography readability
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.85),
                                    Colors.black.withOpacity(0.2),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                          ),
                          // Background design circles
                          Positioned(
                            right: -20,
                            top: -20,
                            child: CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          Positioned(
                            right: 30,
                            bottom: -30,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          // A light blue circle matching the uploaded image theme on the right
                          Positioned(
                            right: 15,
                            top: 48,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFFBFEFFF).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // The main illustrative icon on the right side of the poster banner
                          Positioned(
                            right: 32,
                            top: 65,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.22),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item["icon"] as IconData,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                          // Upload button overlay (visible on the top right)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: _uploadSliderMedia,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white24, width: 1),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      "Upload",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Content Column placing text immediately after icon
                          Padding(
                            padding: const EdgeInsets.only(left: 24, right: 24, top: 44, bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    item["badge"] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item["title"] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item["subtitle"] as String,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Explore Now",
                                        style: TextStyle(
                                          color: (item["gradient"] as LinearGradient).colors[0],
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: (item["gradient"] as LinearGradient).colors[0],
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            sliderItems.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: _currentSliderPage == index ? 18 : 6,
              decoration: BoxDecoration(
                color: _currentSliderPage == index
                    ? AppColors.primary
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── SECTION HEADER HELPER (title + optional "View all") ──────────────
  Widget _sectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [GenZ.purple, GenZ.pink],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          if (onViewAll != null)
            TapScale(
              onTap: onViewAll,
              child: const Text(
                "View all",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: GenZ.purpleDark,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── REUSABLE HORIZONTAL JOB SECTION (used by all Home Sections) ──────
  // Each section now takes its own `cardBuilder` so every section can have
  // a visually distinct card design, and the vertical gap between sections
  // has been trimmed down to tighten up the layout to match the reference design.
  Widget _horizontalSection({
    required String title,
    required List<Map<String, dynamic>> sectionJobs,
    required Widget Function(
      Map<String, dynamic> job, {
      String? badgeText,
      Color? badgeColor,
    })
    cardBuilder,
    VoidCallback? onViewAll,
    String? badgeText,
    Color? badgeColor,
    double height = 150,
  }) {
    if (sectionJobs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _sectionHeader(title, onViewAll: onViewAll),
          ),
          SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: sectionJobs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final job = sectionJobs[index];
                return cardBuilder(
                  job,
                  badgeText: badgeText,
                  badgeColor: badgeColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── REUSABLE VERTICAL JOB SECTION ───────────────────────────────────
  Widget _verticalSection({
    required String title,
    required List<Map<String, dynamic>> sectionJobs,
    required Widget Function(
      Map<String, dynamic> job, {
      String? badgeText,
      Color? badgeColor,
    })
    cardBuilder,
    VoidCallback? onViewAll,
    String? badgeText,
    Color? badgeColor,
  }) {
    if (sectionJobs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _sectionHeader(title, onViewAll: onViewAll),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sectionJobs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final job = sectionJobs[index];
                return cardBuilder(
                  job,
                  badgeText: badgeText,
                  badgeColor: badgeColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── CUSTOM GRADIENT GLOW CARD HELPER (IMAGE STYLE) ─────────────────────
  Widget _imageStyleCard({
    required String title,
    required String subtitle1,
    required String subtitle2,
    required double progressValue,
    required String progressText,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String buttonText,
    required LinearGradient buttonGradient,
    required LinearGradient cardBackgroundGradient,
    required VoidCallback onTap,
  }) {
    return TapScale(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: cardBackgroundGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rounded square icon container with matching borders
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBgColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: iconBgColor.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle1,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle2,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Continue / Explore Button
                Container(
                  decoration: BoxDecoration(
                    gradient: buttonGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: buttonGradient.colors.first.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Progress",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  progressText,
                  style: const TextStyle(
                    color: Color(0xFFFF4096),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Progress Bar
            Container(
              height: 4.5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(2.25),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressValue,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: buttonGradient.colors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── QUICK ACTION UNIFORM CARD HELPER ─────────────────────────────────
  Widget _quickActionCard({
    required String title,
    String? subtitleText,
    Widget? subtitleWidget,
    required String badgeText,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
    double width = double.infinity,
    double height = 104,
  }) {
    return TapScale(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            if (subtitleWidget != null)
              subtitleWidget
            else if (subtitleText != null)
              Text(
                subtitleText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ══════════════════════════════════════════════════════════════════
  // 1) JOBS NEAR YOU — Location pin radar accent, soft blue theme
  // ══════════════════════════════════════════════════════════════════
  Widget _jobsNearYouCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
    double width = 195,
  }) {
    final Color color = job["logoColor"] as Color;
    return Tap3D(
      onTap: () {},
      builder: (pressed) {
        return Container(
          width: width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              topLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(
              color: color.withOpacity(pressed ? 0.35 : 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  job["logoUrl"] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      job["logoText"] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      job["title"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job["company"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job["salary"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.near_me_rounded, size: 8, color: color),
                    const SizedBox(width: 2),
                    Text(
                      job["distance"] as String,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 2) URGENT HIRING — Notched Alert Card with Solid Coral Left Bar
  // ══════════════════════════════════════════════════════════════════
  Widget _urgentHiringCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
  }) {
    return Tap3D(
      onTap: () {},
      builder: (pressed) {
        return Container(
          width: 155,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7F6),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(
              color: GenZ.coral.withOpacity(pressed ? 0.40 : 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: GenZ.coral.withOpacity(0.06),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22.8),
              topRight: Radius.circular(22.8),
              bottomLeft: Radius.circular(2.8),
              bottomRight: Radius.circular(2.8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: GenZ.coral),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text("🔥", style: TextStyle(fontSize: 11)),
                            SizedBox(width: 2),
                            Text(
                              "URGENT",
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: GenZ.coral,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job["title"] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          job["company"] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          job["salary"] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: GenZ.coral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 3) RECOMMENDED FOR YOU — Super-Rounded Oval Squircle Shape
  // ══════════════════════════════════════════════════════════════════
  // Widget _recommendedForYouCard(
  //   Map<String, dynamic> job, {
  //   String? badgeText,
  //   Color? badgeColor,
  // }) {
  //   return Tap3D(
  //     onTap: () {},
  //     builder: (pressed) {
  //       return Container(
  //         width: 160,
  //         padding: const EdgeInsets.all(12),
  //         decoration: BoxDecoration(
  //           gradient: const LinearGradient(
  //             colors: [Color(0xFFFAF8FF), Colors.white],
  //             begin: Alignment.topCenter,
  //             end: Alignment.bottomCenter,
  //           ),
  //           borderRadius: BorderRadius.circular(18),
  //           border: Border.all(
  //             color: GenZ.purple.withOpacity(pressed ? 0.35 : 0.15),
  //             width: 1.2,
  //           ),
  //           boxShadow: [
  //             BoxShadow(
  //               color: GenZ.purple.withOpacity(0.06),
  //               blurRadius: 5,
  //               offset: const Offset(0, 2),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 6,
  //                 vertical: 2.5,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: GenZ.purple,
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: const Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(
  //                     Icons.auto_awesome_rounded,
  //                     size: 9,
  //                     color: Colors.white,
  //                   ),
  //                   SizedBox(width: 2),
  //                   Text(
  //                     "AI PICK",
  //                     style: TextStyle(
  //                       fontSize: 8.5,
  //                       fontWeight: FontWeight.w900,
  //                       color: Colors.white,
  //                       letterSpacing: 0.3,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               job["title"] as String,
  //               maxLines: 1,
  //               overflow: TextOverflow.ellipsis,
  //               style: const TextStyle(
  //                 fontSize: 13,
  //                 fontWeight: FontWeight.w700,
  //                 color: AppColors.textPrimary,
  //               ),
  //             ),
  //             const SizedBox(height: 3),
  //             Text(
  //               job["company"] as String,
  //               maxLines: 1,
  //               overflow: TextOverflow.ellipsis,
  //               style: const TextStyle(
  //                 fontSize: 11,
  //                 fontWeight: FontWeight.w500,
  //                 color: AppColors.textSecondary,
  //               ),
  //             ),
  //             const SizedBox(height: 6),
  //             Text(
  //               job["salary"] as String,
  //               maxLines: 1,
  //               overflow: TextOverflow.ellipsis,
  //               style: const TextStyle(
  //                 fontSize: 11.5,
  //                 fontWeight: FontWeight.w800,
  //                 color: GenZ.purple,
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // ══════════════════════════════════════════════════════════════════
  // 4) RECENTLY POSTED — Sharp Minimal Rectangular Ticket Shape (NO GREEN NEW BADGE)
  // ══════════════════════════════════════════════════════════════════
  Widget _recentlyPostedCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
    double width = 195,
  }) {
    final String initial = (job["company"] as String? ?? "C").substring(0, 1).toUpperCase();
    return Tap3D(
      onTap: () {},
      builder: (pressed) {
        return Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(
              color: const Color(0xFF64748B).withOpacity(pressed ? 0.30 : 0.14),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      job["title"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      job["company"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "JUST IN",
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    job["salary"] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 5) WALK-IN INTERVIEWS — Dashed Border Event Pass Coupon Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _walkInCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
  }) {
    const indigo = Color(0xFF4F46E5);
    return Tap3D(
      onTap: () {},
      builder: (pressed) {
        return Container(
          width: 185,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F3FF),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(
              color: indigo.withOpacity(pressed ? 0.40 : 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: indigo.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: indigo,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.confirmation_number_rounded,
                          size: 9.5,
                          color: Colors.white,
                        ),
                        SizedBox(width: 2),
                        Text(
                          "WALK-IN",
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                job["title"] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                job["company"] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                job["salary"] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: indigo,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 6) PART-TIME JOBS — Bubble Pill Capsule Oval Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _partTimeCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
  }) {
    const amber = Color(0xFFD97706);
    return Tap3D(
      onTap: () {},
      builder: (pressed) {
        return Container(
          width: 195,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: amber.withOpacity(pressed ? 0.35 : 0.16),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: amber.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: amber.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: amber,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      job["title"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      job["company"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job["salary"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 7) WORK FROM HOME — Diagonal Cut Corner Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _wfhCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
    double width = 195,
  }) {
    return Tap3D(
      onTap: () {},
      builder: (pressed) {
        return Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              topLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(
              color: GenZ.mint.withOpacity(pressed ? 0.35 : 0.16),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: GenZ.mint.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: GenZ.mint.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_rounded,
                  size: 22,
                  color: GenZ.mint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      job["title"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      job["company"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: GenZ.mint,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "REMOTE",
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    job["salary"] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: GenZ.mint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 8) JOBS MATCHING YOUR SKILLS — Inverted Top-Left Corner Badge Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _compactJobCard2(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
  }) {
    final List<String> skills = (job["skills"] as List?)?.cast<String>() ?? [];
    final String firstSkill = skills.isNotEmpty ? skills.first : "Skill Match";

    final String titleLower = (job["title"] as String? ?? "").toLowerCase();
    String bgImgUrl =
        "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400&auto=format&fit=crop";
    if (titleLower.contains("developer") ||
        titleLower.contains("flutter") ||
        titleLower.contains("code") ||
        titleLower.contains("tech")) {
      bgImgUrl =
          "https://images.unsplash.com/photo-1634017839464-5c339ebe3cb4?q=80&w=400&auto=format&fit=crop";
    } else if (titleLower.contains("design") ||
        titleLower.contains("ui") ||
        titleLower.contains("ux")) {
      bgImgUrl =
          "https://images.unsplash.com/photo-1618005198143-e5283b519a7f?q=80&w=400&auto=format&fit=crop";
    } else if (titleLower.contains("sales") ||
        titleLower.contains("marketing") ||
        titleLower.contains("manager")) {
      bgImgUrl =
          "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=400&auto=format&fit=crop";
    } else if (titleLower.contains("delivery") ||
        titleLower.contains("driver")) {
      bgImgUrl =
          "https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=400&auto=format&fit=crop";
    }

    return Tap3D(
      onTap: () {},
      builder: (pressed) {
        return Container(
          width: 195,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            image: DecorationImage(
              image: NetworkImage(bgImgUrl),
              fit: BoxFit.cover,
              opacity: 0.28,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E1B4B), // Deep Indigo
                Color(0xFF3B0764), // Deep Purple
              ],
            ),
            border: Border.all(
              color: GenZ.lavender.withOpacity(pressed ? 0.50 : 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: GenZ.lavender.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      job["title"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      job["company"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFC7D2FE), // light indigo
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        firstSkill,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 9) TOP LOCAL EMPLOYERS — Circular Capsule Badge Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _employerCard(Map<String, dynamic> employer) {
    final color = employer["color"] as Color;
    return TapScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CategoriesPage()),
        );
      },
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.15), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                employer["logoUrl"] as String,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.business_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            Text(
              employer["name"] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${employer["openings"]} open",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 10) CAREER TIPS — Micro-article Ticket Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _careerTipCard(Map<String, dynamic> tip) {
    final color = tip["color"] as Color;
    return TapScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LearningCareerPage()),
        );
      },
      child: Container(
        width: 190,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.12),
                  ),
                  child: Icon(tip["icon"] as IconData, color: color, size: 16),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "2 min read",
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tip["title"] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tip["subtitle"] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 11) PREMIUM JOBS — Gold Beveled VIP Frame Shape
  // ══════════════════════════════════════════════════════════════════
  Widget _premiumJobCard(
    Map<String, dynamic> job, {
    String? badgeText,
    Color? badgeColor,
  }) {
    const gold = Color(0xFFB8860B);
    const goldDark = Color(0xFF8B6508);

    return Tap3D(
      onTap: () {},
      builder: (pressed) {
        return Container(
          width: 165,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFDF5), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(
              color: gold.withOpacity(pressed ? 0.45 : 0.22),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: gold.withOpacity(0.08),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [gold, goldDark]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("👑", style: TextStyle(fontSize: 9)),
                        SizedBox(width: 2),
                        Text(
                          "PREMIUM",
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job["title"] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                job["company"] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                job["salary"] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: goldDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── JOB CARD HELPER — 3D NEUMORPHIC / "POP-OUT" STYLE (used in search results) ──
  Widget _jobCard({
    required String title,
    required String company,
    required String distance,
    required String salary,
    required String logoText,
    required Color logoColor,
    required String logoUrl,
  }) {
    return Tap3D(
      onTap: () {},
      builder: (pressed) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: logoColor.withOpacity(pressed ? 0.30 : 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: logoColor,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  logoUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: Text(
                        logoText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        logoText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          "$company • ",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: logoColor,
                        ),
                        const SizedBox(width: 1),
                        Text(
                          distance,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: logoColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.currency_rupee_rounded,
                            size: 13,
                            color: logoColor,
                          ),
                          Text(
                            salary.replaceAll("₹", ""),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: logoColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TapScale(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoriesPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: logoColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 16,
                        color: logoColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TapScale(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: logoColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_border_rounded,
                        size: 16,
                        color: logoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
        setState(() => _selectedIndex = index);
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

  // ── DRAWER TILE HELPER (colorful purple-shade icon chip) ────────────
  static Widget _drawerTile(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return TapScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── UPLOAD SLIDER MEDIA HELPER ─────────────────────────────────────────
  Future<void> _uploadSliderMedia() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'mp4', 'mov', 'avi', 'mkv'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final extension = path.split('.').last.toLowerCase();
        final isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(extension);

        setState(() {
          sliderItems.add({
            "title": isVideo ? "Uploaded Video" : "Uploaded Banner",
            "subtitle": "Tap to interact with uploaded banner",
            "badge": isVideo ? "VIDEO" : "IMAGE",
            "gradient": const LinearGradient(
              colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            "icon": isVideo ? Icons.play_circle_fill_rounded : Icons.image_rounded,
            "route": "uploaded_media",
            "isVideo": isVideo,
            "isNetworkVideo": false,
            "videoPath": isVideo ? path : null,
            "image": isVideo ? "https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=600&q=80" : path,
            "isLocalImage": !isVideo,
          });
        });

        // Smoothly animate to the newly uploaded page
        _currentSliderPage = sliderItems.length - 1;
        if (_sliderPageController.hasClients) {
          _sliderPageController.animateToPage(
            _currentSliderPage,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isVideo ? 'Video uploaded successfully!' : 'Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading media: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class AutoScrollJobList extends StatefulWidget {
  final List<Map<String, dynamic>> jobs;
  final Widget Function(Map<String, dynamic>) cardBuilder;
  final double height;

  const AutoScrollJobList({
    super.key,
    required this.jobs,
    required this.cardBuilder,
    this.height = 150,
  });

  @override
  State<AutoScrollJobList> createState() => _AutoScrollJobListState();
}

class _AutoScrollJobListState extends State<AutoScrollJobList> {
  late final ScrollController _controller;
  Timer? _timer;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_controller.hasClients || _userInteracting) return;

      final maxScroll = _controller.position.maxScrollExtent;
      final current = _controller.offset;

      if (current >= maxScroll) {
        _controller.jumpTo(0);
      } else {
        _controller.jumpTo(current + 2.2); // scroll speed — kami/jast kar
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            _userInteracting = true;
          } else if (notification is ScrollEndNotification) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) _userInteracting = false;
            });
          }
          return false;
        },
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: widget.jobs.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: widget.cardBuilder(widget.jobs[index]),
          ),
        ),
      ),
    );
  }
}

/// ── DASHED BORDER PAINTER ─────────────────────────────────────────────
/// Used by the "Walk-in Interviews" card to give it a dashed-outline look
/// that visually differentiates it from every other section's card style.
// ignore: unused_element
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.7, 0.7, size.width - 1.4, size.height - 1.4),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

// ── SLIDER VIDEO PLAYER WIDGET ───────────────────────────────────────────
class SliderVideoPlayer extends StatefulWidget {
  final String videoPath;
  final bool isAsset;
  final bool isNetwork;

  const SliderVideoPlayer({
    super.key,
    required this.videoPath,
    this.isAsset = false,
    this.isNetwork = false,
  });

  @override
  State<SliderVideoPlayer> createState() => _SliderVideoPlayerState();
}

class _SliderVideoPlayerState extends State<SliderVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      if (widget.isNetwork) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
      } else if (widget.isAsset) {
        _controller = VideoPlayerController.asset(widget.videoPath);
      } else {
        _controller = VideoPlayerController.file(File(widget.videoPath));
      }

      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        _controller.setVolume(0.0); // Muted by default for sliders
        _controller.play();
      }
    } catch (e) {
      debugPrint("Error initializing video player: $e");
    }
  }

  @override
  void didUpdateWidget(covariant SliderVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      _controller.dispose();
      _isInitialized = false;
      _initPlayer();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black26,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
            ),
          ),
        ),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
