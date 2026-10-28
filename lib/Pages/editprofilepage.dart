import 'dart:io';
import 'dart:typed_data' show Uint8List;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hyper_local/controllers/auth_controller.dart';
import 'package:hyper_local/services/api_service.dart';
import 'package:hyper_local/utils/session_manager.dart';
import '../utils/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    this.name,
    this.email,
    this.phone,
    this.address,
  });

  final String? name;
  final String? email;
  final String? phone;
  final String? address;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  bool _isLoading = true;
  bool _isSaving = false;
  Uint8List? _pickedBytes;
  File? _pickedImage;
  String? _userPhoto;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name ?? "");
    _emailController = TextEditingController(text: widget.email ?? "");
    _phoneController = TextEditingController(text: widget.phone ?? "");
    _addressController = TextEditingController(text: widget.address ?? "");
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final details = await SessionManager.getUserDetails();
    if (mounted) {
      setState(() {
        if (_nameController.text.isEmpty && details['name'] != null) {
          _nameController.text = details['name'].toString();
        }
        if (_emailController.text.isEmpty && details['email'] != null) {
          _emailController.text = details['email'].toString();
        }
        if (_phoneController.text.isEmpty && details['mobile'] != null) {
          _phoneController.text = details['mobile'].toString();
        }
        _userPhoto = details['photo']?.toString();
        _isLoading = false;
      });
    }

    try {
      final success = await _authController.getProfile();
      if (success && _authController.profileData != null) {
        final p = _authController.profileData!;
        if (mounted) {
          setState(() {
            _nameController.text = p.name;
            _emailController.text = p.email;
            _phoneController.text = p.mobileNo;
            if (p.address != null && p.address!.isNotEmpty) {
              _addressController.text = p.address!;
            }
            if (p.profilePhoto != null && p.profilePhoto!.isNotEmpty) {
              _userPhoto = p.profilePhoto;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading profile in EditProfilePage: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
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
        _pickedBytes = bytes;
        if (!kIsWeb) {
          _pickedImage = File(pickedFile.path);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uploading photo...")),
      );

      final uploaded = await _authController.uploadProfilePhoto(
        imageFile: _pickedImage,
        imageBytes: bytes,
        fileName: name,
      );
      if (mounted) {
        if (uploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile photo updated successfully")),
          );
        } else {
          final msg = _authController.errorMessage.isNotEmpty
              ? _authController.errorMessage
              : "Failed to upload photo";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      }
    }
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final success = await _authController.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobileNo: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context, true);
    } else {
      final msg = _authController.errorMessage.isNotEmpty
          ? _authController.errorMessage
          : "Failed to update profile";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  ImageProvider? _getAvatarImage() {
    if (_pickedBytes != null) {
      return MemoryImage(_pickedBytes!);
    }
    if (!kIsWeb && _pickedImage != null) {
      return FileImage(_pickedImage!);
    }
    if (_userPhoto != null && _userPhoto!.trim().isNotEmpty) {
      final photo = _userPhoto!.trim();
      if (photo.startsWith('http://') || photo.startsWith('https://')) {
        return NetworkImage(photo);
      } else if (!kIsWeb && File(photo).existsSync()) {
        return FileImage(File(photo));
      } else {
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
          "Edit Profile",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: [
                  // ── PROFILE AVATAR ─────────────────────────────
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: _getAvatarImage() != null
                              ? CircleAvatar(
                                  radius: 46,
                                  backgroundImage: _getAvatarImage(),
                                )
                              : Center(
                                  child: Text(
                                    _nameController.text.trim().isNotEmpty
                                        ? _nameController.text.trim()[0].toUpperCase()
                                        : "U",
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 2.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.buttonText,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── FORM FIELDS ────────────────────────────────
                  _fieldLabel("Full Name"),
                  _textField(
                    controller: _nameController,
                    hint: "Enter your full name",
                    icon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Name is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _fieldLabel("Email Address"),
                  _textField(
                    controller: _emailController,
                    hint: "example@email.com",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email is required";
                      }
                      if (!RegExp(
                        r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$',
                      ).hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _fieldLabel("Phone Number"),
                  _textField(
                    controller: _phoneController,
                    hint: "10-digit mobile number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Phone number is required";
                      }
                      if (value.trim().length < 10) {
                        return "Enter a valid phone number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _fieldLabel("Address"),
                  _textField(
                    controller: _addressController,
                    hint: "Enter your address / city",
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Address is required";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── SAVE BUTTON ────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: AppColors.buttonText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: AppColors.buttonText,
                              ),
                            )
                          : const Text(
                              "Save Changes",
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

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}