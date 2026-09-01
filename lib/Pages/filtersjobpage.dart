import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FiltersJobPage extends StatefulWidget {
  const FiltersJobPage({super.key});

  @override
  State<FiltersJobPage> createState() => _FiltersJobPageState();
}

class _FiltersJobPageState extends State<FiltersJobPage> {
  // ── SORTING STATE ──
  String _selectedSort = "Recommended";
  final List<String> sortingOptions = [
    "Recommended",
    "Nearest",
    "Latest",
    "Highest salary",
    "Most vacancies",
  ];

  // ── LOCATION STATE ──
  bool _locationEnabled = true;
  double _radiusKm = 5;
  final TextEditingController _cityController = TextEditingController(text: "Mumbai");
  final TextEditingController _localityController = TextEditingController(text: "Bhandup");

  // ── JOB TYPE STATE ──
  final List<String> jobTypes = [
    "Full-time",
    "Part-time",
    "Contract",
    "Temporary",
    "Internship",
    "Freelance",
    "Gig",
  ];
  final Set<String> _selectedJobTypes = {};

  // ── EXPERIENCE STATE ──
  final List<String> experienceOptions = [
    "Fresher",
    "0–1 years",
    "1–3 years",
    "3–5 years",
    "5+ years",
  ];
  String? _selectedExperience;

  // ── SALARY RANGE STATE ──
  RangeValues _salaryRange = const RangeValues(15000, 75000);

  // ── ADDITIONAL FILTERS STATE ──
  bool _workFromHome = false;
  bool _immediateJoining = false;
  bool _verifiedEmployer = false;
  bool _walkInInterview = false;
  bool _femaleFriendly = false;
  bool _nightShift = false;
  bool _accommodationAvailable = false;

  @override
  void dispose() {
    _cityController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedSort = "Recommended";
      _locationEnabled = true;
      _radiusKm = 5;
      _cityController.text = "Mumbai";
      _localityController.text = "Bhandup";
      _selectedJobTypes.clear();
      _selectedExperience = null;
      _salaryRange = const RangeValues(15000, 75000);
      _workFromHome = false;
      _immediateJoining = false;
      _verifiedEmployer = false;
      _walkInInterview = false;
      _femaleFriendly = false;
      _nightShift = false;
      _accommodationAvailable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.buttonText, size: 20),
        ),
        title: const Text(
          "Filters",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text(
              "Clear All",
              style: TextStyle(
                color: AppColors.buttonText,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── SORTING SECTION ──
              _sectionHeader("Sort Results By"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sortingOptions.map((opt) {
                  final isSelected = _selectedSort == opt;
                  return ChoiceChip(
                    label: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.scaffoldBackground,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedSort = opt);
                      }
                    },
                  );
                }).toList(),
              ),
              _sectionDivider(),

              // ── LOCATION SECTION ──
              _sectionHeader("Location Options"),
              const SizedBox(height: 12),
              // Current Location Switch
              Row(
                children: [
                  const Icon(
                    Icons.my_location_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Use Current Location",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    value: _locationEnabled,
                    activeThumbColor: AppColors.buttonText,
                    activeTrackColor: AppColors.primary,
                    inactiveThumbColor: AppColors.unselected,
                    inactiveTrackColor: AppColors.border,
                    onChanged: (value) {
                      setState(() => _locationEnabled = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // City & Locality Input Fields
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      controller: _cityController,
                      label: "City",
                      icon: Icons.location_city_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      controller: _localityController,
                      label: "Locality",
                      icon: Icons.streetview_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Radius Selection Slider
              if (_locationEnabled) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Maximum Travel Radius",
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${_radiusKm.toInt()} km",
                      style: const TextStyle(fontSize: 12.5, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: _radiusKm,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  onChanged: (val) {
                    setState(() => _radiusKm = val);
                  },
                ),
              ],
              _sectionDivider(),

              // ── JOB TYPE SECTION ──
              _sectionHeader("Job Type"),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 6,
                ),
                itemCount: jobTypes.length,
                itemBuilder: (context, index) {
                  final type = jobTypes[index];
                  final isChecked = _selectedJobTypes.contains(type);
                  return _checkboxTile(
                    label: type,
                    value: isChecked,
                    onTap: () {
                      setState(() {
                        if (isChecked) {
                          _selectedJobTypes.remove(type);
                        } else {
                          _selectedJobTypes.add(type);
                        }
                      });
                    },
                  );
                },
              ),
              _sectionDivider(),

              // ── EXPERIENCE SECTION ──
              _sectionHeader("Experience Level"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: experienceOptions.map((exp) {
                  final isSelected = _selectedExperience == exp;
                  return ChoiceChip(
                    label: Text(
                      exp,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.scaffoldBackground,
                    onSelected: (selected) {
                      setState(() {
                        _selectedExperience = selected ? exp : null;
                      });
                    },
                  );
                }).toList(),
              ),
              _sectionDivider(),

              // ── SALARY SECTION ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader("Salary Range (Monthly)"),
                  Text(
                    "₹${_salaryRange.start.round()} - ₹${_salaryRange.end.round()}",
                    style: const TextStyle(fontSize: 12.5, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              RangeSlider(
                values: _salaryRange,
                min: 5000,
                max: 150000,
                divisions: 29,
                labels: RangeLabels(
                  "₹${_salaryRange.start.round()}",
                  "₹${_salaryRange.end.round()}",
                ),
                activeColor: AppColors.primary,
                inactiveColor: AppColors.border,
                onChanged: (RangeValues vals) {
                  setState(() => _salaryRange = vals);
                },
              ),
              _sectionDivider(),

              // ── ADDITIONAL FILTERS SECTION ──
              _sectionHeader("Additional Filters"),
              const SizedBox(height: 10),
              Column(
                children: [
                  _switchTile("Work From Home", _workFromHome, (val) => setState(() => _workFromHome = val)),
                  _switchTile("Immediate Joining", _immediateJoining, (val) => setState(() => _immediateJoining = val)),
                  _switchTile("Verified Employer Only", _verifiedEmployer, (val) => setState(() => _verifiedEmployer = val)),
                  _switchTile("Walk-in Interview Only", _walkInInterview, (val) => setState(() => _walkInInterview = val)),
                  _switchTile("Female-Friendly Jobs", _femaleFriendly, (val) => setState(() => _femaleFriendly = val)),
                  _switchTile("Night Shift Jobs", _nightShift, (val) => setState(() => _nightShift = val)),
                  _switchTile("Accommodation / Lodging Available", _accommodationAvailable, (val) => setState(() => _accommodationAvailable = val)),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // ── APPLY FILTERS BUTTON ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: const Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "sortBy": _selectedSort,
                  "locationEnabled": _locationEnabled,
                  "city": _cityController.text.trim(),
                  "locality": _localityController.text.trim(),
                  "radiusKm": _radiusKm,
                  "jobTypes": _selectedJobTypes,
                  "experience": _selectedExperience,
                  "minSalary": _salaryRange.start,
                  "maxSalary": _salaryRange.end,
                  "workFromHome": _workFromHome,
                  "immediateJoining": _immediateJoining,
                  "verifiedEmployer": _verifiedEmployer,
                  "walkInInterview": _walkInInterview,
                  "femaleFriendly": _femaleFriendly,
                  "nightShift": _nightShift,
                  "accommodationAvailable": _accommodationAvailable,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.buttonText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Apply Filters",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── HELPER STYLING METHODS ──
  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _sectionDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: AppColors.divider, height: 1),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 16, color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _checkboxTile({
    required String label,
    required bool value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: value ? AppColors.primary : AppColors.border,
                  width: 1.4,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: AppColors.buttonText,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.buttonText,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: AppColors.unselected,
            inactiveTrackColor: AppColors.border,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}