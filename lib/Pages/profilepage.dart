import 'dart:io';
import 'dart:typed_data' show Uint8List;
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hyper_local/Pages/homepage.dart';
import 'package:hyper_local/Pages/languagespage.dart';
import 'package:hyper_local/utils/app_colors.dart';
import 'package:hyper_local/Pages/applicationtrackerpage.dart';
import 'package:hyper_local/Pages/certificatespage.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';
import 'package:hyper_local/Pages/editprofilepage.dart';
import 'package:hyper_local/Pages/educationpage.dart';
import 'package:hyper_local/Pages/experiancepage.dart' hide AppColors;
import 'package:hyper_local/Pages/resumeuploded.dart';
import 'package:hyper_local/Pages/recommendedjpbpage.dart';
import 'package:hyper_local/Pages/skillspage.dart' hide AppColors;
import 'package:hyper_local/Pages/workpreferencepage.dart';

import 'package:hyper_local/controllers/auth_controller.dart';
import 'package:hyper_local/services/api_service.dart';
import 'package:hyper_local/utils/session_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4; // "Profile" tab active

  String _userName = "User";
  String _userEmail = "";
  String _userMobile = "";
  String? _userPhoto;
  int _profilePercent = 0;
  bool _isLoading = true;

  final AuthController _authController = AuthController();
  Uint8List? _profileBytes;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final details = await SessionManager.getUserDetails();
    final percent = prefs.getInt('resume_completion_percent') ?? 0;

    if (mounted) {
      setState(() {
        _userName = (details['name'] != null && details['name'].toString().trim().isNotEmpty)
            ? details['name'].toString()
            : "User";
        _userEmail = (details['email'] != null) ? details['email'].toString() : "";
        _userMobile = (details['mobile'] != null) ? details['mobile'].toString() : "";
        _userPhoto = (details['photo'] != null && details['photo'].toString().trim().isNotEmpty)
            ? details['photo'].toString()
            : null;
        _profilePercent = percent;
        _isLoading = false;
      });
    }

    // 1. Fetch fresh profile details from backend (/api/user/profile)
    try {
      final success = await _authController.getProfile();
      if (success && _authController.profileData != null) {
        final p = _authController.profileData!;
        if (mounted) {
          setState(() {
            if (p.name.isNotEmpty) _userName = p.name;
            if (p.email.isNotEmpty) _userEmail = p.email;
            if (p.mobileNo.isNotEmpty) _userMobile = p.mobileNo;
            if (p.profilePhoto != null && p.profilePhoto!.isNotEmpty) {
              _userPhoto = p.profilePhoto;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading profile details: $e");
    }

    // 2. Fetch fresh completion percentage from backend (/api/resume)
    try {
      final token = await SessionManager.getToken();
      if (token != null && token.isNotEmpty) {
        final url = Uri.parse('${ApiService.baseUrl}/resume');
        final response = await http.get(
          url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded['success'] == true && decoded['data'] != null) {
            final data = decoded['data'] as Map<String, dynamic>;
            final serverPercent = (data['completion_percentage'] as num?)?.toInt() ?? 0;
            await prefs.setInt('resume_completion_percent', serverPercent);
            if (mounted) {
              setState(() {
                _profilePercent = serverPercent;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading resume completion percent: $e");
    }
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final name = pickedFile.name;
      setState(() {
        _profileBytes = bytes;
        if (!kIsWeb) {
          _profileImage = File(pickedFile.path);
        }
      });
      // Upload photo to backend!
      await _authController.uploadProfilePhoto(
        imageFile: _profileImage,
        imageBytes: bytes,
        fileName: name,
      );
      _loadUserData();
    }
  }

  ImageProvider? _getAvatarImage() {
    if (_profileBytes != null) {
      return MemoryImage(_profileBytes!);
    }
    if (!kIsWeb && _profileImage != null) {
      return FileImage(_profileImage!);
    }
    if (_userPhoto != null && _userPhoto!.trim().isNotEmpty) {
      final photo = _userPhoto!.trim();
      if (photo.startsWith('http://') || photo.startsWith('https://')) {
        return NetworkImage(photo);
      } else if (!kIsWeb && File(photo).existsSync()) {
        return FileImage(File(photo));
      } else {
        // Backend upload path
        final baseUrlNoApi = ApiService.baseUrl.replaceAll('/api', '');
        final fullUrl = photo.startsWith('/')
            ? "$baseUrlNoApi$photo"
            : "$baseUrlNoApi/$photo";
        return NetworkImage(fullUrl);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
          "Profile",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                children: [
                  // ── PROFILE HEADER CARD ────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar with online dot + camera upload button
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withOpacity(0.12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: _getAvatarImage() != null
                                  ? CircleAvatar(
                                      radius: 26,
                                      backgroundImage: _getAvatarImage(),
                                    )
                                  : Center(
                                      child: Text(
                                        _userName.isNotEmpty
                                            ? _userName[0].toUpperCase()
                                            : "U",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            // Camera icon to upload/change profile photo
                            Positioned(
                              left: -2,
                              bottom: -2,
                              child: GestureDetector(
                                onTap: _pickProfileImage,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.background,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    color: AppColors.buttonText,
                                    size: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),

                        // Name + subtitle (Email / Mobile)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _userEmail.isNotEmpty
                                    ? _userEmail
                                    : (_userMobile.isNotEmpty ? _userMobile : "No details"),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Edit icon
                        IconButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            );
                            _loadUserData();
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── PROFILE STRENGTH ────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Profile Strength",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              "$_profilePercent%",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: (_profilePercent / 100.0).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── MENU LIST ────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _menuTile(
                          icon: Icons.description_outlined,
                          label: "My Resume",
                          subtitle: "$_profilePercent% Complete",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ResumeUploadedPage(),
                              ),
                            );
                            _loadUserData();
                          },
                        ),
                        _divider(),
                        _menuTile(
                          icon: Icons.person_outline_rounded,
                          label: "Name",
                          subtitle: _userName,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            );
                            _loadUserData();
                          },
                        ),
                        _divider(),
                        _menuTile(
                          icon: Icons.phone_outlined,
                          label: "Mobile Number",
                          subtitle: _userMobile.isNotEmpty ? _userMobile : "Not provided",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            );
                            _loadUserData();
                          },
                        ),
                        _divider(),
                        _menuTile(
                          icon: Icons.work_outline_rounded,
                          label: "Preferred Job Role",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WorkPreferencePage(),
                              ),
                            );
                            _loadUserData();
                          },
                        ),
                        _divider(),
                        _menuTile(
                          icon: Icons.currency_rupee_rounded,
                          label: "Preferred Salary",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WorkPreferencePage(),
                              ),
                            );
                            _loadUserData();
                          },
                        ),
                        _divider(),
                        _menuTile(
                          icon: Icons.location_on_outlined,
                          label: "Current Location",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            );
                            _loadUserData();
                          },
                        ),
                        _divider(),
                        _menuTile(
                          icon: Icons.camera_alt_outlined,
                          label: "Profile Photo",
                          subtitle: _userPhoto != null ? "Tap to change photo" : "Upload photo",
                          onTap: _pickProfileImage,
                        ),
                        _divider(),
                        _menuTile(
                          icon: Icons.school_outlined,
                          label: "Education",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EducationPage(),
                              ),
                            );
                            _loadUserData();
                          },
                        ),
                        _divider(),
                        _menuTile(
                          icon: Icons.work_outline_rounded,
                          label: "Experience",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ExperiencePage(),
                              ),
                            );
                            _loadUserData();
                          },
                        ),
                        _divider(),
                        _menuTile(
                          icon: Icons.bolt_outlined,
                          label: "Skills",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SkillsPage(),
                              ),
                            );
                            _loadUserData();
                          },
                        ),
                        _divider(),
                        _menuTile(
                          icon: Icons.card_membership_outlined,
                          label: "Certificates",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CertificatesPage(),
                              ),
                            );
                            _loadUserData();
                          },
                        ),
                        _divider(),
                        _menuTile(
                          icon: Icons.language_outlined,
                          label: "Languages",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LanguagesPage(),
                              ),
                            );
                            _loadUserData();
                          },
                        ),
                        _divider(),
                        _menuTile(
                          icon: Icons.settings_outlined,
                          label: "Work Preference",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WorkPreferencePage(),
                              ),
                            );
                            _loadUserData();
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

      // ── BOTTOM NAVIGATION BAR ──
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
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
                              builder: (context) => const ApplicationTrackerPage(),
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

  // ── DIVIDER BETWEEN TILES ────────────────────
  Widget _divider() {
    return const Divider(height: 1, indent: 52, color: AppColors.divider);
  }

  // ── SINGLE MENU ROW ────────────────────
  Widget _menuTile({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        bottom: isLast ? const Radius.circular(14) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ── BOTTOM NAV ITEM HELPER ──
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
                return Transform.scale(
                  scale: 1 + (value * 0.15),
                  child: child,
                );
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