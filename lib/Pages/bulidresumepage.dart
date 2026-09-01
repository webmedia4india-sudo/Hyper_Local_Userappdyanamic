// C:\flutter-projects\hyper_local\lib\Pages\buildresumepage.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// ---------------- Models ----------------
class ResumeEducation {
  final TextEditingController degree = TextEditingController();
  final TextEditingController institution = TextEditingController();
  final TextEditingController year = TextEditingController();
}

class ResumeExperience {
  final TextEditingController title = TextEditingController();
  final TextEditingController company = TextEditingController();
  final TextEditingController duration = TextEditingController();
  final TextEditingController description = TextEditingController();
}

// ---------------- Build Resume Page ----------------
class BuildResumePage extends StatefulWidget {
  const BuildResumePage({super.key});

  @override
  State<BuildResumePage> createState() => _BuildResumePageState();
}

class _BuildResumePageState extends State<BuildResumePage> {
  final _formKey = GlobalKey<FormState>();

  // Personal details
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _summaryController = TextEditingController();

  final List<ResumeEducation> _educationList = [ResumeEducation()];
  final List<ResumeExperience> _experienceList = [ResumeExperience()];

  final List<String> _skills = [];
  final TextEditingController _skillController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _addEducation() {
    setState(() => _educationList.add(ResumeEducation()));
  }

  void _removeEducation(int index) {
    if (_educationList.length == 1) return;
    setState(() => _educationList.removeAt(index));
  }

  void _addExperience() {
    setState(() => _experienceList.add(ResumeExperience()));
  }

  void _removeExperience(int index) {
    if (_experienceList.length == 1) return;
    setState(() => _experienceList.removeAt(index));
  }

  void _addSkill(String value) {
    final skill = value.trim();
    if (skill.isEmpty) return;
    if (_skills.any((s) => s.toLowerCase() == skill.toLowerCase())) {
      _skillController.clear();
      return;
    }
    setState(() {
      _skills.add(skill);
      _skillController.clear();
    });
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  void _saveResume() {
    if (!_formKey.currentState!.validate()) return;

    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one skill"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // TODO: hook up backend / save-to-profile logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Resume saved successfully!"),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
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
          "Build Resume",
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
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            _buildSectionTitle("Personal Details", Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _buildTextField(controller: _nameController, label: "Full Name", icon: Icons.badge_outlined, required: true),
            const SizedBox(height: 12),
            _buildTextField(controller: _titleController, label: "Job Title (e.g. Flutter Developer)", icon: Icons.work_outline_rounded, required: true),
            const SizedBox(height: 12),
            _buildTextField(controller: _emailController, label: "Email", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, required: true),
            const SizedBox(height: 12),
            _buildTextField(controller: _phoneController, label: "Phone Number", icon: Icons.phone_outlined, keyboardType: TextInputType.phone, required: true),
            const SizedBox(height: 12),
            _buildTextField(controller: _locationController, label: "Location (City, State)", icon: Icons.location_on_outlined, required: true),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _summaryController,
              label: "Professional Summary",
              icon: Icons.notes_rounded,
              maxLines: 3,
              required: true,
            ),

            const SizedBox(height: 24),
            _buildSectionTitle("Skills", Icons.code_rounded),
            const SizedBox(height: 12),
            _buildSkillInput(),
            if (_skills.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildSkillsWrap(),
            ],

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Education", Icons.school_outlined),
                _addButton(onTap: _addEducation),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_educationList.length, (index) => _buildEducationCard(index)),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Experience", Icons.work_history_outlined),
                _addButton(onTap: _addExperience),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_experienceList.length, (index) => _buildExperienceCard(index)),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: AppColors.buttonText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Save Resume",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Title ──────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _addButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 15, color: AppColors.primary),
            SizedBox(width: 3),
            Text(
              "Add",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable Text Field ─────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      validator: required
          ? (value) => (value == null || value.trim().isEmpty) ? "This field is required" : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
      ),
    );
  }

  // ── Skills Input ─────────────────────────────────
  Widget _buildSkillInput() {
    return TextField(
      controller: _skillController,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: "Type a skill and press enter",
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        prefixIcon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.textHint, size: 20),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
      textInputAction: TextInputAction.done,
      onSubmitted: _addSkill,
    );
  }

  Widget _buildSkillsWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _skills.asMap().entries.map((entry) {
        final color = AppColors.accents[entry.key % AppColors.accents.length];
        return Container(
          padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.value,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _removeSkill(entry.value),
                child: Icon(Icons.close_rounded, size: 15, color: color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Education Card ────────────────────────────────
  Widget _buildEducationCard(int index) {
    final edu = _educationList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Education ${index + 1}",
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const Spacer(),
              if (_educationList.length > 1)
                GestureDetector(
                  onTap: () => _removeEducation(index),
                  child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTextField(controller: edu.degree, label: "Degree / Course", icon: Icons.school_outlined, required: true),
          const SizedBox(height: 10),
          _buildTextField(controller: edu.institution, label: "Institution / University", icon: Icons.apartment_outlined, required: true),
          const SizedBox(height: 10),
          _buildTextField(controller: edu.year, label: "Year of Passing", icon: Icons.calendar_today_outlined, required: true),
        ],
      ),
    );
  }

  // ── Experience Card ───────────────────────────────
  Widget _buildExperienceCard(int index) {
    final exp = _experienceList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Experience ${index + 1}",
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const Spacer(),
              if (_experienceList.length > 1)
                GestureDetector(
                  onTap: () => _removeExperience(index),
                  child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTextField(controller: exp.title, label: "Job Title", icon: Icons.work_outline_rounded),
          const SizedBox(height: 10),
          _buildTextField(controller: exp.company, label: "Company Name", icon: Icons.business_outlined),
          const SizedBox(height: 10),
          _buildTextField(controller: exp.duration, label: "Duration (e.g. Jan 2023 - Present)", icon: Icons.date_range_outlined),
          const SizedBox(height: 10),
          _buildTextField(controller: exp.description, label: "Description", icon: Icons.notes_rounded, maxLines: 3),
        ],
      ),
    );
  }
}