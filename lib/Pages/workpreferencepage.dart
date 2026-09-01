import 'package:flutter/material.dart';
import 'package:hyper_local/utils/app_colors.dart';

class WorkPreferencePage extends StatefulWidget {
  const WorkPreferencePage({super.key});

  @override
  State<WorkPreferencePage> createState() => _WorkPreferencePageState();
}

class _WorkPreferencePageState extends State<WorkPreferencePage> {
  // ---- Data ----
  final List<String> _workTypes = const [
    "Full-time",
    "Part-time",
    "Contract",
    "Freelance",
    "Internship",
  ];

  final List<String> _workModes = const [
    "On-site",
    "Remote",
    "Hybrid",
  ];

  final List<String> _availability = const [
    "Immediately",
    "Within 1 week",
    "Within 1 month",
    "Flexible",
  ];

  // ---- Selected state ----
  final Set<String> _selectedWorkTypes = {"Full-time"};
  String _selectedWorkMode = "On-site";
  String _selectedAvailability = "Immediately";

  double _minSalary = 15000;
  double _maxSalary = 60000;

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
          "Work Preference",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tell us how you like to work",
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // ---- Work Type (multi-select) ----
            _sectionTitle("Work Type", "Select all that apply"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _workTypes.map((type) {
                final isSelected = _selectedWorkTypes.contains(type);
                return _choiceChip(
                  label: type,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedWorkTypes.remove(type);
                      } else {
                        _selectedWorkTypes.add(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ---- Work Mode (single-select) ----
            _sectionTitle("Work Mode", "Choose one"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _workModes.map((mode) {
                final isSelected = _selectedWorkMode == mode;
                return _choiceChip(
                  label: mode,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedWorkMode = mode),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ---- Availability (single-select list) ----
            _sectionTitle("Availability", "When can you start?"),
            const SizedBox(height: 12),
            Column(
              children: _availability.map((item) {
                final isSelected = _selectedAvailability == item;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _selectedAvailability = item),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.08)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 1.4 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.selected : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.selected
                                    : AppColors.unselected,
                                width: 1.6,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 13, color: AppColors.buttonText)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ---- Salary Range ----
            _sectionTitle("Expected Salary Range", "Per month, in ₹"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${_minSalary.toInt()}",
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "₹${_maxSalary.toInt()}",
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: RangeValues(_minSalary, _maxSalary),
                    min: 5000,
                    max: 150000,
                    divisions: 29,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    labels: RangeLabels(
                      "₹${_minSalary.toInt()}",
                      "₹${_maxSalary.toInt()}",
                    ),
                    onChanged: (values) {
                      setState(() {
                        _minSalary = values.start;
                        _maxSalary = values.end;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---- Continue Button ----
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: save preferences (SharedPreferences / provider / API call)
                  Navigator.pop(context, {
                    "workTypes": _selectedWorkTypes.toList(),
                    "workMode": _selectedWorkMode,
                    "availability": _selectedAvailability,
                    "minSalary": _minSalary,
                    "maxSalary": _maxSalary,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: AppColors.buttonText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ---- Reusable widgets ----

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _choiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.buttonText : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}