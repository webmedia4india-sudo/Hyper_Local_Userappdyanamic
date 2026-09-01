import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AIResumeBuilderPage extends StatefulWidget {
  const AIResumeBuilderPage({super.key});

  @override
  State<AIResumeBuilderPage> createState() => _AIResumeBuilderPageState();
}

class _AIResumeBuilderPageState extends State<AIResumeBuilderPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── INPUT FIELDS CONTROLLERS ──
  final _nameCtrl = TextEditingController(text: "Rahul Sharma");
  final _designationCtrl = TextEditingController(text: "React Developer");
  final _phoneCtrl = TextEditingController(text: "+91 98765 43210");
  final _emailCtrl = TextEditingController(text: "rahul.sharma@tcs.com");
  final _locationCtrl = TextEditingController(text: "Mumbai, India");
  final _summaryCtrl = TextEditingController(text: "React developer looking for opportunities in Mumbai area.");

  // Education
  final _degreeCtrl = TextEditingController(text: "B.Tech in Computer Science");
  final _schoolCtrl = TextEditingController(text: "Mumbai University");
  final _eduYearCtrl = TextEditingController(text: "2020 - 2024");

  // Experience
  final _expTitleCtrl = TextEditingController(text: "Software Engineering Intern");
  final _expCompanyCtrl = TextEditingController(text: "TCS Pvt. Ltd.");
  final _expDurationCtrl = TextEditingController(text: "6 Months");
  final _expDescCtrl = TextEditingController(text: "Worked on UI components and API integration using JavaScript.");

  // Projects
  final _projTitleCtrl = TextEditingController(text: "E-Commerce App Dashboard");
  final _projTechCtrl = TextEditingController(text: "React, Firebase, Tailwind CSS");
  final _projDescCtrl = TextEditingController(text: "Designed dashboard interface for tracking sales data.");

  // Certifications
  final _certNameCtrl = TextEditingController(text: "AWS Certified Developer Associate");
  final _certOrgCtrl = TextEditingController(text: "Amazon Web Services");
  final _certDateCtrl = TextEditingController(text: "June 2025");

  // Skills & Languages (Lists)
  final List<String> _skillsList = ["React.js", "JavaScript", "HTML5", "CSS3"];
  final List<String> _languagesList = ["English", "Hindi", "Marathi"];

  // ── STATE VARIABLES ──
  int _resumeScore = 65;
  String _selectedTemplate = "Modern Teal"; // "Modern Teal", "Classic Navy", "Minimalist Charcoal"
  bool _isGeneratingPdf = false;
  final List<String> _missingFields = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateResumeScore();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _designationCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _locationCtrl.dispose();
    _summaryCtrl.dispose();
    _degreeCtrl.dispose();
    _schoolCtrl.dispose();
    _eduYearCtrl.dispose();
    _expTitleCtrl.dispose();
    _expCompanyCtrl.dispose();
    _expDurationCtrl.dispose();
    _expDescCtrl.dispose();
    _projTitleCtrl.dispose();
    _projTechCtrl.dispose();
    _projDescCtrl.dispose();
    _certNameCtrl.dispose();
    _certOrgCtrl.dispose();
    _certDateCtrl.dispose();
    super.dispose();
  }

  // ── AI ASSISTANCE ACTIONS ──
  void _calculateResumeScore() {
    int score = 40;
    _missingFields.clear();

    if (_nameCtrl.text.isNotEmpty) score += 5;
    if (_designationCtrl.text.isNotEmpty) score += 5;
    if (_phoneCtrl.text.isNotEmpty) score += 5;
    if (_emailCtrl.text.isNotEmpty) score += 5;

    // Check missing contacts
    if (_locationCtrl.text.isEmpty) _missingFields.add("City Location details");

    // Summary check
    if (_summaryCtrl.text.length > 30) {
      score += 10;
    } else {
      _missingFields.add("Detailed professional summary");
    }

    // Education check
    if (_degreeCtrl.text.isNotEmpty && _schoolCtrl.text.isNotEmpty) {
      score += 15;
    } else {
      _missingFields.add("Academic qualification details");
    }

    // Experience check
    if (_expTitleCtrl.text.isNotEmpty && _expDescCtrl.text.isNotEmpty) {
      score += 20;
    } else {
      _missingFields.add("Professional work history description");
    }

    // Projects check
    if (_projTitleCtrl.text.isNotEmpty && _projDescCtrl.text.isNotEmpty) {
      score += 15;
    } else {
      _missingFields.add("Personal or professional project listings");
    }

    // Certifications check
    if (_certNameCtrl.text.isNotEmpty) {
      score += 10;
    } else {
      _missingFields.add("Professional certification verification");
    }

    // Lists check
    if (_skillsList.isNotEmpty) score += 5;
    if (_languagesList.isNotEmpty) score += 5;

    setState(() {
      _resumeScore = score > 100 ? 100 : score;
    });
  }

  // AI Summary Improver (Editable modal popup requirement)
  void _aiImproveSummary() {
    final String originalSummary = _summaryCtrl.text;
    final String suggestedSummary = "Result-oriented React Developer with hands-on experience in building scalable web dashboards, integrating APIs, and crafting responsive user interfaces with optimal performance.";

    _showAIEditableSuggestionDialog(
      title: "AI Improved Summary",
      originalText: originalSummary,
      suggestedText: suggestedSummary,
      onSave: (editedText) {
        setState(() {
          _summaryCtrl.text = editedText;
          _calculateResumeScore();
        });
      },
    );
  }

  // AI Rewrite Experience (Editable modal popup requirement)
  void _aiRewriteExperience() {
    final String originalDesc = _expDescCtrl.text;
    final String suggestedDesc = "• Orchestrated front-end dashboard development using React.js, improving load latency by 20%.\n• Designed modular components and integrated asynchronous RESTful APIs.\n• Collaborated closely with QA desks to identify layout bottlenecks.";

    _showAIEditableSuggestionDialog(
      title: "AI Professional Experience Rewrite",
      originalText: originalDesc,
      suggestedText: suggestedDesc,
      onSave: (editedText) {
        setState(() {
          _expDescCtrl.text = editedText;
          _calculateResumeScore();
        });
      },
    );
  }

  // AI Suggest Skills based on job title
  void _aiSuggestSkills() {
    List<String> suggestedSkills = [];
    if (_designationCtrl.text.toLowerCase().contains("react") || _designationCtrl.text.toLowerCase().contains("developer")) {
      suggestedSkills = ["Redux toolkit", "TypeScript", "RESTful API Integration", "Jest Testing Framework", "Next.js"];
    } else {
      suggestedSkills = ["Manual Testing", "Automation Desk", "Selenium Grid", "Agile JIRA", "API Postman"];
    }

    showDialog(
      context: context,
      builder: (context) {
        final List<String> selectedSuggestions = List.from(suggestedSkills);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("AI Suggested Skills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("AI analyzed your job title and suggests adding the following skills. Tweak selection before adding:", style: TextStyle(fontSize: 12.5)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: suggestedSkills.map((sk) {
                      final isSelected = selectedSuggestions.contains(sk);
                      return ChoiceChip(
                        label: Text(sk, style: TextStyle(fontSize: 11.5, color: isSelected ? Colors.white : Colors.black87)),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              selectedSuggestions.add(sk);
                            } else {
                              selectedSuggestions.remove(sk);
                            }
                          });
                        },
                      );
                    }).toList(),
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    setState(() {
                      for (var sk in selectedSuggestions) {
                        if (!_skillsList.contains(sk)) _skillsList.add(sk);
                      }
                      _calculateResumeScore();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Add to Resume"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // AI Project Description Generator (Editable modal popup requirement)
  void _aiGenerateProjectDescription() {
    final String projTitle = _projTitleCtrl.text;
    if (projTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please type a project title first.")));
      return;
    }
    final String suggestedProjDesc = "Developed a real-time, responsive $projTitle utilizing robust React architecture. Implemented Firebase auth credentials, state hydration, and premium charts analytics for tracking metrics.";

    _showAIEditableSuggestionDialog(
      title: "AI Project Description",
      originalText: _projDescCtrl.text,
      suggestedText: suggestedProjDesc,
      onSave: (editedText) {
        setState(() {
          _projDescCtrl.text = editedText;
          _calculateResumeScore();
        });
      },
    );
  }

  // Shared Helper for AI Editable Suggestion dialog
  void _showAIEditableSuggestionDialog({
    required String title,
    required String originalText,
    required String suggestedText,
    required ValueChanged<String> onSave,
  }) {
    final TextEditingController textEditingController = TextEditingController(text: suggestedText);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("AI Suggested Version (You can edit this content below before saving):", style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: textEditingController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    fillColor: AppColors.scaffoldBackground,
                    filled: true,
                  ),
                  style: const TextStyle(fontSize: 12.5, height: 1.45),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Discard"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                onSave(textEditingController.text);
                Navigator.pop(context);
              },
              child: const Text("Save & Apply"),
            ),
          ],
        );
      },
    );
  }

  // Simulated PDF Export
  void _exportPdfAction() {
    setState(() {
      _isGeneratingPdf = true;
    });
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isGeneratingPdf = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text("PDF Generated"),
            ],
          ),
          content: Text("Your resume has been successfully compiled into PDF using the $_selectedTemplate template."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Downloading PDF file to device downloads...")));
              },
              child: const Text("Download PDF"),
            ),
          ],
        ),
      );
    });
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.buttonText, size: 20),
        ),
        title: const Text(
          "AI Resume Builder Desk",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Edit Data"),
            Tab(text: "AI Enhancer"),
            Tab(text: "Preview & PDF"),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── QUICK SCORE SUB-BAR ──
          Container(
            color: AppColors.primary.withOpacity(0.04),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("AI Resume Completeness Score", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      _resumeScore >= 80 ? "Excellent Profile Ready" : "Improve profile checklist details",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _resumeScore >= 80 ? Colors.green : Colors.orange),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _resumeScore >= 80 ? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Score: $_resumeScore%",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _resumeScore >= 80 ? Colors.green : Colors.orange),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── TAB 1: FORM INPUTS ──
                _buildFormTab(),

                // ── TAB 2: AI ASSIST / ENHANCER ──
                _buildAiTab(),

                // ── TAB 3: PREVIEW & EXPORT ──
                _buildPreviewTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB 1: DATA FORMS BUILDER ──
  Widget _buildFormTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _formHeader("1. Personal Information"),
        _inputField("Full Name", _nameCtrl),
        _inputField("Job Title Target", _designationCtrl),
        _inputField("Phone Number", _phoneCtrl),
        _inputField("Email Address", _emailCtrl),
        _inputField("City, Country", _locationCtrl),
        _inputField("Professional Summary", _summaryCtrl, maxLines: 3),
        const SizedBox(height: 16),

        _formHeader("2. Education (Academic)"),
        _inputField("Degree / Certificate", _degreeCtrl),
        _inputField("School / Institution", _schoolCtrl),
        _inputField("Year / Duration", _eduYearCtrl),
        const SizedBox(height: 16),

        _formHeader("3. Professional Experience"),
        _inputField("Designation / Role", _expTitleCtrl),
        _inputField("Employer Company", _expCompanyCtrl),
        _inputField("Duration worked", _expDurationCtrl),
        _inputField("Role Description", _expDescCtrl, maxLines: 3),
        const SizedBox(height: 16),

        _formHeader("4. Project Showcases"),
        _inputField("Project Name", _projTitleCtrl),
        _inputField("Tech Stack used", _projTechCtrl),
        _inputField("Project Description Summary", _projDescCtrl, maxLines: 2),
        const SizedBox(height: 16),

        _formHeader("5. Certifications & Achievements"),
        _inputField("Certification Name", _certNameCtrl),
        _inputField("Issuing Organization", _certOrgCtrl),
        _inputField("Date Issued", _certDateCtrl),
        const SizedBox(height: 16),

        _formHeader("6. Technical Skills & Languages"),
        const SizedBox(height: 8),
        const Text("Skills:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ..._skillsList.map((sk) => Chip(
                  label: Text(sk, style: const TextStyle(fontSize: 11)),
                  onDeleted: () {
                    setState(() {
                      _skillsList.remove(sk);
                      _calculateResumeScore();
                    });
                  },
                )),
            ActionChip(
              backgroundColor: AppColors.primary.withOpacity(0.08),
              avatar: const Icon(Icons.add, size: 14, color: AppColors.primary),
              label: const Text("Add Skill", style: TextStyle(fontSize: 11, color: AppColors.primary)),
              onPressed: () {
                String val = "";
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Add Custom Skill"),
                    content: TextFormField(
                      onChanged: (v) => val = v,
                      decoration: const InputDecoration(hintText: "Enter skill name"),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                        onPressed: () {
                          if (val.isNotEmpty) {
                            setState(() {
                              _skillsList.add(val);
                              _calculateResumeScore();
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: const Text("Add"),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text("Languages:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ..._languagesList.map((lang) => Chip(
                  label: Text(lang, style: const TextStyle(fontSize: 11)),
                  onDeleted: () {
                    setState(() {
                      _languagesList.remove(lang);
                      _calculateResumeScore();
                    });
                  },
                )),
            ActionChip(
              backgroundColor: AppColors.primary.withOpacity(0.08),
              avatar: const Icon(Icons.add, size: 14, color: AppColors.primary),
              label: const Text("Add Language", style: TextStyle(fontSize: 11, color: AppColors.primary)),
              onPressed: () {
                String val = "";
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Add Language"),
                    content: TextFormField(
                      onChanged: (v) => val = v,
                      decoration: const InputDecoration(hintText: "Enter language name"),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                        onPressed: () {
                          if (val.isNotEmpty) {
                            setState(() {
                              _languagesList.add(val);
                              _calculateResumeScore();
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: const Text("Add"),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ── TAB 2: AI ENHANCEMENT PANEL ──
  Widget _buildAiTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // AI score recommendation check
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text("AI Completeness Review Report", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 24),
              if (_missingFields.isEmpty)
                const Text("✓ Perfect Profile! Your resume covers all required data checklist items.", style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold))
              else ...[
                const Text("Identify Missing Information & Gaps:", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 8),
                ..._missingFields.map((field) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange, size: 14),
                          const SizedBox(width: 8),
                          Expanded(child: Text("Missing: $field", style: const TextStyle(fontSize: 12, color: Colors.black87))),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text("Interactive AI Assistance Desk", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        _aiToolCard(
          icon: Icons.auto_awesome_rounded,
          title: "Improve Resume Summary",
          desc: "Transforms simple goals into high-impact summary statements suitable for target IT jobs.",
          actionLabel: "Enhance Summary",
          onTap: _aiImproveSummary,
        ),
        _aiToolCard(
          icon: Icons.edit_note_rounded,
          title: "Rewrite Work Experience",
          desc: "Rewrites simple internship/work descriptions using strong action verbs.",
          actionLabel: "Format Experience",
          onTap: _aiRewriteExperience,
        ),
        _aiToolCard(
          icon: Icons.lightbulb_rounded,
          title: "Suggest Relevant Tech Skills",
          desc: "Analyzes designation profile to suggest matching IT framework skills.",
          actionLabel: "Suggest Skills",
          onTap: _aiSuggestSkills,
        ),
        _aiToolCard(
          icon: Icons.code_rounded,
          title: "Generate Project Description",
          desc: "Autocreates a professional technical description based on project title.",
          actionLabel: "Generate Description",
          onTap: _aiGenerateProjectDescription,
        ),
      ],
    );
  }

  // ── TAB 3: RESUME PREVIEW & PDF DOWNLOADS ──
  Widget _buildPreviewTab() {
    return Column(
      children: [
        // Template Choice bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.background,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Select Template:", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedTemplate,
                items: ["Modern Teal", "Classic Navy", "Minimalist Charcoal"].map((t) {
                  return DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12.5)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedTemplate = val;
                    });
                  }
                },
              ),
            ],
          ),
        ),

        // Live Document Preview Pane
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Accent Header based on Template
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: _getTemplateColor().withOpacity(0.12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_nameCtrl.text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getTemplateColor())),
                        Text(_designationCtrl.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                        const SizedBox(height: 6),
                        Text("${_phoneCtrl.text}  |  ${_emailCtrl.text}  |  ${_locationCtrl.text}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Summary
                  _docHeader("PROFESSIONAL SUMMARY"),
                  Text(_summaryCtrl.text, style: const TextStyle(fontSize: 11.5, color: Colors.black87, height: 1.35)),
                  const SizedBox(height: 12),

                  // Education
                  _docHeader("EDUCATION HISTORY"),
                  Text(_degreeCtrl.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text("${_schoolCtrl.text} (${_eduYearCtrl.text})", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 12),

                  // Experience
                  _docHeader("WORK EXPERIENCE"),
                  Text(_expTitleCtrl.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text("${_expCompanyCtrl.text} (${_expDurationCtrl.text})", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(_expDescCtrl.text, style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.35)),
                  const SizedBox(height: 12),

                  // Projects
                  _docHeader("PROJECT SHOWCASES"),
                  Text(_projTitleCtrl.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text("Technologies: ${_projTechCtrl.text}", style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(_projDescCtrl.text, style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.35)),
                  const SizedBox(height: 12),

                  // Certifications
                  _docHeader("CERTIFICATIONS"),
                  Text(_certNameCtrl.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text("${_certOrgCtrl.text} - ${_certDateCtrl.text}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 12),

                  // Skills & Languages
                  _docHeader("TECHNICAL SKILLS"),
                  Text(_skillsList.join(", "), style: const TextStyle(fontSize: 11.5, color: Colors.black87)),
                  const SizedBox(height: 12),
                  _docHeader("LANGUAGES"),
                  Text(_languagesList.join(", "), style: const TextStyle(fontSize: 11.5, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ),

        // Action panel for export
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.background,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isGeneratingPdf ? null : _exportPdfAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isGeneratingPdf
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf_rounded),
              label: Text(_isGeneratingPdf ? "Compiling PDF Template..." : "Export Resume to PDF File", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        )
      ],
    );
  }

  // Helper template styles
  Color _getTemplateColor() {
    if (_selectedTemplate == "Classic Navy") return const Color(0xFF0D47A1);
    if (_selectedTemplate == "Minimalist Charcoal") return Colors.blueGrey[800]!;
    return Colors.teal[700]!;
  }

  Widget _docHeader(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6, top: 4),
      padding: const EdgeInsets.only(bottom: 2),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _getTemplateColor(), width: 1.2)),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getTemplateColor(), letterSpacing: 0.5)),
    );
  }

  // ── CORE SUB-WIDGET COMPONENTS ──
  Widget _formHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12.5),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          fillColor: AppColors.background,
          filled: true,
        ),
        onChanged: (_) => _calculateResumeScore(),
      ),
    );
  }

  Widget _aiToolCard({
    required IconData icon,
    required String title,
    required String desc,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(desc, style: const TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.3)),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: AppColors.primary.withOpacity(0.06),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: onTap,
                    icon: const Icon(Icons.auto_awesome, size: 13, color: AppColors.primary),
                    label: Text(actionLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
