import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyper_local/utils/app_colors.dart';

class LanguagesPage extends StatefulWidget {
  const LanguagesPage({super.key});

  @override
  State<LanguagesPage> createState() => _LanguagesPageState();
}

class _LanguagesPageState extends State<LanguagesPage> {
  // Key used to store the selected language locally (SharedPreferences)
  static const String _prefsKey = "app_selected_language";

  // ── MVP LANGUAGES (enabled, user can select) ────────────────────
  // As per requirement: MVP supports English, Hindi, Marathi only.
  final List<Map<String, String>> _mvpLanguages = const [
    {"name": "English", "native": "English", "flag": "🇬🇧"},
    {"name": "Hindi", "native": "हिन्दी", "flag": "🇮🇳"},
    {"name": "Marathi", "native": "मराठी", "flag": "🇮🇳"},
  ];

  // ── ADDITIONAL LANGUAGES ────────────────────
  // Not enabled in MVP - shown as "Coming Soon" / admin-controlled.
  // Can be enabled later via admin settings without changing this UI.
  final List<Map<String, String>> _additionalLanguages = const [
    {"name": "Gujarati", "native": "ગુજરાતી", "flag": "🇮🇳"},
    {"name": "Tamil", "native": "தமிழ்", "flag": "🇮🇳"},
    {"name": "Telugu", "native": "తెలుగు", "flag": "🇮🇳"},
    {"name": "Kannada", "native": "ಕನ್ನಡ", "flag": "🇮🇳"},
    {"name": "Bengali", "native": "বাংলা", "flag": "🇮🇳"},
    {"name": "Punjabi", "native": "ਪੰਜਾਬੀ", "flag": "🇮🇳"},
    {"name": "Urdu", "native": "اردو", "flag": "🇮🇳"},
  ];

  String _selectedLanguage = "English"; // default selected
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  // Load previously saved language from local storage (if any)
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    setState(() {
      if (saved != null &&
          _mvpLanguages.any((lang) => lang["name"] == saved)) {
        _selectedLanguage = saved;
      }
      _isLoading = false;
    });
  }

  // Applies the language immediately and stores it locally.
  // TODO: also sync selected language with the server (API call) here,
  // e.g. await ApiService.updateUserLanguage(_selectedLanguage);
  Future<void> _applyLanguage() async {
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _selectedLanguage);

    // Server sync hook point:
    // await ApiService.updateUserLanguage(_selectedLanguage);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Language changed to $_selectedLanguage"),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context, _selectedLanguage);
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
          "Language",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Subtitle
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Choose your preferred language",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // ── AVAILABLE (MVP) LANGUAGES ────────────────────
                      _sectionLabel("Available Languages"),
                      const SizedBox(height: 8),
                      ..._mvpLanguages.map((lang) {
                        final isSelected = lang["name"] == _selectedLanguage;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _languageCard(
                            lang: lang,
                            isSelected: isSelected,
                            enabled: true,
                            onTap: () {
                              setState(() => _selectedLanguage = lang["name"]!);
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // ── ADDITIONAL LANGUAGES (ADMIN-CONTROLLED) ────
                      _sectionLabel("More Languages"),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          "These languages can be enabled by the admin.",
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      ..._additionalLanguages.map((lang) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _languageCard(
                            lang: lang,
                            isSelected: false,
                            enabled: false,
                            onTap: null,
                          ),
                        );
                      }),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // Continue / Apply button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _applyLanguage,
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
                              "Continue",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ── SECTION LABEL HELPER ────────────────────
  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ── LANGUAGE CARD (enabled / disabled) ────────────────────
  Widget _languageCard({
    required Map<String, String> lang,
    required bool isSelected,
    required bool enabled,
    required VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
              Text(lang["flag"]!, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang["name"]!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lang["native"]!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Enabled: selected check / unselected circle.
              // Disabled: lock icon + "Coming Soon" badge.
              if (enabled)
                Container(
                  width: 22,
                  height: 22,
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
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.buttonText,
                        )
                      : null,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 12,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Soon",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}