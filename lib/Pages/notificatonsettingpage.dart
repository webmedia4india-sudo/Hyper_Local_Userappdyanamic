import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class NotificatonSettingPage extends StatefulWidget {
  const NotificatonSettingPage({super.key});

  @override
  State<NotificatonSettingPage> createState() => _NotificatonSettingPageState();
}

class _NotificatonSettingPageState extends State<NotificatonSettingPage> {
  bool _pushNotifications = true;

  final Map<String, bool> _notificationTypes = {
    "Job Alerts": true,
    "Application Updates": true,
    "Interview Reminders": true,
    "Messages": true,
    "Promotionals": false,
    "News & Updates": true,
  };

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
          "Notifications Settings",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── MASTER TOGGLE ────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                "Push Notifications",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              value: _pushNotifications,
              activeThumbColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                  // Master toggle off = disable all individual toggles
                  if (!value) {
                    _notificationTypes.updateAll((key, val) => false);
                  }
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // ── INDIVIDUAL NOTIFICATION TYPES ────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: List.generate(_notificationTypes.length, (index) {
                final key = _notificationTypes.keys.elementAt(index);
                final isLast = index == _notificationTypes.length - 1;

                return Column(
                  children: [
                    SwitchListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        key,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      value: _notificationTypes[key]!,
                      activeThumbColor: AppColors.primary,
                      onChanged: _pushNotifications
                          ? (value) {
                              setState(() {
                                _notificationTypes[key] = value;
                              });
                            }
                          : null, // disabled when master toggle is off
                    ),
                    if (!isLast)
                      const Divider(height: 1, indent: 16, color: AppColors.divider),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}