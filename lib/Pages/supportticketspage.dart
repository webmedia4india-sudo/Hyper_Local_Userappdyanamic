import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  int _selectedTab = 0; // 0: Open, 1: Resolved

  final List<Map<String, dynamic>> _tickets = [
    {
      "title": "Payment Issue",
      "ticketId": "Ticket ID: #12345",
      "date": "12 May 2024",
      "status": "Open",
    },
    {
      "title": "App Not Working",
      "ticketId": "Ticket ID: #12344",
      "date": "10 May 2024",
      "status": "In Progress",
    },
    {
      "title": "Profile Update",
      "ticketId": "Ticket ID: #12343",
      "date": "8 May 2024",
      "status": "Resolved",
    },
  ];

  List<Map<String, dynamic>> get _filteredTickets {
    if (_selectedTab == 0) {
      return _tickets.where((t) => t["status"] != "Resolved").toList();
    }
    return _tickets.where((t) => t["status"] == "Resolved").toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Open":
        return AppColors.primary;
      case "In Progress":
        return AppColors.warning;
      case "Resolved":
        return AppColors.success;
      default:
        return AppColors.textSecondary;
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
          "Support Ticket",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "My Tickets",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // ── TABS ────────────────────
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.otpBoxBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _tabItem("Open", 0)),
                      Expanded(child: _tabItem("Resolved", 1)),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── TICKET LIST ────────────────────
                ..._filteredTickets.map((ticket) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ticketCard(ticket),
                    )),
              ],
            ),
          ),

          // ── RAISE NEW TICKET BUTTON ────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Raise New Ticket",
                  style: TextStyle(
                    color: AppColors.buttonText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TOGGLE TAB ITEM ────────────────────
  Widget _tabItem(String label, int index) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.background : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── SINGLE TICKET CARD ────────────────────
  Widget _ticketCard(Map<String, dynamic> ticket) {
    final String status = ticket["status"] as String;
    final Color statusColor = _statusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket["title"] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket["ticketId"] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket["date"] as String,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}