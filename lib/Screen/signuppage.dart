import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:hyper_local/Screen/login_screen.dart';
import '../utils/app_colors.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _agreeToTerms = false;

  String? _selectedGender;
  final List<String> _genderOptions = ["Male", "Female", "Other"];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // ── DATE OF BIRTH PICKER ────────────────────────────────────
  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // ── TERMS & CONDITIONS POPUP ───────────────────────────────
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _buildPolicyDialog(
          title: "Terms & Conditions",
          content: """
Welcome to our app. By creating an account, you agree to the following terms:

1. Account Responsibility
You are responsible for maintaining the confidentiality of your account and for all activities that occur under it.

2. Acceptable Use
You agree not to misuse the platform, including but not limited to posting false information, spamming, or engaging in fraudulent activity.

3. Job Listings & Applications
All job listings and applications submitted through the platform must be accurate and lawful. We reserve the right to remove any content that violates these terms.

4. Termination
We reserve the right to suspend or terminate accounts that violate these terms without prior notice.

5. Changes to Terms
We may update these terms from time to time. Continued use of the app after changes constitutes acceptance of the new terms.

6. Limitation of Liability
We are not liable for any indirect, incidental, or consequential damages arising from your use of the platform.

By tapping "I Agree", you confirm that you have read, understood, and accepted these Terms & Conditions.
""",
        );
      },
    );
  }

  // ── PRIVACY POLICY POPUP ───────────────────────────────────
  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _buildPolicyDialog(
          title: "Privacy Policy",
          content: """
Your privacy is important to us. This policy explains how we collect, use, and protect your information.

1. Information We Collect
We collect information you provide during sign up, such as your name, email address, and phone number.

2. How We Use Your Information
Your information is used to create and manage your account, connect you with relevant job opportunities, and improve our services.

3. Data Sharing
We do not sell your personal information. We may share data with trusted service providers strictly to operate the platform.

4. Data Security
We implement reasonable security measures to protect your data from unauthorized access, alteration, or disclosure.

5. Your Rights
You may request access to, correction of, or deletion of your personal data at any time by contacting our support team.

6. Cookies & Tracking
We may use cookies or similar technologies to enhance your experience and analyze app usage.

7. Changes to This Policy
We may update this Privacy Policy periodically. Continued use of the app indicates acceptance of the revised policy.

By tapping "I Agree", you acknowledge that you have read and understood this Privacy Policy.
""",
        );
      },
    );
  }

  // ── SHARED POPUP UI ─────────────────────────────────────────
  Widget _buildPolicyDialog({required String title, required String content}) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    content.trim(),
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Read and Understand 👍",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/new_onboarding_logo.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    "Create Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    "Sign up to get started",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildLabel("Full Name"),
                _buildTextField(
                  controller: _nameController,
                  hint: "Enter your full name",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),

                _buildLabel("Email"),
                _buildTextField(
                  controller: _emailController,
                  hint: "Enter your email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                _buildLabel("Phone Number"),
                _buildTextField(
                  controller: _phoneController,
                  hint: "Enter your phone number",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                _buildLabel("Date of Birth"),
                _buildTextField(
                  controller: _dobController,
                  hint: "DD/MM/YYYY",
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _pickDateOfBirth,
                ),
                const SizedBox(height: 12),

                _buildLabel("Gender"),
                _buildGenderDropdown(),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (value) {
                          setState(() => _agreeToTerms = value ?? false);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: "I agree to the "),
                              TextSpan(
                                text: "Terms & Conditions",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _showTermsDialog,
                              ),
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _showPrivacyPolicyDialog,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPrimary,
                      foregroundColor: AppColors.buttonText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Log In",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  // ── GENDER DROPDOWN ─────────────────────────────────────────
  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.textHint),
      decoration: InputDecoration(
        hintText: "Select gender",
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: const Icon(Icons.wc_outlined,
            color: AppColors.textHint, size: 20),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      items: _genderOptions
          .map(
            (gender) => DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() => _selectedGender = value);
      },
    );
  }
}