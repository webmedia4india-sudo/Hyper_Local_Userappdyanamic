import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with TickerProviderStateMixin {
  int _selectedTab = 0; // 0: All, 1: Applications, 2: Messages

  late AnimationController _listController;

  final List<Map<String, dynamic>> _notifications = [
    {
      "icon": Icons.send_rounded,
      "iconBg": AppColors.primary,
      "title": "Your application was submitted to Zomato",
      "time": "2h ago",
      "isUnread": true,
      "type": 1,
    },
    {
      "icon": Icons.event_available_rounded,
      "iconBg": AppColors.mint,
      "title": "Interview scheduled at Uber",
      "time": "6h ago",
      "isUnread": true,
      "type": 1,
    },
    {
      "icon": Icons.work_outline_rounded,
      "iconBg": AppColors.lime,
      "title": "New job shortlisted for you",
      "time": "1d ago",
      "isUnread": false,
      "type": 1,
    },
    {
      "icon": Icons.check_circle_outline_rounded,
      "iconBg": AppColors.coral,
      "title": "You have been shortlisted for the role",
      "time": "1d ago",
      "isUnread": false,
      "type": 1,
    },
    {
      "icon": Icons.notifications_active_outlined,
      "iconBg": AppColors.pink,
      "title": "Reminder: Update your profile",
      "time": "2d ago",
      "isUnread": false,
      "type": 2,
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedTab == 0) return _notifications;
    return _notifications.where((n) => n["type"] == _selectedTab).toList();
  }

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
    _listController
      ..reset()
      ..forward();
  }

  void _dismissNotification(Map<String, dynamic> item) {
    setState(() => _notifications.remove(item));
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
          "Notifications",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── TABS ────────────────────
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _tabItem("All", 0),
                const SizedBox(width: 10),
                _tabItem("Applications", 1),
                const SizedBox(width: 10),
                _tabItem("Messages", 2),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // ── NOTIFICATION LIST ────────────────────
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: _filteredNotifications.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final item = _filteredNotifications[index];
                      return _AnimatedTile(
                        key: ValueKey(item["title"]),
                        index: index,
                        controller: _listController,
                        item: item,
                        onDismiss: () => _dismissNotification(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── EMPTY STATE ────────────────────
  Widget _emptyState() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.scale(scale: 0.9 + (0.1 * value), child: child),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                size: 40,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "You're all caught up ✨",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB CHIP (animated pill) ────────────────────
  Widget _tabItem(String label, int index) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.otpBoxBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 280),
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.buttonText : AppColors.textSecondary,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

// ── SWIPEABLE + STAGGER-ANIMATED TILE ────────────────────
class _AnimatedTile extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Map<String, dynamic> item;
  final VoidCallback onDismiss;

  const _AnimatedTile({
    super.key,
    required this.index,
    required this.controller,
    required this.item,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.12).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: ValueKey(item["title"]),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismiss(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
        ),
        child: _NotificationCard(item: item),
      ),
    );
  }
}

// ── NOTIFICATION CARD (tap bounce + solid theme badge) ────────────────────
class _NotificationCard extends StatefulWidget {
  final Map<String, dynamic> item;
  const _NotificationCard({required this.item});

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final Color badgeColor = item["iconBg"] as Color;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: item["isUnread"] == true
                ? AppColors.primary.withOpacity(0.05)
                : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item["isUnread"] == true
                  ? AppColors.primary.withOpacity(0.15)
                  : AppColors.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Solid theme-colored icon badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  item["icon"] as IconData,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),

              // Title + time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["title"] as String,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: item["isUnread"] == true
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item["time"] as String,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),

              // Unread pulse dot
              if (item["isUnread"] == true) const _PulsingDot(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PULSING UNREAD DOT ────────────────────
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.9 + (_controller.value * 0.3);
        return Container(
          margin: const EdgeInsets.only(left: 8, top: 5),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}