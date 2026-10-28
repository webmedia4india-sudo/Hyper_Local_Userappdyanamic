import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hyper_local/Pages/applicationtrackerpage.dart';
import '../utils/app_colors.dart';

// ── Simple local model (no external package needed) ─────
class PlatformFile {
  final String name;
  final int size;
  final String path;

  PlatformFile({required this.name, required this.size, required this.path});
}

class ApplicationFormPage extends StatefulWidget {
  const ApplicationFormPage({
    super.key,
    this.jobTitle = "Angular Devloper",
    this.companyName = "IBC",
  });

  final String jobTitle;
  final String companyName;

  @override
  State<ApplicationFormPage> createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends State<ApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _expectedSalaryController = TextEditingController();
  final _messageController = TextEditingController();

  String? _selectedQualification;
  final List<String> _qualifications = [
    "10th Pass",
    "12th Pass",
    "Diploma",
    "Graduate",
    "Post Graduate",
  ];

  PlatformFile? _resumeFile;
  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _expectedSalaryController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ── PICK RESUME FROM GALLERY ─────────────────────────
  Future<void> _pickResume() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final fileSize = await pickedFile.length();

      setState(() {
        _resumeFile = PlatformFile(
          name: pickedFile.name,
          size: fileSize,
          path: pickedFile.path,
        );
      });
    }
  }

  void _removeResume() {
    setState(() {
      _resumeFile = null;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 KB";
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(0)} KB";
    }
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  void _handleSubmit() {
    setState(() => _isSubmitting = true);

    // Simulate submission delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showAnimatedSuccessDialog();
    });
  }

  // ── ANIMATED SUCCESS DIALOG ───────────────────────────
  void _showAnimatedSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Success",
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return Transform.scale(
          scale: curved.value,
          child: Opacity(
            opacity: anim.value.clamp(0.0, 1.0),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Application Sent",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your application for ${widget.jobTitle} at ${widget.companyName} has been submitted successfully.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ApplicationTrackerPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimary,
                          foregroundColor: AppColors.buttonText,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Done",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
          "Application Form",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // ── JOB SUMMARY CARD ─────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.work_rounded,
                      color: AppColors.buttonText,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.jobTitle,
                          style: const TextStyle(
                            color: AppColors.buttonText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.companyName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ── PERSONAL INFORMATION ─────────────────────
            _sectionTitle("Personal Information"),
            const SizedBox(height: 12),
            _fieldLabel("Full Name"),
            _textField(
              controller: _nameController,
              hint: "Enter your full name",
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 14),

            _fieldLabel("Email Address"),
            _textField(
              controller: _emailController,
              hint: "example@email.com",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),

            _fieldLabel("Phone Number"),
            _textField(
              controller: _phoneController,
              hint: "10-digit mobile number",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            _fieldLabel("Current Address"),
            _textField(
              controller: _addressController,
              hint: "Enter your address / area",
              icon: Icons.location_on_outlined,
              maxLines: 2,
            ),

            const SizedBox(height: 22),

            // ── PROFESSIONAL INFORMATION ─────────────────
            _sectionTitle("Professional Information"),
            const SizedBox(height: 12),

            _fieldLabel("Highest Qualification"),
            _dropdownField(),
            const SizedBox(height: 14),

            _fieldLabel("Total Experience (in years)"),
            _textField(
              controller: _experienceController,
              hint: "e.g. 2",
              icon: Icons.work_history_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),

            _fieldLabel("Expected Salary (per month)"),
            _textField(
              controller: _expectedSalaryController,
              hint: "e.g. 25000",
              icon: Icons.currency_rupee_rounded,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 22),

            // ── RESUME UPLOAD ─────────────────────────────
            _sectionTitle("Upload Resume"),
            const SizedBox(height: 12),
            _resumeUploadCard(),

            const SizedBox(height: 22),

            // ── COVER MESSAGE ─────────────────────────────
            _sectionTitle("Message to Employer (optional)"),
            const SizedBox(height: 12),
            _textField(
              controller: _messageController,
              hint: "Tell them why you're a good fit for this job...",
              icon: Icons.message_outlined,
              maxLines: 4,
            ),

            const SizedBox(height: 20),

            // ── TERMS CHECKBOX ─────────────────────────────
            GestureDetector(
              onTap: () {
                setState(() => _agreedToTerms = !_agreedToTerms);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() => _agreedToTerms = value ?? false);
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        "I confirm that the above information is correct and I agree to the Terms & Conditions.",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── SUBMIT BUTTON ─────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: AppColors.buttonText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.buttonText,
                        ),
                      )
                    : const Text(
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
    );
  }

  // ── SECTION TITLE ────────────────────────────────────
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ── FIELD LABEL ───────────────────────────────────────
  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ── REUSABLE TEXT FIELD (VALIDATION REMOVED) ──────────
  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13.5),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 40 : 0),
          child: Icon(icon, color: AppColors.textHint, size: 20),
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }

  // ── DROPDOWN FIELD (Qualification) — VALIDATION REMOVED ──
  Widget _dropdownField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedQualification,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: "Select qualification",
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13.5),
        prefixIcon: const Icon(
          Icons.school_outlined,
          color: AppColors.textHint,
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      items: _qualifications
          .map((q) => DropdownMenuItem(value: q, child: Text(q)))
          .toList(),
      onChanged: (value) {
        setState(() => _selectedQualification = value);
      },
    );
  }

  // ── RESUME UPLOAD CARD (NOW PICKS FROM GALLERY) ──────
  Widget _resumeUploadCard() {
    if (_resumeFile == null) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _pickResume,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 1.4,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Upload your resume",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Choose an image from your gallery",
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: !kIsWeb
                ? Image.file(
                    File(_resumeFile!.path),
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 44,
                    height: 44,
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.description, color: AppColors.primary),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _resumeFile!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatFileSize(_resumeFile!.size),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _removeResume,
            icon: const Icon(Icons.close_rounded, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}