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

// ---------------- Model ----------------
class ExperienceModel {
  String title;
  String company;
  String duration;
  String description;

  ExperienceModel({
    required this.title,
    required this.company,
    required this.duration,
    required this.description,
  });
}

// ---------------- Experience Page ----------------
class ExperiencePage extends StatefulWidget {
  const ExperiencePage({super.key});

  @override
  State<ExperiencePage> createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
  final List<ExperienceModel> _experiences = [
    ExperienceModel(
      title: "Flutter Developer",
      company: "TechNova Pvt. Ltd.",
      duration: "Jan 2023 - Present",
      description:
          "Built and maintained multiple cross-platform mobile applications using Flutter, integrated REST APIs, and worked closely with design team.",
    ),
    ExperienceModel(
      title: "Junior App Developer",
      company: "Softline Solutions",
      duration: "Jun 2021 - Dec 2022",
      description:
          "Worked on UI development, bug fixing and testing for Android applications built with Flutter and native modules.",
    ),
  ];

  void _openExperienceForm({ExperienceModel? experience, int? index}) {
    final titleController = TextEditingController(text: experience?.title ?? "");
    final companyController = TextEditingController(text: experience?.company ?? "");
    final durationController = TextEditingController(text: experience?.duration ?? "");
    final descriptionController =
        TextEditingController(text: experience?.description ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                Text(
                  experience == null ? "Add Experience" : "Edit Experience",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(controller: titleController, label: "Job Title"),
                const SizedBox(height: 14),
                _buildTextField(controller: companyController, label: "Company Name"),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: durationController,
                  label: "Duration (e.g. Jan 2023 - Present)",
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: descriptionController,
                  label: "Description",
                  maxLines: 4,
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
                      if (titleController.text.trim().isEmpty ||
                          companyController.text.trim().isEmpty) {
                        return;
                      }
                      setState(() {
                        if (experience == null) {
                          _experiences.add(
                            ExperienceModel(
                              title: titleController.text.trim(),
                              company: companyController.text.trim(),
                              duration: durationController.text.trim(),
                              description: descriptionController.text.trim(),
                            ),
                          );
                        } else {
                          _experiences[index!].title = titleController.text.trim();
                          _experiences[index].company = companyController.text.trim();
                          _experiences[index].duration = durationController.text.trim();
                          _experiences[index].description =
                              descriptionController.text.trim();
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      experience == null ? "Save Experience" : "Update Experience",
                      style: const TextStyle(
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
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
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
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: AppColors.background,
        title: const Text(
          "Delete Experience",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          "Are you sure you want to delete this experience?",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _experiences.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
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
          "Experience",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openExperienceForm(),
        child: const Icon(Icons.add, color: AppColors.buttonText),
      ),
      body: _experiences.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
              itemCount: _experiences.length,
              itemBuilder: (context, index) {
                final exp = _experiences[index];
                return _buildExperienceCard(exp, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.work_outline, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Experience Added",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Tap + to add your work experience",
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(ExperienceModel exp, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.work, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exp.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      exp.company,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      exp.duration,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textHint, size: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (value) {
                  if (value == "edit") {
                    _openExperienceForm(experience: exp, index: index);
                  } else if (value == "delete") {
                    _confirmDelete(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: "edit",
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: "delete",
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text("Delete"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (exp.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              exp.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}