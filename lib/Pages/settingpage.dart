import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // ── ACCOUNT STATE ──
  String _mobileNumber = "+91 98765 43210";
  String _emailAddress = "rahul.sharma@tcs.com";

  // ── NOTIFICATIONS STATE ──
  bool _jobAlerts = true;
  bool _messagesAlerts = true;
  bool _interviewsAlerts = true;
  bool _marketingAlerts = false;

  // ── PRIVACY STATE ──
  bool _profileVisibility = true; // Public/Private
  bool _locationSharing = true;
  bool _resumeVisibility = true;
  bool _videoResumeVisibility = false;

  // ── SECURITY STATE ──
  final List<String> _activeDevices = [
    "Samsung Galaxy S23 (This device - Active)",
    "Windows PC - Chrome Browser (Mumbai)",
    "iPad Pro - Safari Mobile (Pune)"
  ];

  // ── APPLICATION STATE ──
  String _selectedLanguage = "English (US)";
  String _selectedTheme = "System Default";
  bool _lowDataUsage = false;

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
          "Settings Desk",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. ACCOUNT SECTION ──
          _sectionHeader("Account Settings"),
          Container(
            decoration: _containerDecoration(),
            child: Column(
              children: [
                _settingTile(
                  icon: Icons.person_outline_rounded,
                  label: "Edit Profile Details",
                  subtitle: "Change profile avatar & metadata",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Redirecting to profile edit pages...")),
                    );
                  },
                ),
                _divider(),
                _settingTile(
                  icon: Icons.phone_android_rounded,
                  label: "Change Mobile Number",
                  subtitle: _mobileNumber,
                  onTap: _changeMobileDialog,
                ),
                _divider(),
                _settingTile(
                  icon: Icons.alternate_email_rounded,
                  label: "Change Email Address",
                  subtitle: _emailAddress,
                  onTap: _changeEmailDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── 2. NOTIFICATIONS SECTION ──
          _sectionHeader("Notifications Preferences"),
          Container(
            decoration: _containerDecoration(),
            child: Column(
              children: [
                _switchTile(
                  icon: Icons.work_outline_rounded,
                  title: "Job Alerts Alerts",
                  desc: "Instant notifications for matching micro-local roles",
                  val: _jobAlerts,
                  onChanged: (v) => setState(() => _jobAlerts = v),
                ),
                _divider(),
                _switchTile(
                  icon: Icons.forum_outlined,
                  title: "Messages Notifications",
                  desc: "Direct messages from verified IT employers",
                  val: _messagesAlerts,
                  onChanged: (v) => setState(() => _messagesAlerts = v),
                ),
                _divider(),
                _switchTile(
                  icon: Icons.calendar_today_outlined,
                  title: "Interview Updates",
                  desc: "Video call updates and coordinator logs",
                  val: _interviewsAlerts,
                  onChanged: (v) => setState(() => _interviewsAlerts = v),
                ),
                _divider(),
                _switchTile(
                  icon: Icons.campaign_outlined,
                  title: "Marketing Promotions",
                  desc: "Early access discount premium membership emails",
                  val: _marketingAlerts,
                  onChanged: (v) => setState(() => _marketingAlerts = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── 3. PRIVACY SECTION ──
          _sectionHeader("Privacy Configuration"),
          Container(
            decoration: _containerDecoration(),
            child: Column(
              children: [
                _switchTile(
                  icon: Icons.visibility_outlined,
                  title: "Profile Visibility",
                  desc: _profileVisibility ? "Visible to recruiters (Public)" : "Hidden from search pools (Private)",
                  val: _profileVisibility,
                  onChanged: (v) => setState(() => _profileVisibility = v),
                ),
                _divider(),
                _switchTile(
                  icon: Icons.my_location_rounded,
                  title: "Real-time Location Sharing",
                  desc: "Calculate precise distances to employer venues",
                  val: _locationSharing,
                  onChanged: (v) => setState(() => _locationSharing = v),
                ),
                _divider(),
                _switchTile(
                  icon: Icons.file_present_rounded,
                  title: "Resume Visibility",
                  desc: "Allow recruiters to download summary PDFs",
                  val: _resumeVisibility,
                  onChanged: (v) => setState(() => _resumeVisibility = v),
                ),
                _divider(),
                _switchTile(
                  icon: Icons.video_camera_back_rounded,
                  title: "Video Resume Visibility",
                  desc: "Display recorded clips on job dashboard lists",
                  val: _videoResumeVisibility,
                  onChanged: (v) => setState(() => _videoResumeVisibility = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── 4. SECURITY SECTION ──
          _sectionHeader("Security & Sessions"),
          Container(
            decoration: _containerDecoration(),
            child: Column(
              children: [
                _settingTile(
                  icon: Icons.devices_other_rounded,
                  label: "Active Devices Sessions",
                  subtitle: "${_activeDevices.length} platforms logged in",
                  onTap: _viewActiveSessionsDialog,
                ),
                _divider(),
                _settingTile(
                  icon: Icons.lock_reset_rounded,
                  label: "Logout From All Devices",
                  subtitle: "Terminates active session auth logs",
                  isDestructive: true,
                  onTap: _logoutAllDevicesDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── 5. APPLICATION SECTION ──
          _sectionHeader("Application Configuration"),
          Container(
            decoration: _containerDecoration(),
            child: Column(
              children: [
                _settingTile(
                  icon: Icons.language_outlined,
                  label: "App Display Language",
                  subtitle: _selectedLanguage,
                  onTap: _changeLanguageDialog,
                ),
                _divider(),
                _settingTile(
                  icon: Icons.palette_outlined,
                  label: "Theme Selection",
                  subtitle: _selectedTheme,
                  onTap: _changeThemeDialog,
                ),
                _divider(),
                _switchTile(
                  icon: Icons.data_usage_rounded,
                  title: "Low Data Usage Mode",
                  desc: "Compresses mock visuals to save bandwidth",
                  val: _lowDataUsage,
                  onChanged: (v) => setState(() => _lowDataUsage = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── LOGOUT BUTTON ──
          Container(
            decoration: _containerDecoration(),
            child: _settingTile(
              icon: Icons.logout_rounded,
              label: "Logout from Device",
              subtitle: "Clears session logs but retains preferences",
              isDestructive: true,
              isLast: true,
              onTap: _logoutFlowCurrentDevice,
            ),
          ),
          const SizedBox(height: 12),

          // ── DELETE ACCOUNT LINK ──
          Container(
            decoration: _containerDecoration(),
            child: _settingTile(
              icon: Icons.delete_forever_rounded,
              label: "Delete Candidate Account",
              subtitle: "Irreversibly delete profile data, maps, score history",
              isDestructive: true,
              isLast: true,
              onTap: _deleteAccountWorkflow,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── REUSABLE DECORATIONS ──
  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 52, color: AppColors.divider);
  }

  // ── ROW BUILDERS ──
  Widget _settingTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
    bool isDestructive = false,
  }) {
    final Color iconColor = isDestructive ? Colors.red : AppColors.primary;
    final Color textColor = isDestructive ? Colors.red : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(14),
        bottom: isLast ? const Radius.circular(14) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (!isDestructive)
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String desc,
    required bool val,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: val,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ── DIALOG INTERACTION HANDLERS ──

  // Edit Mobile
  void _changeMobileDialog() {
    String tempPhone = _mobileNumber;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Change Mobile Number"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Updating mobile number requires a code validation. Enter new number:", style: TextStyle(fontSize: 12.5)),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: tempPhone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Mobile Number", border: OutlineInputBorder()),
              onChanged: (v) => tempPhone = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              // Trigger Simulated OTP dialog
              _simulateOtpVerificationFlow(
                onSuccess: () {
                  setState(() {
                    _mobileNumber = tempPhone;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mobile number updated successfully.")));
                },
              );
            },
            child: const Text("Send OTP"),
          ),
        ],
      ),
    );
  }

  // Edit Email
  void _changeEmailDialog() {
    String tempEmail = _emailAddress;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Change Email Address"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Provide your new primary email address below:", style: TextStyle(fontSize: 12.5)),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: tempEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email Address", border: OutlineInputBorder()),
              onChanged: (v) => tempEmail = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _emailAddress = tempEmail;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email address updated.")));
            },
            child: const Text("Update Email"),
          ),
        ],
      ),
    );
  }

  // View Devices Sessions
  void _viewActiveSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Active Devices Sessions"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _activeDevices.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, idx) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.important_devices_rounded, color: AppColors.primary),
              title: Text(_activeDevices[idx], style: const TextStyle(fontSize: 12.5)),
              subtitle: const Text("IP: 192.168.1.1 - Active Session token", style: TextStyle(fontSize: 10)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  // Logout All Devices
  void _logoutAllDevicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Logout from All Devices?"),
        content: const Text("This will terminate access tokens on all browsers, tablets, and computers. You will need to log in again on those systems."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _activeDevices.removeRange(1, _activeDevices.length);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Successfully logged out from all other platforms.")));
            },
            child: const Text("Logout All Devices"),
          ),
        ],
      ),
    );
  }

  // Choose App Language
  void _changeLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Select Display Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["English (US)", "मराठी (Marathi)", "हिंदी (Hindi)", "Gujarati"].map((lang) {
            return RadioListTile<String>(
              value: lang,
              groupValue: _selectedLanguage,
              title: Text(lang, style: const TextStyle(fontSize: 13)),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _selectedLanguage = v;
                  });
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // Choose Theme Selector
  void _changeThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Choose App Theme"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["Light Theme Mode", "Dark Theme Mode", "System Default"].map((theme) {
            return RadioListTile<String>(
              value: theme,
              groupValue: _selectedTheme,
              title: Text(theme, style: const TextStyle(fontSize: 13)),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _selectedTheme = v;
                  });
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // Shared OTP verification flow simulator
  void _simulateOtpVerificationFlow({required VoidCallback onSuccess}) {
    String typedOtp = "";
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("OTP Verification Code"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter the 6-digit OTP code sent to verify action (Mock code: 123456):", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            TextFormField(
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(fontSize: 16, letterSpacing: 6, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(border: OutlineInputBorder(), counterText: ""),
              onChanged: (v) => typedOtp = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              if (typedOtp == "123456") {
                Navigator.pop(context);
                onSuccess();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incorrect OTP code. Try again.")));
              }
            },
            child: const Text("Verify OTP"),
          ),
        ],
      ),
    );
  }

  // ── 32. LOGOUT WORKFLOW ──
  void _logoutFlowCurrentDevice() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Logout current device?"),
          content: const Text("Are you sure you want to logout? Preference choices will be retained locally."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel action
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                // Rule: Clear local session data but retain user preferences where appropriate.
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mock session data cleared. Logging out..."), duration: Duration(seconds: 2)),
                );
                Timer(const Duration(seconds: 2), () {
                  Navigator.pop(context); // Go back home
                });
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  // ── 33. DELETE ACCOUNT WORKFLOW ──
  void _deleteAccountWorkflow() {
    bool impactAcknowledged = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Delete Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Warning: This action is permanent and cannot be undone. Read the impact details carefully:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "• All your profile information, skills, resumes will be deleted.\n"
                      "• Active job applications status trackers will be cancelled.\n"
                      "• Subscribed premium perks, cashback balance, rewards will be lost.",
                      style: TextStyle(fontSize: 12, height: 1.35),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: impactAcknowledged,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "I understand that deleting my account is permanent.",
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      dense: true,
                      onChanged: (v) {
                        setDialogState(() {
                          impactAcknowledged = v ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Keep Account"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: impactAcknowledged
                      ? () {
                          Navigator.pop(context); // Close warning dialog
                          // Proceed to verify OTP requirement
                          _simulateOtpVerificationFlow(
                            onSuccess: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: const Text("Deletion Request Submitted"),
                                  content: const Text("Your account deletion request has been registered and is undergoing processing. You will be logged out."),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context); // Exit settings
                                      },
                                      child: const Text("Close App"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      : null,
                  child: const Text("Proceed to Delete"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
