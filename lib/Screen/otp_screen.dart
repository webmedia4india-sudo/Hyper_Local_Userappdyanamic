import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_local/Screen/languagepage.dart';
import 'package:hyper_local/controllers/auth_controller.dart';
import 'package:hyper_local/models/auth/signup_request_model.dart';
import '../utils/app_colors.dart';

class OtpScreen extends StatefulWidget {
  final SignupRequestModel? signupData;
  final String? mobileNo;

  const OtpScreen({
    super.key,
    this.signupData,
    this.mobileNo,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final AuthController _authController = AuthController();
  bool _isLoading = false;

  final int _otpLength = 6;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    controllers = List.generate(_otpLength, (_) => TextEditingController());
    focusNodes = List.generate(_otpLength, (_) => FocusNode());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _getSubtitleText() {
    if (widget.signupData != null && widget.signupData!.mobileNo.isNotEmpty) {
      final phone = widget.signupData!.mobileNo;
      final masked = phone.length >= 10
          ? '${phone.substring(0, 2)}******${phone.substring(8)}'
          : phone;
      return "Enter the 6-digit code sent to +91 $masked";
    } else if (widget.mobileNo != null && widget.mobileNo!.isNotEmpty) {
      final phone = widget.mobileNo!;
      final masked = phone.length >= 10
          ? '${phone.substring(0, 2)}******${phone.substring(8)}'
          : phone;
      return "Enter the 6-digit code sent to +91 $masked";
    }
    return "Enter the 6-digit code sent to your mobile number";
  }

  void _handleVerifyOtp() async {
    final otp = controllers.map((c) => c.text).join();
    if (otp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    bool success = false;

    if (widget.signupData != null) {
      success = await _authController.verifyOtp(
        name: widget.signupData!.name,
        email: widget.signupData!.email,
        mobileNo: widget.signupData!.mobileNo,
        dob: widget.signupData!.dob,
        gender: widget.signupData!.gender,
        industry: widget.signupData!.industry,
        currentRole: widget.signupData!.currentRole,
        otp: otp,
      );
    } else if (widget.mobileNo != null) {
      success = await _authController.loginVerifyOtp(
        mobileNo: widget.mobileNo!,
        otp: otp,
      );
    } else {
      success = true;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Verified Successfully!')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LanguagePage()),
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

  void _handleResendOtp() async {
    if (widget.signupData != null) {
      setState(() => _isLoading = true);
      final success = await _authController.sendOtp(
        name: widget.signupData!.name,
        email: widget.signupData!.email,
        mobileNo: widget.signupData!.mobileNo,
        dob: widget.signupData!.dob,
        gender: widget.signupData!.gender,
        industry: widget.signupData!.industry,
        currentRole: widget.signupData!.currentRole,
      );
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
    } else if (widget.mobileNo != null) {
      setState(() => _isLoading = true);
      final success = await _authController.loginSendOtp(
        mobileNo: widget.mobileNo!,
      );
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
  }

  Widget otpBox(int index) {
    return SizedBox(
      width: 44,
      height: 54,
      child: AnimatedBuilder(
        animation: focusNodes[index],
        builder: (context, child) {
          final isFocused = focusNodes[index].hasFocus;
          return Container(
            decoration: BoxDecoration(
              color: AppColors.otpBoxBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFocused ? AppColors.primary : AppColors.otpBoxBorder,
                width: isFocused ? 2.0 : 1.0,
              ),
            ),
            child: child,
          );
        },
        child: TextField(
          controller: controllers[index],
          focusNode: focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < _otpLength - 1) {
                FocusScope.of(context).requestFocus(focusNodes[index + 1]);
              } else {
                FocusScope.of(context).unfocus();
              }
            } else {
              if (index > 0) {
                FocusScope.of(context).requestFocus(focusNodes[index - 1]);
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                                child: const Icon(
                                  Icons.verified_user,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                "OTP Verification",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                _getSubtitleText(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),

                              const SizedBox(height: 25),

                              /// OTP BOXES
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  _otpLength,
                                  (index) => otpBox(index),
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// RESEND OTP
                              if (widget.signupData != null || widget.mobileNo != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: _isLoading ? null : _handleResendOtp,
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

                              /// VERIFY BUTTON
                              GestureDetector(
                                onTap: _isLoading ? null : _handleVerifyOtp,
                                child: Container(
                                  height: 55,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryDark,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              color: AppColors.buttonText,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            "Verify OTP",
                                            style: TextStyle(
                                              color: AppColors.buttonText,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
}
