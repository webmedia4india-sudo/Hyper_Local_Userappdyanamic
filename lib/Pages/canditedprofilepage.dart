import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CandidateProfilePage extends StatefulWidget {
  const CandidateProfilePage({super.key});

  @override
  State<CandidateProfilePage> createState() => _CandidateProfilePageState();
}

class _CandidateProfilePageState extends State<CandidateProfilePage>
    with TickerProviderStateMixin {
  // Entrance animation controller
  late AnimationController _fadeController;

  // Profile avatar pulse controller
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Track expanded cards
  final Set<int> _expandedExperience = {};

  @override
  void initState() {
    super.initState();

    // Entrance animations
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeController.forward();

    // Pulse glow animation around the profile picture
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Helper widget to wrap elements in a staggered fade + slide entrance transition
  Widget _animatedItem({
    required Widget child,
    required double startInterval,
    required double endInterval,
  }) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, childWidget) {
        final double opacity = CurvedAnimation(
          parent: _fadeController,
          curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
        ).value;

        final double translateOffset = Tween<double>(
          begin: 20,
          end: 0,
        ).animate(CurvedAnimation(
          parent: _fadeController,
          curve: Interval(startInterval, endInterval, curve: Curves.easeOutCubic),
        )).value;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateOffset),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }

  // ── STATIC PERSONAL INFO ────────────────────────────────
  final Map<String, String> _personalInfo = const {
    "name": "Gauri Salunkhe",
    "mobile": "+91 98765 43210",
    "email": "gauri.salunkhe@example.com",
    "dob": "14 Aug 2000",
    "gender": "Female",
    "address": "Nagpur, Maharashtra, India",
  };

  // ── STATIC EDUCATION DATA ───────────────────────────────
  final List<Map<String, String>> _education = const [
    {
      "qualification": "B.E. Computer Science",
      "institution": "Government College of Engineering, Nagpur",
      "passingYear": "2021",
      "grade": "8.7 CGPA",
    },
    {
      "qualification": "HSC (12th)",
      "institution": "Modern Junior College, Nagpur",
      "passingYear": "2017",
      "grade": "84%",
    },
  ];

  // ── STATIC EXPERIENCE DATA ──────────────────────────────
  final List<Map<String, String>> _experience = const [
    {
      "company": "TechNova Solutions",
      "designation": "Flutter Developer",
      "startDate": "Jun 2022",
      "endDate": "Present",
      "responsibilities":
          "Building and maintaining multi-role Flutter apps, integrating REST APIs, and collaborating with design team on UI systems.",
    },
    {
      "company": "CodeCraft Pvt Ltd",
      "designation": "Junior Software Developer",
      "startDate": "Jan 2021",
      "endDate": "May 2022",
      "responsibilities":
          "Worked on Angular admin panel modules, fixed UI bugs, and assisted in API integration for internal dashboards.",
    },
  ];

  // ── STATIC SKILLS DATA ──────────────────────────────────
  final List<Map<String, dynamic>> _skills = const [
    {"name": "Flutter", "level": "Expert", "verified": true},
    {"name": "Angular", "level": "Advanced", "verified": true},
    {"name": "Dart", "level": "Expert", "verified": true},
    {"name": "REST API Integration", "level": "Advanced", "verified": false},
    {"name": "Firebase", "level": "Intermediate", "verified": false},
    {"name": "UI/UX Design", "level": "Intermediate", "verified": true},
  ];

  // ── STATIC LANGUAGES DATA ───────────────────────────────
  final List<Map<String, dynamic>> _languages = const [
    {"language": "English", "speaking": 0.9, "reading": 0.95, "writing": 0.85},
    {"language": "Hindi", "speaking": 1.0, "reading": 1.0, "writing": 0.9},
    {"language": "Marathi", "speaking": 1.0, "reading": 1.0, "writing": 1.0},
  ];

  // ── STATIC CERTIFICATES DATA ────────────────────────────
  final List<Map<String, String>> _certificates = const [
    {
      "name": "Flutter Development Bootcamp",
      "organization": "Udemy",
      "date": "Mar 2023",
      "document": "flutter_bootcamp_certificate.pdf",
    },
    {
      "name": "AWS Cloud Practitioner",
      "organization": "Amazon Web Services",
      "date": "Nov 2023",
      "document": "aws_cloud_practitioner.pdf",
    },
    {
      "name": "Google UX Design Certificate",
      "organization": "Coursera",
      "date": "Jul 2024",
      "document": "google_ux_design.pdf",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "Candidate Profile",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Edit profile coming soon")),
              );
            },
            icon: const Icon(Icons.edit_outlined, color: AppColors.buttonText),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background blurred decorative shapes (wow aesthetics)
          Positioned(
            top: -40,
            left: -40,
            child: _blurBlob(160, AppColors.primary.withOpacity(0.05)),
          ),
          Positioned(
            bottom: 120,
            right: -60,
            child: _blurBlob(200, AppColors.primaryLight.withOpacity(0.04)),
          ),
          Positioned(
            top: 360,
            left: -80,
            child: _blurBlob(180, AppColors.primaryDark.withOpacity(0.03)),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Card (Entrance: 0.0 - 0.4)
                _animatedItem(
                  startInterval: 0.0,
                  endInterval: 0.4,
                  child: _profileHeaderCard(),
                ),
                const SizedBox(height: 18),

                // 2. Personal Info Card (Entrance: 0.1 - 0.5)
                _animatedItem(
                  startInterval: 0.1,
                  endInterval: 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.badge_outlined, "Personal Information"),
                      const SizedBox(height: 10),
                      _personalInfoCard(),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // 3. Education Section (Entrance: 0.2 - 0.6)
                _animatedItem(
                  startInterval: 0.2,
                  endInterval: 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.school_outlined, "Education"),
                      const SizedBox(height: 10),
                      ...List.generate(_education.length, (index) {
                        final edu = _education[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          // Stagger individual card entries in list
                          child: _animatedItem(
                            startInterval: 0.22 + (index * 0.05),
                            endInterval: 0.58 + (index * 0.05),
                            child: _educationCard(edu),
                          ),
                        );
                      }),
                ],
              ),
            ),
            const SizedBox(height: 10),

                // 4. Experience Section (Entrance: 0.3 - 0.7)
                _animatedItem(
                  startInterval: 0.3,
                  endInterval: 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.work_outline_rounded, "Experience"),
                      const SizedBox(height: 10),
                      ...List.generate(_experience.length, (index) {
                        final exp = _experience[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          // Stagger individual card entries in list
                          child: _animatedItem(
                            startInterval: 0.32 + (index * 0.05),
                            endInterval: 0.68 + (index * 0.05),
                            child: _experienceCard(exp, index),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 5. Skills Section (Entrance: 0.4 - 0.8)
                _animatedItem(
                  startInterval: 0.4,
                  endInterval: 0.75,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.auto_awesome_outlined, "Skills"),
                      const SizedBox(height: 10),
                      _skillsCard(),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // 6. Languages Section (Entrance: 0.5 - 0.9)
                _animatedItem(
                  startInterval: 0.5,
                  endInterval: 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.language_rounded, "Languages"),
                      const SizedBox(height: 10),
                      ..._languages.map((lang) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _languageCard(lang),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 7. Certificates Section (Entrance: 0.6 - 1.0)
                _animatedItem(
                  startInterval: 0.6,
                  endInterval: 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.workspace_premium_outlined, "Certificates"),
                      const SizedBox(height: 10),
                      ..._certificates.map((cert) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _certificateCard(cert),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Background blur blobs helper
  Widget _blurBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  // ── PROFILE HEADER: PHOTO + NAME ────────────────────────
  Widget _profileHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Pulse glow ring
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 98 * _pulseAnimation.value,
                    height: 98 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(
                        0.14 * (1.6 - _pulseAnimation.value),
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight.withOpacity(0.3),
                  border: Border.all(color: AppColors.primary, width: 2.5),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 52,
                  color: AppColors.primaryDeep,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: TapScale(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Camera upload coming soon")),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: AppColors.buttonText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _personalInfo["name"]!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _personalInfo["email"]!,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── GENERIC SECTION HEADER ──────────────────────────────
  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 19, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── GENERIC CARD WRAPPER ────────────────────────────────
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border, width: 1.1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PERSONAL INFORMATION CARD ───────────────────────────
  Widget _personalInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoRow(Icons.phone_outlined, "Mobile", _personalInfo["mobile"]!),
          const Divider(height: 1, color: AppColors.divider),
          _infoRow(Icons.email_outlined, "Email", _personalInfo["email"]!),
          const Divider(height: 1, color: AppColors.divider),
          _infoRow(Icons.cake_outlined, "Date of Birth", _personalInfo["dob"]!),
          const Divider(height: 1, color: AppColors.divider),
          _infoRow(Icons.wc_rounded, "Gender", _personalInfo["gender"]!),
          const Divider(height: 1, color: AppColors.divider),
          _infoRow(
              Icons.location_on_outlined, "Address", _personalInfo["address"]!),
        ],
      ),
    );
  }

  // ── EDUCATION CARD ───────────────────────────────────────
  Widget _educationCard(Map<String, String> edu) {
    return TapScale(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.accentsSoft[0],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school_rounded, color: AppColors.primaryDeep, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    edu["qualification"]!,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    edu["institution"]!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _pillTag("Year: ${edu["passingYear"]}", AppColors.mint, AppColors.mintSoft),
                      const SizedBox(width: 8),
                      _pillTag("Grade: ${edu["grade"]}", AppColors.primary, AppColors.accentsSoft[0]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── EXPERIENCE CARD ──────────────────────────────────────
  Widget _experienceCard(Map<String, String> exp, int index) {
    final isExpanded = _expandedExperience.contains(index);

    return TapScale(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedExperience.remove(index);
          } else {
            _expandedExperience.add(index);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.coralSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.work_rounded, color: AppColors.coral, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exp["designation"]!,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        exp["company"]!,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${exp["startDate"]} - ${exp["endDate"]}",
                        style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),

            // Expanded description area (Smooth expansion micro-animation)
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        exp["responsibilities"]!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
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

  // ── SKILLS CARD (chips with level + verification) ───────
  Widget _skillsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(_skills.length, (index) {
          final skill = _skills[index];
          final bool verified = skill["verified"] as bool;

          // staggered delay entry timing for skill chips
          final double start = 0.4 + (index * 0.05);
          final double end = (start + 0.22).clamp(0.0, 1.0);

          return _animatedItem(
            startInterval: start,
            endInterval: end,
            child: TapScale(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill["name"] as String,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          skill["level"] as String,
                          style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      verified ? Icons.verified_rounded : Icons.hourglass_bottom_rounded,
                      size: 16,
                      color: verified ? AppColors.mint : AppColors.warning,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── LANGUAGE CARD (speaking/reading/writing progress) ───
  Widget _languageCard(Map<String, dynamic> lang) {
    return TapScale(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang["language"] as String,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _languageLevelBar("Speaking", lang["speaking"] as double),
            const SizedBox(height: 8),
            _languageLevelBar("Reading", lang["reading"] as double),
            const SizedBox(height: 8),
            _languageLevelBar("Writing", lang["writing"] as double),
          ],
        ),
      ),
    );
  }

  Widget _languageLevelBar(String label, double value) {
    return Row(
      children: [
        SizedBox(
          width: 62,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                // Animate progress bar from 0.0 to final value
                final progressVal = CurvedAnimation(
                  parent: _fadeController,
                  curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
                ).value * value;

                return LinearProgressIndicator(
                  value: progressVal,
                  minHeight: 7,
                  backgroundColor: AppColors.divider,
                  color: AppColors.primary,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "${(value * 100).round()}%",
          style: const TextStyle(
            fontSize: 10.5,
            color: AppColors.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── CERTIFICATE CARD ─────────────────────────────────────
  Widget _certificateCard(Map<String, String> cert) {
    return TapScale(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.pinkSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: AppColors.pink, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cert["name"]!,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    cert["organization"]!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    cert["date"]!,
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Opening ${cert["document"]}")),
                );
              },
              icon: const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 22),
              tooltip: "View document",
            ),
          ],
        ),
      ),
    );
  }

  // ── SMALL PILL TAG HELPER ────────────────────────────────
  Widget _pillTag(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// ── TAP-SCALE "HOVER" WRAPPER ────────────────────────────────────────
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
      onTapDown: (_) => _setScale(0.96),
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