// C:\flutter-projects\hyper_local\lib\screens\resumeuploaded.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:hyper_local/utils/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class ResumeUploadedPage extends StatefulWidget {
  const ResumeUploadedPage({super.key});

  @override
  State<ResumeUploadedPage> createState() => _ResumeUploadedPageState();
}

class _ResumeUploadedPageState extends State<ResumeUploadedPage> {
  final _formKey = GlobalKey<FormState>();

  // ── Text Controllers ──
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController objectiveController = TextEditingController();

  String? selectedGender;
  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  // ── Uploaded Resume File ──
  String resumeFileName = '';
  String resumeUploadedOn = '';

  final List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  String _formatDate(DateTime date) =>
      '${monthNames[date.month - 1]} ${date.year}';

  // ── Skills Data ──
  final List<String> skillLevels = ['Beginner', 'Intermediate', 'Expert'];
  List<Map<String, String>> skills = [];
  List<String> suggestedSkills = [
    'Flutter',
    'Dart',
    'Firebase',
    'REST API',
    'Git',
    'UI/UX Design',
    'Node.js',
    'MySQL',
    'Java',
    'Kotlin',
    'Python',
    'SQL',
    'Photoshop',
  ];

  // ── Languages Data ──
  final List<String> languageLevels = [
    'Beginner',
    'Intermediate',
    'Fluent',
    'Native',
  ];
  List<Map<String, String>> languages = [];
  List<String> suggestedLanguages = ['English', 'Hindi', 'Marathi', 'French', 'German', 'Spanish'];

  // ── Education Data ──
  List<Map<String, String>> education = [];

  // ── Certification Data ──
  List<Map<String, String>> certifications = [];

  // ── Experience Data ──
  List<Map<String, String>> experiences = [];

  // ── Projects Data ──
  List<Map<String, String>> projects = [];

  // ── Accomplishments Data ──
  List<Map<String, String>> accomplishments = [];

  // ────────────────────────────────
  // Backend & Auto-Save State
  // ────────────────────────────────
  Timer? _debounceTimer;
  bool _isSaving = false;
  bool _isFetching = false;
  bool _isInitializing = true;

  // ────────────────────────────────
  // Section completion checks
  // ────────────────────────────────
  bool get _isPersonalDetailsComplete =>
      nameController.text.trim().isNotEmpty &&
      emailController.text.trim().isNotEmpty &&
      phoneController.text.trim().isNotEmpty &&
      dobController.text.trim().isNotEmpty &&
      addressController.text.trim().isNotEmpty &&
      (selectedGender ?? '').trim().isNotEmpty;

  String? get _safeGender {
    final clean = selectedGender?.trim();
    if (clean == null || clean.isEmpty) return null;
    for (final opt in genderOptions) {
      if (opt.toLowerCase() == clean.toLowerCase()) {
        return opt;
      }
    }
    return null;
  }

  bool get _isObjectiveComplete => objectiveController.text.trim().isNotEmpty;
  bool get _isEducationComplete => education.isNotEmpty;
  bool get _isCertificationsComplete => certifications.isNotEmpty;
  bool get _isSkillsComplete => skills.isNotEmpty;
  bool get _isLanguagesComplete => languages.isNotEmpty;
  bool get _isExperienceComplete => experiences.isNotEmpty;
  bool get _isProjectsComplete => projects.isNotEmpty;
  bool get _isAccomplishmentsComplete => accomplishments.isNotEmpty;

  // ────────────────────────────────
  // Completion Percentage (Aligned 100% with backend calculation)
  // ────────────────────────────────
  int get currentPercentage {
    int percentage = 0;
    // 1. Personal Details (20%)
    if (_isPersonalDetailsComplete) percentage += 20;
    // 2. Objective (10%)
    if (_isObjectiveComplete) percentage += 10;
    // 3. Skills (10%)
    if (_isSkillsComplete) percentage += 10;
    // 4. Languages (5%)
    if (_isLanguagesComplete) percentage += 5;
    // 5. Education (15%)
    if (_isEducationComplete) percentage += 15;
    // 6. Certifications (10%)
    if (_isCertificationsComplete) percentage += 10;
    // 7. Experiences (10%)
    if (_isExperienceComplete) percentage += 10;
    // 8. Projects (10%)
    if (_isProjectsComplete) percentage += 10;
    // 9. Accomplishments (10%)
    if (_isAccomplishmentsComplete) percentage += 10;
    return percentage.clamp(0, 100);
  }

  int get completedSectionsCount {
    int count = 0;
    if (_isPersonalDetailsComplete) count++;
    if (_isObjectiveComplete) count++;
    if (_isSkillsComplete) count++;
    if (_isLanguagesComplete) count++;
    if (_isEducationComplete) count++;
    if (_isCertificationsComplete) count++;
    if (_isExperienceComplete) count++;
    if (_isProjectsComplete) count++;
    if (_isAccomplishmentsComplete) count++;
    return count;
  }

  // ────────────────────────────────
  // Safe List of Maps JSON Parser
  // ────────────────────────────────
  List<Map<String, String>> _parseListMap(dynamic raw) {
    if (raw == null) return [];
    dynamic list = raw;
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty || trimmed == 'null') return [];
      try {
        list = jsonDecode(trimmed);
      } catch (e) {
        debugPrint("JSON parse error in _parseListMap: $e");
        return [];
      }
    }
    if (list is List) {
      final List<Map<String, String>> result = [];
      for (final item in list) {
        if (item is String) {
          final s = item.trim();
          if (s.isNotEmpty) {
            result.add({'name': s, 'level': 'Beginner'});
          }
        } else if (item is Map) {
          final Map<String, String> entry = {};
          item.forEach((k, v) {
            entry[k.toString()] = v?.toString() ?? '';
          });
          if (entry.containsKey('skill') && (entry['name'] == null || entry['name']?.trim().isEmpty == true)) {
            entry['name'] = entry['skill'] ?? '';
          }
          if (entry.containsKey('title') && (entry['name'] == null || entry['name']?.trim().isEmpty == true)) {
            entry['name'] = entry['title'] ?? '';
          }
          if (!entry.containsKey('name') || entry['name'] == null) {
            entry['name'] = '';
          }
          if (!entry.containsKey('level') || (entry['level']?.trim().isEmpty ?? true)) {
            entry['level'] = 'Beginner';
          }
          if (entry.isNotEmpty) {
            result.add(entry);
          }
        }
      }
      return result;
    }
    return [];
  }

  Future<void> _updateProgress() async {
    if (_isInitializing) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      final points = completedSectionsCount;
      final percent = currentPercentage;

      await prefs.setInt('resume_completed_points', points);
      await prefs.setInt('resume_total_points', 9);
      await prefs.setInt('resume_completion_percent', percent);

      // Persist all resume data to SharedPreferences so it is NEVER lost on exit
      final Map<String, dynamic> data = {
        'full_name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'dob': dobController.text.trim().contains('T')
            ? dobController.text.trim().split('T')[0]
            : dobController.text.trim(),
        'gender': selectedGender,
        'objective': objectiveController.text.trim(),
        'resume_file': resumeFileName,
        'resume_file_name': resumeFileName,
        'resume_uploaded_on': resumeUploadedOn,
        'skills': skills,
        'languages': languages,
        'education': education,
        'certifications': certifications,
        'experiences': experiences,
        'projects': projects,
        'accomplishments': accomplishments,
        'completion_percentage': percent,
      };
      await prefs.setString('saved_resume_data', jsonEncode(data));
    } catch (e) {
      debugPrint("Error auto-saving resume progress: $e");
    }

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    _isInitializing = true;
    await _loadSavedData();
    _isInitializing = false;
    if (mounted) setState(() {});

    for (final c in [
      nameController,
      emailController,
      phoneController,
      addressController,
      dobController,
      objectiveController,
    ]) {
      c.addListener(_onPersonalDetailsChanged);
    }

    // Fetch latest fresh data from backend
    await _fetchResumeFromBackend();
    await _updateProgress();
  }

  void _onPersonalDetailsChanged() {
    if (_isInitializing) return;
    _updateProgress();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      saveResume(isSilent: true);
    });
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDataStr = prefs.getString('saved_resume_data');
      if (savedDataStr != null && savedDataStr.isNotEmpty) {
        final data = jsonDecode(savedDataStr) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            nameController.text = data['full_name'] ?? '';
            emailController.text = data['email'] ?? '';
            phoneController.text = data['phone'] ?? '';
            addressController.text = data['address'] ?? '';
            final rawSavedDob = (data['dob'] ?? '').toString().trim();
            dobController.text =
                rawSavedDob.contains('T') ? rawSavedDob.split('T')[0] : rawSavedDob;
            selectedGender = data['gender'];
            objectiveController.text = data['objective'] ?? '';
            resumeFileName = data['resume_file'] ?? data['resume_file_name'] ?? '';
            resumeUploadedOn = data['resume_uploaded_on'] ?? '';

            if (data['skills'] != null) {
              skills = _parseListMap(data['skills']);
              for (var s in skills) {
                suggestedSkills.remove(s['name']);
              }
            }
            if (data['languages'] != null) {
              languages = _parseListMap(data['languages']);
              for (var l in languages) {
                suggestedLanguages.remove(l['name']);
              }
            }
            if (data['education'] != null) {
              education = _parseListMap(data['education']);
            }
            if (data['certifications'] != null) {
              certifications = _parseListMap(data['certifications']);
            }
            if (data['experiences'] != null) {
              experiences = _parseListMap(data['experiences']);
            }
            if (data['projects'] != null) {
              projects = _parseListMap(data['projects']);
            }
            if (data['accomplishments'] != null) {
              accomplishments = _parseListMap(data['accomplishments']);
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading saved resume data: $e");
    }
  }

  Future<String?> _getAuthToken() async {
    String? token = await SessionManager.getToken();
    if (token == null || token.trim().isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token') ?? prefs.getString('token');
    }
    return token;
  }

  // ────────────────────────────────
  // Fetch Existing Resume from Backend (GET /api/resume)
  // ────────────────────────────────
  Future<void> _fetchResumeFromBackend() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final token = await _getAuthToken();
      if (token == null || token.trim().isEmpty) {
        _isFetching = false;
        return;
      }

      final url = Uri.parse('${ApiService.baseUrl}/resume');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final data = decoded['data'] as Map<String, dynamic>;
          _isInitializing = true;

          if (mounted) {
            setState(() {
              if (data['full_name'] != null && data['full_name'].toString().trim().isNotEmpty) {
                nameController.text = data['full_name'].toString();
              }
              if (data['email'] != null && data['email'].toString().trim().isNotEmpty) {
                emailController.text = data['email'].toString();
              }
              if (data['phone'] != null && data['phone'].toString().trim().isNotEmpty) {
                phoneController.text = data['phone'].toString();
              } else if (data['mobile_no'] != null && data['mobile_no'].toString().trim().isNotEmpty) {
                phoneController.text = data['mobile_no'].toString();
              } else if (data['mobile'] != null && data['mobile'].toString().trim().isNotEmpty) {
                phoneController.text = data['mobile'].toString();
              }
              if (data['address'] != null && data['address'].toString().trim().isNotEmpty) {
                addressController.text = data['address'].toString();
              }
              if (data['dob'] != null && data['dob'].toString().trim().isNotEmpty) {
                final rawDob = data['dob'].toString().trim();
                dobController.text =
                    rawDob.contains('T') ? rawDob.split('T')[0] : rawDob;
              }
              if (data['gender'] != null && data['gender'].toString().trim().isNotEmpty) {
                selectedGender = data['gender'].toString();
              }
              if (data['objective'] != null && data['objective'].toString().trim().isNotEmpty) {
                objectiveController.text = data['objective'].toString();
              }
              if (data['resume_file'] != null && data['resume_file'].toString().trim().isNotEmpty) {
                resumeFileName = data['resume_file'].toString();
              }

              if (data['skills'] != null) {
                final fetchedSkills = _parseListMap(data['skills']);
                if (fetchedSkills.isNotEmpty) {
                  skills = fetchedSkills;
                  for (var s in skills) {
                    suggestedSkills.remove(s['name']);
                  }
                }
              }

              if (data['languages'] != null) {
                final fetchedLangs = _parseListMap(data['languages']);
                if (fetchedLangs.isNotEmpty) {
                  languages = fetchedLangs;
                  for (var l in languages) {
                    suggestedLanguages.remove(l['name']);
                  }
                }
              }

              if (data['education'] != null) {
                final fetchedEdu = _parseListMap(data['education']);
                if (fetchedEdu.isNotEmpty) education = fetchedEdu;
              }

              if (data['certifications'] != null) {
                final fetchedCerts = _parseListMap(data['certifications']);
                if (fetchedCerts.isNotEmpty) certifications = fetchedCerts;
              }

              if (data['experiences'] != null) {
                final fetchedExp = _parseListMap(data['experiences']);
                if (fetchedExp.isNotEmpty) experiences = fetchedExp;
              }

              if (data['projects'] != null) {
                final fetchedProj = _parseListMap(data['projects']);
                if (fetchedProj.isNotEmpty) projects = fetchedProj;
              }

              if (data['accomplishments'] != null) {
                final fetchedAcc = _parseListMap(data['accomplishments']);
                if (fetchedAcc.isNotEmpty) accomplishments = fetchedAcc;
              }
            });
          }
          _isInitializing = false;

          final prefs = await SharedPreferences.getInstance();
          final serverPercent = data['completion_percentage'];
          if (serverPercent != null) {
            await prefs.setInt('resume_completion_percent', (serverPercent as num).toInt());
          }
          await prefs.setInt('resume_completed_points', completedSectionsCount);
          await prefs.setInt('resume_total_points', 9);
        } else {
          // User has no resume on backend (fresh signup)
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('saved_resume_data');
          await prefs.setInt('resume_completion_percent', 0);
          await prefs.setInt('resume_completed_points', 0);
          await prefs.setInt('resume_total_points', 9);
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('saved_resume_data');
        await prefs.setInt('resume_completion_percent', 0);
        await prefs.setInt('resume_completed_points', 0);
        await prefs.setInt('resume_total_points', 9);
      }
    } catch (e) {
      debugPrint("Error fetching resume from backend: $e");
    } finally {
      _isFetching = false;
      _isInitializing = false;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    for (final c in [
      nameController,
      emailController,
      phoneController,
      addressController,
      dobController,
      objectiveController,
    ]) {
      c.removeListener(_onPersonalDetailsChanged);
      c.dispose();
    }
    super.dispose();
  }

  // ────────────────────────────────
  // Save Resume API Function (POST /api/resume)
  // Supports both manual click (isSilent: false) and auto-sync (isSilent: true)
  // ────────────────────────────────
  Future<void> saveResume({bool isSilent = false}) async {
    if (_isSaving && isSilent) return;
    _isSaving = true;

    try {
      if (!isSilent && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const Center(child: CircularProgressIndicator());
          },
        );
      }

      final token = await _getAuthToken();

      if (token == null || token.isEmpty) {
        if (!isSilent && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login token not found. Please log in again.'),
            ),
          );
        }
        _isSaving = false;
        return;
      }

      final url = Uri.parse('${ApiService.baseUrl}/resume');

      final userDetails = await SessionManager.getUserDetails();
      final userMobile = (userDetails['mobile'] ?? userDetails['mobile_no'] ?? '').toString().trim();
      final phoneVal = phoneController.text.trim().isNotEmpty
          ? phoneController.text.trim()
          : (userMobile.isNotEmpty ? userMobile : '0000000000');

      final Map<String, dynamic> resumeData = {
        // Personal Details
        "full_name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneVal,
        "mobile_no": phoneVal,
        "mobile": phoneVal,
        "address": addressController.text.trim(),
        "dob": dobController.text.trim().contains('T')
            ? dobController.text.trim().split('T')[0]
            : dobController.text.trim(),
        "gender": selectedGender,

        // Objective
        "objective": objectiveController.text.trim(),

        // Resume file
        "resume_file": resumeFileName,

        // Skills
        "skills": skills,

        // Languages
        "languages": languages,

        // Education
        "education": education,

        // Certifications
        "certifications": certifications,

        // Experiences
        "experiences": experiences,

        // Projects
        "projects": projects,

        // Accomplishments
        "accomplishments": accomplishments,
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(resumeData),
      );

      if (!isSilent && mounted) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final percentage = responseData["completion_percentage"] ?? currentPercentage;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'saved_resume_data',
          jsonEncode({
            ...resumeData,
            'resume_file_name': resumeFileName,
            'resume_uploaded_on': resumeUploadedOn,
            'completion_percentage': percentage,
          }),
        );
        await prefs.setInt('resume_completed_points', completedSectionsCount);
        await prefs.setInt('resume_total_points', 9);
        await prefs.setInt('resume_completion_percent', (percentage as num).toInt());

        if (mounted) {
          setState(() {});
        }

        if (!isSilent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Resume Saved Successfully! $percentage% Complete"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (!isSilent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed: ${response.body}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!isSilent && mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      debugPrint("SAVE RESUME ERROR: $e");

      if (!isSilent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      _isSaving = false;
    }
  }

  // ────────────────────────────────
  // Shared Input Decoration
  // ────────────────────────────────
  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.primary, size: 20)
          : null,
      filled: true,
      fillColor: AppColors.scaffoldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }

  // ────────────────────────────────
  // Naukri-style white "card" wrapper for every section
  // ────────────────────────────────
  Widget _sectionCard({
    required String title,
    String? subtitle,
    bool isCompleted = false,
    VoidCallback? onEdit,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isCompleted) _updatedBadge(),
              if (onEdit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 8),
              child: Text(
                subtitle,
                style: const TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            )
          else
            const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // ────────────────────────────────
  // "Updated" badge — profile-completion pill
  // ────────────────────────────────
  Widget _updatedBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.limeSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, size: 13, color: AppColors.primary),
          SizedBox(width: 4),
          Text(
            'Updated',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime initialDate = DateTime(today.year - 18, today.month, today.day);

    if (dobController.text.trim().isNotEmpty) {
      final raw = dobController.text.trim();
      DateTime? parsed = DateTime.tryParse(raw);
      if (parsed == null) {
        final parts = raw.split(RegExp(r'[/.-]'));
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            final y = int.tryParse(parts[0]);
            final m = int.tryParse(parts[1]);
            final d = int.tryParse(parts[2]);
            if (y != null && m != null && d != null) {
              parsed = DateTime(y, m, d);
            }
          } else if (parts[2].length == 4) {
            final d = int.tryParse(parts[0]);
            final m = int.tryParse(parts[1]);
            final y = int.tryParse(parts[2]);
            if (y != null && m != null && d != null) {
              parsed = DateTime(y, m, d);
            }
          }
        }
      }

      if (parsed != null && !parsed.isAfter(today) && !parsed.isBefore(DateTime(1900))) {
        initialDate = parsed;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
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
        dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
      _updateProgress();
      saveResume(isSilent: true);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: _inputDecoration(label, icon: icon),
        validator: isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }


  // ────────────────────────────────
  // Tag Chip (skills / languages)
  // ────────────────────────────────
  Widget _buildTagChip({
    required String name,
    required String level,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '· $level',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedChip(String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 15, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.primary, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────
  // Generic info card (education / certification / experience / projects)
  // ────────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String caption,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.limeSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (caption.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────
  // Dialogs — Skill / Language
  // ────────────────────────────────
  void _showAddSkillDialog() {
    String skillName = '';
    String level = skillLevels.first;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Add Skill',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: _inputDecoration('Skill Name'),
                    onChanged: (val) => skillName = val,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: level,
                    decoration: _inputDecoration('Proficiency Level'),
                    items: skillLevels
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => level = val ?? level),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    if (skillName.trim().isNotEmpty) {
                      setState(
                        () => skills.add({
                          'name': skillName.trim(),
                          'level': level,
                        }),
                      );
                      _updateProgress();
                      saveResume(isSilent: true);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddLanguageDialog() {
    String langName = '';
    String level = languageLevels.first;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Add Language',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: _inputDecoration('Language Name'),
                    onChanged: (val) => langName = val,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: level,
                    decoration: _inputDecoration('Proficiency Level'),
                    items: languageLevels
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => level = val ?? level),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    if (langName.trim().isNotEmpty) {
                      setState(
                        () => languages.add({
                          'name': langName.trim(),
                          'level': level,
                        }),
                      );
                      _updateProgress();
                      saveResume(isSilent: true);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ────────────────────────────────
  // Dialog — Education
  // ────────────────────────────────
  void _showAddEducationDialog() {
    String degree = '';
    String institution = '';
    String year = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Education',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: _inputDecoration('Degree / Course'),
                onChanged: (val) => degree = val,
              ),
              const SizedBox(height: 14),
              TextField(
                decoration: _inputDecoration('Institution Name'),
                onChanged: (val) => institution = val,
              ),
              const SizedBox(height: 14),
              TextField(
                decoration: _inputDecoration('Year (e.g. 2020 - 2024)'),
                onChanged: (val) => year = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                if (degree.trim().isNotEmpty && institution.trim().isNotEmpty) {
                  setState(
                    () => education.add({
                      'degree': degree.trim(),
                      'institution': institution.trim(),
                      'year': year.trim(),
                    }),
                  );
                  _updateProgress();
                  saveResume(isSilent: true);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ────────────────────────────────
  // Dialog — Certification
  // ────────────────────────────────
  void _showAddCertificationDialog() {
    String certName = '';
    String organization = '';
    String year = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Certification',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: _inputDecoration('Certification Name'),
                onChanged: (val) => certName = val,
              ),
              const SizedBox(height: 14),
              TextField(
                decoration: _inputDecoration('Issued By (Organization)'),
                onChanged: (val) => organization = val,
              ),
              const SizedBox(height: 14),
              TextField(
                decoration: _inputDecoration('Year (e.g. 2023)'),
                onChanged: (val) => year = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                if (certName.trim().isNotEmpty &&
                    organization.trim().isNotEmpty) {
                  setState(
                    () => certifications.add({
                      'name': certName.trim(),
                      'organization': organization.trim(),
                      'year': year.trim(),
                    }),
                  );
                  _updateProgress();
                  saveResume(isSilent: true);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ────────────────────────────────
  // Dialog — Work Experience (with real date pickers)
  // ────────────────────────────────
  void _showAddExperienceDialog() {
    String role = '';
    String company = '';
    DateTime? startDate;
    DateTime? endDate;
    bool isCurrentJob = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickStartDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: startDate ?? DateTime.now(),
                firstDate: DateTime(1990),
                lastDate: DateTime(2100),
              );
              if (picked != null) setDialogState(() => startDate = picked);
            }

            Future<void> pickEndDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: endDate ?? DateTime.now(),
                firstDate: DateTime(1990),
                lastDate: DateTime(2100),
              );
              if (picked != null) setDialogState(() => endDate = picked);
            }

            Widget dateButton(
              String label,
              DateTime? date,
              VoidCallback onTap, {
              bool enabled = true,
            }) {
              return InkWell(
                onTap: enabled ? onTap : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: enabled
                        ? AppColors.scaffoldBackground
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        date != null ? _formatDate(date) : label,
                        style: TextStyle(
                          color: date != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Add Work Experience',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: _inputDecoration('Job Role'),
                      onChanged: (val) => role = val,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      decoration: _inputDecoration('Company Name'),
                      onChanged: (val) => company = val,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: dateButton(
                            'Start Date',
                            startDate,
                            pickStartDate,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: dateButton(
                            'End Date',
                            endDate,
                            pickEndDate,
                            enabled: !isCurrentJob,
                          ),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      value: isCurrentJob,
                      onChanged: (val) {
                        setDialogState(() {
                          isCurrentJob = val ?? false;
                          if (isCurrentJob) endDate = null;
                        });
                      },
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'Currently working here',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    final sDate = startDate;
                    final eDate = endDate;
                    if (role.trim().isNotEmpty &&
                        company.trim().isNotEmpty &&
                        sDate != null) {
                      final durationText =
                          '${_formatDate(sDate)} - ${isCurrentJob ? 'Present' : (eDate != null ? _formatDate(eDate) : '')}';
                      setState(
                        () => experiences.add({
                          'role': role.trim(),
                          'company': company.trim(),
                          'duration': durationText,
                        }),
                      );
                      _updateProgress();
                      saveResume(isSilent: true);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ────────────────────────────────
  // Dialog — Project
  // ────────────────────────────────
  void _showAddProjectDialog() {
    String projectName = '';
    String description = '';
    String duration = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Project',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: _inputDecoration('Project Title'),
                onChanged: (val) => projectName = val,
              ),
              const SizedBox(height: 14),
              TextField(
                decoration: _inputDecoration('Short Description'),
                onChanged: (val) => description = val,
              ),
              const SizedBox(height: 14),
              TextField(
                decoration: _inputDecoration('Duration (e.g. 3 months)'),
                onChanged: (val) => duration = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                if (projectName.trim().isNotEmpty) {
                  setState(
                    () => projects.add({
                      'name': projectName.trim(),
                      'description': description.trim(),
                      'duration': duration.trim(),
                    }),
                  );
                  _updateProgress();
                  saveResume(isSilent: true);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ────────────────────────────────
  // Dialog — Accomplishment
  // ────────────────────────────────
  void _showAddAccomplishmentDialog() {
    String title = '';
    String detail = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Accomplishment',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: _inputDecoration('Title'),
                onChanged: (val) => title = val,
              ),
              const SizedBox(height: 14),
              TextField(
                decoration: _inputDecoration('Details'),
                maxLines: 2,
                onChanged: (val) => detail = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                if (title.trim().isNotEmpty) {
                  setState(
                    () => accomplishments.add({
                      'title': title.trim(),
                      'detail': detail.trim(),
                    }),
                  );
                  _updateProgress();
                  saveResume(isSilent: true);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateResumeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload new resume',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Supported formats: doc, docx, rtf, pdf up to 2 MB',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      final result = await FilePicker.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'doc', 'docx', 'rtf'],
                      );
                      if (result != null && result.files.isNotEmpty) {
                        setState(() {
                          resumeFileName = result.files.single.name;
                          resumeUploadedOn = _formatDate(DateTime.now());
                        });
                        _updateProgress();
                        saveResume(isSilent: true);
                      }
                    } catch (e) {
                      debugPrint('File picker error: $e');
                    }
                  },
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: const Text(
                    'Choose file',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ────────────────────────────────
  // Build
  // ────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _updateProgress();
        saveResume(isSilent: true);
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () async {
              await _updateProgress();
              await saveResume(isSilent: true);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
          ),
        title: const Text(
          'Create Resume',
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile Photo ──
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.limeSoft,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Live Resume Score / Progress Card ──
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.speed_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Resume Score ($completedSectionsCount/9)',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.limeSoft,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '$currentPercentage%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (currentPercentage / 100.0).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppColors.scaffoldBackground,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentPercentage == 0
                          ? 'Start by entering your personal information below.'
                          : currentPercentage < 50
                              ? 'Good start! Add education, skills, and work experience.'
                              : currentPercentage < 100
                                  ? 'Almost complete! Add projects & certifications.'
                                  : 'Great job! Your resume profile is 100% complete.',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // ── 1. Personal Details ──
              _sectionCard(
                title: 'Personal Details',
                isCompleted: _isPersonalDetailsComplete,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    _buildTextField(
                      controller: emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      controller: phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: dobController,
                      label: 'Date of Birth',
                      icon: Icons.cake_outlined,
                      readOnly: true,
                      onTap: _pickDateOfBirth,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(_safeGender),
                        initialValue: _safeGender,
                        decoration: _inputDecoration(
                          'Gender',
                          icon: Icons.wc_outlined,
                        ),
                        items: genderOptions
                            .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() => selectedGender = val);
                          _updateProgress();
                          saveResume(isSilent: true);
                        },
                      ),
                    ),
                    _buildTextField(
                      controller: addressController,
                      label: 'Address',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              // ── 2. Resume file card (Naukri-style) ──
              _sectionCard(
                title: 'Resume',
                isCompleted: resumeFileName.trim().isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (resumeFileName.trim().isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.limeSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resumeFileName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Uploaded on $resumeUploadedOn',
                                  style: const TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.scaffoldBackground,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.download_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                resumeFileName = '';
                                resumeUploadedOn = '';
                              });
                              _updateProgress();
                              saveResume(isSilent: true);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.scaffoldBackground,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    InkWell(
                      onTap: _showUpdateResumeSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              resumeFileName.isNotEmpty
                                  ? 'Update resume'
                                  : 'Upload resume',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Supported Formats: doc, docx, rtf, pdf, upto 2 MB',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 3. Resume Headline / Career Objective ──
              _sectionCard(
                title: 'Resume Headline',
                isCompleted: _isObjectiveComplete,
                onEdit: () {},
                child: _buildTextField(
                  controller: objectiveController,
                  label: 'Write a short career objective / summary',
                  icon: Icons.flag_outlined,
                  maxLines: 3,
                ),
              ),

              // ── 4. Key Skills ──
              _sectionCard(
                title: 'Key Skills',
                subtitle: '${skills.length} skills added',
                isCompleted: _isSkillsComplete,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills.asMap().entries.map((entry) {
                        final index = entry.key;
                        final skill = entry.value;
                        return _buildTagChip(
                          name: skill['name'] ?? '',
                          level: skill['level'] ?? 'Beginner',
                          onRemove: () {
                            setState(() => skills.removeAt(index));
                            _updateProgress();
                            saveResume(isSilent: true);
                          },
                        );
                      }).toList(),
                    ),
                    if (suggestedSkills.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Suggested Skills',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: suggestedSkills.map((s) {
                          return _buildSuggestedChip(s, () {
                            setState(() {
                              skills.add({'name': s, 'level': 'Beginner'});
                              suggestedSkills.remove(s);
                            });
                            _updateProgress();
                            saveResume(isSilent: true);
                          });
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _addButton('Add Skill', _showAddSkillDialog),
                  ],
                ),
              ),

              // ── 5. Employment / Work Experience ──
              _sectionCard(
                title: 'Employment',
                subtitle: '${experiences.length} entries added',
                isCompleted: _isExperienceComplete,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...experiences.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exp = entry.value;
                      return _buildInfoCard(
                        icon: Icons.work_outline,
                        title: exp['role'] ?? '',
                        subtitle: exp['company'] ?? '',
                        caption: exp['duration'] ?? '',
                        onRemove: () {
                          setState(() => experiences.removeAt(index));
                          _updateProgress();
                          saveResume(isSilent: true);
                        },
                      );
                    }),
                    _addButton('Add Employment', _showAddExperienceDialog),
                  ],
                ),
              ),

              // ── 6. Education ──
              _sectionCard(
                title: 'Education',
                subtitle: '${education.length} entries added',
                isCompleted: _isEducationComplete,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...education.asMap().entries.map((entry) {
                      final index = entry.key;
                      final edu = entry.value;
                      return _buildInfoCard(
                        icon: Icons.school_outlined,
                        title: edu['degree'] ?? '',
                        subtitle: edu['institution'] ?? '',
                        caption: edu['year'] ?? '',
                        onRemove: () {
                          setState(() => education.removeAt(index));
                          _updateProgress();
                          saveResume(isSilent: true);
                        },
                      );
                    }),
                    _addButton('Add Education', _showAddEducationDialog),
                  ],
                ),
              ),

              // ── 7. IT Skills ──
              _sectionCard(
                title: 'IT Skills',
                subtitle: '${certifications.length} entries added',
                isCompleted: _isCertificationsComplete,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...certifications.asMap().entries.map((entry) {
                      final index = entry.key;
                      final cert = entry.value;
                      return _buildInfoCard(
                        icon: Icons.card_membership_outlined,
                        title: cert['name'] ?? '',
                        subtitle: cert['organization'] ?? '',
                        caption: cert['year'] ?? '',
                        onRemove: () {
                          setState(() => certifications.removeAt(index));
                          _updateProgress();
                          saveResume(isSilent: true);
                        },
                      );
                    }),
                    _addButton(
                      'Add Certification',
                      _showAddCertificationDialog,
                    ),
                  ],
                ),
              ),

              // ── 8. Projects ──
              _sectionCard(
                title: 'Projects',
                subtitle: '${projects.length} entries added',
                isCompleted: _isProjectsComplete,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...projects.asMap().entries.map((entry) {
                      final index = entry.key;
                      final proj = entry.value;
                      return _buildInfoCard(
                        icon: Icons.folder_open_outlined,
                        title: proj['name'] ?? proj['title'] ?? '',
                        subtitle: proj['description'] ?? '',
                        caption: proj['duration'] ?? '',
                        onRemove: () {
                          setState(() => projects.removeAt(index));
                          _updateProgress();
                          saveResume(isSilent: true);
                        },
                      );
                    }),
                    _addButton('Add Project', _showAddProjectDialog),
                  ],
                ),
              ),

              // ── 9. Profile Summary ──
              _sectionCard(
                title: 'Profile Summary',
                isCompleted: _isObjectiveComplete,
                child: Text(
                  objectiveController.text.trim().isEmpty
                      ? 'Add a profile summary to tell employers about your experience, key skills and career goals.'
                      : objectiveController.text.trim(),
                  style: TextStyle(
                    color: objectiveController.text.trim().isEmpty
                        ? AppColors.textHint
                        : AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),

              // ── 10. Accomplishments ──
              _sectionCard(
                title: 'Accomplishments',
                subtitle: '${accomplishments.length} entries added',
                isCompleted: _isAccomplishmentsComplete,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...accomplishments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final acc = entry.value;
                      return _buildInfoCard(
                        icon: Icons.emoji_events_outlined,
                        title: acc['title'] ?? '',
                        subtitle: acc['detail'] ?? '',
                        caption: '',
                        onRemove: () {
                          setState(() => accomplishments.removeAt(index));
                          _updateProgress();
                          saveResume(isSilent: true);
                        },
                      );
                    }),
                    _addButton(
                      'Add Accomplishment',
                      _showAddAccomplishmentDialog,
                    ),
                  ],
                ),
              ),

              // ── 11. Career Profile (Languages) ──
              _sectionCard(
                title: 'Career Profile',
                subtitle: '${languages.length} languages added',
                isCompleted: _isLanguagesComplete,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Languages Known',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: languages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final lang = entry.value;
                        return _buildTagChip(
                          name: lang['name'] ?? '',
                          level: lang['level'] ?? 'Beginner',
                          onRemove: () {
                            setState(() => languages.removeAt(index));
                            _updateProgress();
                            saveResume(isSilent: true);
                          },
                        );
                      }).toList(),
                    ),
                    if (suggestedLanguages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Suggested Languages',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: suggestedLanguages.map((l) {
                          return _buildSuggestedChip(l, () {
                            setState(() {
                              languages.add({'name': l, 'level': 'Beginner'});
                              suggestedLanguages.remove(l);
                            });
                            _updateProgress();
                            saveResume(isSilent: true);
                          });
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _addButton('Add Language', _showAddLanguageDialog),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Submit Button ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await saveResume(isSilent: false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Resume',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}
}
