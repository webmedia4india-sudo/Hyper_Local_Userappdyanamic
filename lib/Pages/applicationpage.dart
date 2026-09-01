import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applicationtrackerpage.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';
import 'package:hyper_local/Pages/messagepage.dart';
import 'package:hyper_local/Pages/profilepage.dart';
import 'package:hyper_local/Pages/recommendedjpbpage.dart';

import '../utils/app_colors.dart';
import 'applicationsuccesspage.dart';

class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key, this.jobTitle = "Delivery Partner"});

  final String jobTitle;

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _coverLetterController = TextEditingController();

  String? _resumeFileName;

  // ── BOTTOM NAV STATE (same as DashboardPage) ────────────
  int _selectedIndex = 2; // "Applications" tab active on this page

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

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
          "Application",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: [
              _buildJobBanner(),
              const SizedBox(height: 24),

              _sectionTitle("Personal Details"),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: "Full Name",
                hint: "Enter your full name",
                icon: Icons.person_outline_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Name is required" : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _emailController,
                label: "Email",
                hint: "Enter your email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Email is required";
                  if (!v.contains("@")) return "Enter a valid email";
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _phoneController,
                label: "Phone Number",
                hint: "Enter your phone number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Phone number is required"
                    : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _addressController,
                label: "Address",
                hint: "Enter your current address",
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Address is required"
                    : null,
              ),

              const SizedBox(height: 26),
              _sectionTitle("Work Details"),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _experienceController,
                label: "Experience",
                hint: "e.g. 2 years / Fresher",
                icon: Icons.work_outline_rounded,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Experience is required"
                    : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _coverLetterController,
                label: "Cover Letter (optional)",
                hint: "Tell us why you're a great fit",
                icon: Icons.description_outlined,
                maxLines: 4,
              ),

              const SizedBox(height: 26),
              _sectionTitle("Resume"),
              const SizedBox(height: 12),
              _buildResumeUpload(),

              const SizedBox(height: 34),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _submitApplication(); // जर submit function ठेवायची असेल

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ApplicationSuccessPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Submit Application",
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ── FLOATING BOTTOM NAVIGATION BAR ─────────────────────────────
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
                  Icons.home_rounded,
                  "Home",
                  0,
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
                  1,
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
                  2,
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
                  Icons.chat_bubble_outline_rounded,
                  "Message",
                  3,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MessagePage(),
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
    );
  }

  // ── JOB BANNER ─────────────────────────────────────────
  Widget _buildJobBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Applying for",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.jobTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION TITLE ──────────────────────────────────────
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ── TEXT FIELD ─────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13.5),
              prefixIcon: maxLines == 1
                  ? Icon(icon, color: AppColors.textHint, size: 20)
                  : null,
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── RESUME UPLOAD BOX ─────────────────────────────────
  Widget _buildResumeUpload() {
    return GestureDetector(
      onTap: () {
        // Hook up file_picker package here if needed.
        setState(() {
          _resumeFileName = "resume.pdf";
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Resume attached")));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.otpBoxBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.otpBoxBorder,
            width: 1.2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _resumeFileName == null
                  ? Icons.upload_file_outlined
                  : Icons.check_circle_outline_rounded,
              color: _resumeFileName == null
                  ? AppColors.primary
                  : AppColors.success,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              _resumeFileName ?? "Tap to upload resume (PDF)",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _resumeFileName == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SUBMIT LOGIC ───────────────────────────────────────
  void _submitApplication() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationSuccessPage(jobTitle: widget.jobTitle),
      ),
    );
  }

  // ── BOTTOM NAV ITEM HELPER (FULLY ANIMATED) ─────────────
  Widget _bottomNavItem(
    IconData icon,
    String label,
    int index, {
    VoidCallback? onTap,
  }) {
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected ? AppColors.selected : AppColors.unselected;

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
          color: isSelected
              ? AppColors.primaryLight.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon scales up smoothly when selected
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
                  color: color,
                  size: 23,
                ),
              ),
            ),

            // Label fades/expands in only when selected — classic
            // "pill" bottom-nav animation
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
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: color,
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



