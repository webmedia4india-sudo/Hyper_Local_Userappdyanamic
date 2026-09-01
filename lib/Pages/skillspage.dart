// C:\flutter-projects\hyper_local\lib\utils\app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // ── PRIMARY COLORS (Electric Blue + Lime Green from HiHR logo) ──
  static const Color primary = Color(0xFF1E3AE2); // Main electric blue (buttons, active states)
  static const Color primaryDark = Color(0xFF1526A8); // Darker blue for pressed/hover
  static const Color primaryDeep = Color(0xFF0D1B7A); // Deepest blue (headers/drawer)
  static const Color primaryLight = Color(0xFF5C74F0); // Lighter blue accent

  // ── ACCENT COLORS (Lime green dot from logo — used across cards, logos, categories) ──
  static const Color lime = Color(0xFFA6D608); // Signature lime green (logo dot)
  static const Color limeSoft = Color(0xFFE3F5A8);
  static const Color pink = Color(0xFFF48FB1);
  static const Color pinkSoft = Color(0xFFFFD6E7);
  static const Color coral = Color(0xFFFF8A75);
  static const Color coralSoft = Color(0xFFFFD9CF);
  static const Color mint = Color(0xFF3DDC97);
  static const Color mintSoft = Color(0xFFC8F7E6);

  // cycling accent list (for cards / logos / categories)
  static const List<Color> accents = [primary, lime, coral, mint, pink];
  static const List<Color> accentsSoft = [
    Color(0xFFDCE3FF),
    limeSoft,
    coralSoft,
    mintSoft,
    pinkSoft,
  ];

  // ── HEADER / DRAWER (solid electric blue, no gradient — matches logo bg) ──
  static const Color headerColor = primaryDeep;
  static const Color drawerColor = primaryDeep;

  // Gradient (used on splash/illustration screens)
  static const Color gradientStart = Color(0xFF1E3AE2); // Electric blue
  static const Color gradientEnd = Color(0xFF0D1B7A); // Deep blue
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );

  // Background Colors
  static const Color background = Color(0xFFFFFFFF); // White background
  static const Color scaffoldBackground = Color(0xFFF7F8FF); // Very light blue-white

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Headings
  static const Color textSecondary = Color(0xFF6B7280); // Subtext/description (gray)
  static const Color textHint = Color(0xFF9CA3AF); // Hint text in fields

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0); // Input field borders
  static const Color divider = Color(0xFFEEEEEE);

  // Button Colors
  static const Color buttonPrimary = primary;
  static const Color buttonText = Color(0xFFFFFFFF);

  // Selected/Active States
  static const Color selected = primary;
  static const Color unselected = Color(0xFFBDBDBD);

  // Social Login Icons Background
  static const Color socialIconBg = Color.fromRGBO(245, 245, 245, 1);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);

  // OTP Box
  static const Color otpBoxBg = Color(0xFFF1F5F9);
  static const Color otpBoxBorder = Color(0xFFCBD5E1);

  // Map/Location Screen
  static const Color mapPinRed = Color(0xFFE53935);
  static const Color mapPinBlue = primary;

  static Gradient? get drawerGradient => null;
}

// ---------------- Skill Model ----------------
class SkillModel {
  String name;
  String level; // Beginner, Intermediate, Expert

  SkillModel({required this.name, this.level = "Intermediate"});
}

// ---------------- Skills Page ----------------
class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key});

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  final List<SkillModel> _skills = [
    SkillModel(name: "Flutter", level: "Expert"),
    SkillModel(name: "Dart", level: "Expert"),
    SkillModel(name: "Firebase", level: "Intermediate"),
    SkillModel(name: "REST API", level: "Intermediate"),
    SkillModel(name: "Git", level: "Beginner"),
  ];

  final List<String> _suggestedSkills = [
    "UI/UX Design",
    "Node.js",
    "MySQL",
    "Java",
    "Kotlin",
    "Python",
    "SQL",
    "Photoshop",
  ];

  String _selectedLevel = "Intermediate";

  void _openAddSkillSheet() {
    final controller = TextEditingController();
    _selectedLevel = "Intermediate";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const Text(
                      "Add Skill",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: "Skill Name",
                        labelStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.scaffoldBackground,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Proficiency Level",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: ["Beginner", "Intermediate", "Expert"].map((level) {
                        final isSelected = _selectedLevel == level;
                        return ChoiceChip(
                          label: Text(level),
                          selected: isSelected,
                          onSelected: (_) {
                            setModalState(() => _selectedLevel = level);
                          },
                          backgroundColor: AppColors.scaffoldBackground,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.buttonText : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final name = controller.text.trim();
                          if (name.isEmpty) return;
                          setState(() {
                            _skills.add(SkillModel(name: name, level: _selectedLevel));
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Add Skill",
                          style: TextStyle(
                            color: AppColors.buttonText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
  }

  void _addSuggested(String name) {
    if (_skills.any((s) => s.name.toLowerCase() == name.toLowerCase())) return;
    setState(() {
      _skills.add(SkillModel(name: name));
    });
  }

  Color _levelColor(String level) {
    switch (level) {
      case "Expert":
        return AppColors.primaryDark;
      case "Beginner":
        return AppColors.primaryLight;
      default:
        return AppColors.primary; // Intermediate
    }
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
          "Skills",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _openAddSkillSheet,
        child: const Icon(Icons.add, color: AppColors.buttonText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Skills",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${_skills.length} skill${_skills.length == 1 ? '' : 's'} added",
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            _skills.isEmpty ? _buildEmptyState() : _buildSkillsWrap(),
            const SizedBox(height: 28),
            const Text(
              "Suggested Skills",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _suggestedSkills.map((skill) {
                final alreadyAdded =
                    _skills.any((s) => s.name.toLowerCase() == skill.toLowerCase());
                return GestureDetector(
                  onTap: alreadyAdded ? null : () => _addSuggested(skill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: alreadyAdded
                          ? AppColors.divider
                          : AppColors.primaryLight.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: alreadyAdded ? AppColors.divider : AppColors.primaryLight,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          alreadyAdded ? Icons.check : Icons.add,
                          size: 15,
                          color: alreadyAdded ? AppColors.textHint : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          skill,
                          style: TextStyle(
                            fontSize: 13,
                            color: alreadyAdded ? AppColors.textHint : AppColors.primaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_outline, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text(
            "No Skills Added Yet",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Tap + or pick from suggestions below",
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsWrap() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_skills.length, (index) {
        final skill = _skills[index];
        return Container(
          padding: const EdgeInsets.only(left: 14, right: 6, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _levelColor(skill.level),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                skill.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "· ${skill.level}",
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              GestureDetector(
                onTap: () => _removeSkill(index),
                child: Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.otpBoxBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}