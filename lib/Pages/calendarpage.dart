import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF9B6DFF); // Main purple (buttons, active states)
  static const Color primaryDark = Color(0xFF6A3DE8); // Darker purple for pressed/hover
  static const Color primaryLight = Color(0xFFB9A6FF); // Lighter purple/lavender accents

  // Gradient (used on splash/illustration screens)
  static const Color gradientStart = Color(0xFFD8CCFF); // Light lavender
  static const Color gradientEnd = Color(0xFFF3EFFF); // Very light lavender/white
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );

  // Background Colors
  static const Color background = Color(0xFFFFFFFF); // White background
  static const Color scaffoldBackground = Color(0xFFF8F6FF); // Very light lavender-white

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

  static Color? lime;

  static var accents;

  static Color? get primaryDeep => null;
}

class CalendarEvent {
  final String title;
  final String time;
  final Color color;

  const CalendarEvent({
    required this.title,
    required this.time,
    this.color = AppColors.primary,
  });
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime.now();

  // TODO: Backend integration - replace with real events fetched per date
  final Map<String, List<CalendarEvent>> _events = {
    _key(DateTime.now()): const [
      CalendarEvent(title: "Site Inspection", time: "10:00 AM"),
      CalendarEvent(title: "Team Sync Meeting", time: "3:00 PM", color: AppColors.success),
    ],
    _key(DateTime.now().add(const Duration(days: 2))): const [
      CalendarEvent(title: "Client Review", time: "1:30 PM", color: AppColors.warning),
    ],
  };

  static String _key(DateTime date) =>
      "${date.year}-${date.month}-${date.day}";

  static const List<String> _weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  static const List<String> _monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  List<DateTime?> _buildMonthGrid() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    // Monday = 1 ... Sunday = 7
    final leadingEmptyCells = firstDayOfMonth.weekday - 1;

    final List<DateTime?> cells = List<DateTime?>.filled(leadingEmptyCells, null, growable: true);
    for (int day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(_focusedMonth.year, _focusedMonth.month, day));
    }
    return cells;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasEvents(DateTime date) => _events.containsKey(_key(date));

  @override
  Widget build(BuildContext context) {
    final gridCells = _buildMonthGrid();
    final selectedEvents = _events[_key(_selectedDate)] ?? [];

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
          "Calendar",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── MONTH SELECTOR CARD ──────────────────────
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _goToPreviousMonth,
                          icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                        ),
                        Text(
                          "${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: _goToNextMonth,
                          icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ── WEEKDAY LABELS ────────────────────
                    Row(
                      children: _weekDays
                          .map((day) => Expanded(
                                child: Center(
                                  child: Text(
                                    day,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),

                    // ── DATE GRID ─────────────────────────
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: gridCells.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final date = gridCells[index];
                        if (date == null) return const SizedBox.shrink();

                        final isSelected = _isSameDay(date, _selectedDate);
                        final isToday = _isSameDay(date, DateTime.now());
                        final hasEvents = _hasEvents(date);

                        return GestureDetector(
                          onTap: () => setState(() => _selectedDate = date),
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : isToday
                                      ? AppColors.primaryLight.withOpacity(0.15)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  "${date.day}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.buttonText
                                        : isToday
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                  ),
                                ),
                                if (hasEvents && !isSelected)
                                  Positioned(
                                    bottom: 4,
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── EVENTS FOR SELECTED DATE ─────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Events on ${_selectedDate.day} ${_monthNames[_selectedDate.month - 1]}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "${selectedEvents.length} event${selectedEvents.length == 1 ? '' : 's'}",
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (selectedEvents.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.event_busy_outlined, color: AppColors.textHint, size: 40),
                        const SizedBox(height: 8),
                        const Text(
                          "No events for this day",
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: selectedEvents.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final event = selectedEvents[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 36,
                            decoration: BoxDecoration(
                              color: event.color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  event.time,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // TODO: Backend integration - open add-event form
        },
        child: const Icon(Icons.add, color: AppColors.buttonText),
      ),
    );
  }
}