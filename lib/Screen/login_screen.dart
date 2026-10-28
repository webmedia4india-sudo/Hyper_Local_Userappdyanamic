import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';
import 'package:hyper_local/Screen/languagepage.dart';
import 'package:hyper_local/utils/app_colors.dart';
import 'package:hyper_local/Screen/signuppage.dart';
import 'package:hyper_local/controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _authController = AuthController();

  final _mobileController = TextEditingController();
  final _mobileFocus = FocusNode();

  bool _mobileFocused = false;
  bool _isLoading = false;

  // ── OTP STATE ───────────────────────────────────────────
  bool _otpSent = false; // false = show mobile field, true = show OTP boxes

  final int _otpLength = 6;
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _otpFocusNodes;

  @override
  void initState() {
    super.initState();
    _mobileFocus.addListener(() {
      setState(() => _mobileFocused = _mobileFocus.hasFocus);
    });

    _otpControllers = List.generate(_otpLength, (_) => TextEditingController());
    _otpFocusNodes = List.generate(_otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _mobileFocus.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ── SEND OTP HANDLER ───────────────────────────────────────
  void _handleSendOtp() async {
    final phone = _mobileController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await _authController.loginSendOtp(mobileNo: phone);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent successfully to +91 $phone')),
      );

      // Auto focus first OTP box after it appears
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _otpFocusNodes.isNotEmpty) {
          FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
        }
      });
    } else {
      final msg = _authController.errorMessage.isNotEmpty
          ? _authController.errorMessage
          : 'Failed to send OTP. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  // ── VERIFY OTP + LOGIN HANDLER ─────────────────────────────
  void _handleVerifyOtp() async {
    final phone = _mobileController.text.trim();
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await _authController.loginVerifyOtp(
      mobileNo: phone,
      otp: otp,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
        (route) => false,
      );
    } else {
      final msg = _authController.errorMessage.isNotEmpty
          ? _authController.errorMessage
          : 'Invalid OTP. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  // ── RESEND OTP ──────────────────────────────────────────────
  void _handleResendOtp() async {
    final phone = _mobileController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await _authController.loginSendOtp(mobileNo: phone);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully')),
      );
    } else {
      final msg = _authController.errorMessage.isNotEmpty
          ? _authController.errorMessage
          : 'Failed to resend OTP.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  // ── GUEST LOGIN HANDLER → DASHBOARD ────────────────────────
  void _handleGuestLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LanguagePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Screen-aware sizing so the illustration never eats extra blank space
    // on shorter/smaller devices (fixes the odd gap issue).
    final screenHeight = MediaQuery.of(context).size.height;
    final illustrationHeight = (screenHeight * 0.35).clamp(250.0, 320.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Top Brand Logo
              Center(
                child: Image.asset(
                  'assets/images/new_onboarding_logo.png',
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              // Centered Illustration Image — height now scales with
              // screen size instead of a fixed 250, so no leftover gap.
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/screen_222 (2).png',
                    height: illustrationHeight,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              _buildFormSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ── FORM SECTION ─────────────────────────────────────────
  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _otpSent ? 'Enter OTP' : 'Login to your account',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle when OTP is showing
          if (_otpSent)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RichText(
                text: TextSpan(
                  text: 'OTP sent to ',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: () {
                        final phone = _mobileController.text.trim();
                        final maskedPhone = phone.length >= 10
                            ? '${phone.substring(0, 2)}******${phone.substring(8)}'
                            : phone;
                        return '+91 $maskedPhone';
                      }(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Enter your mobile number to proceed',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),

          // Mobile Number Field (only before OTP is sent)
          if (!_otpSent) ...[
            _buildTextField(
              controller: _mobileController,
              focusNode: _mobileFocus,
              isFocused: _mobileFocused,
              hint: 'Mobile Number',
              prefixIcon: Icons.phone_iphone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
          ],

          // OTP Boxes (only after OTP is sent)
          if (_otpSent) ...[
            _buildOtpBoxes(),
            const SizedBox(height: 12),

            // Resend OTP row (Change Number removed)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: _handleResendOtp,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Login / Send OTP Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : (_otpSent ? _handleVerifyOtp : _handleSendOtp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppColors.buttonText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.buttonText,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _otpSent ? 'Verify & Login' : 'Send OTP',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sign Up row
          Center(
            child: RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Continue as Guest → Dashboard
          Center(
            child: GestureDetector(
              onTap: _handleGuestLogin,
              child: const Text(
                'Continue as Guest',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TEXT FIELD WITH FOCUS BORDER ──────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? AppColors.primary : AppColors.border,
          width: isFocused ? 2.0 : 1.2,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.primaryLight.withOpacity(0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        maxLength: keyboardType == TextInputType.phone ? 10 : null,
        inputFormatters: keyboardType == TextInputType.phone
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: keyboardType == TextInputType.phone ? 12.0 : 0.5,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: isFocused ? AppColors.primary : AppColors.textHint,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // ── 6-DIGIT OTP BOXES ──────────────────────────────────────
  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (index) {
        return SizedBox(
          width: 50,
          height: 58,
          child: AnimatedBuilder(
            animation: _otpFocusNodes[index],
            builder: (context, child) {
              final isFocused = _otpFocusNodes[index].hasFocus;
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFocused ? AppColors.primary : AppColors.border,
                    width: isFocused ? 2.0 : 1.2,
                  ),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.primaryLight.withOpacity(0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: child,
              );
            },
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _otpFocusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  if (index < _otpLength - 1) {
                    FocusScope.of(
                      context,
                    ).requestFocus(_otpFocusNodes[index + 1]);
                  } else {
                    FocusScope.of(context).unfocus();
                  }
                } else {
                  if (index > 0) {
                    FocusScope.of(
                      context,
                    ).requestFocus(_otpFocusNodes[index - 1]);
                  }
                }
              },
            ),
          ),
        );
      }),
    );
  }
}
