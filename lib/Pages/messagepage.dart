import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/applicationtrackerpage.dart';
import 'package:hyper_local/Pages/dashboard.page.dart';
import 'package:hyper_local/Pages/profilepage.dart';
import 'package:hyper_local/Pages/recommendedjpbpage.dart';
import '../utils/app_colors.dart';

enum MessageType { text, image, document, resume, location, voice }

class ChatMessage {
  final MessageType type;
  final bool isMe;
  final String time;
  final String? text;
  final String? fileName;
  final String? fileSize;
  final String? duration;
  final String? locationLabel;

  const ChatMessage({
    required this.type,
    required this.isMe,
    required this.time,
    this.text,
    this.fileName,
    this.fileSize,
    this.duration,
    this.locationLabel,
  });
}

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Entrance staggered transition controller
  late AnimationController _entranceController;

  // Voice message waveform animation controller
  late AnimationController _waveformController;

  // Bottom nav: "Message" tab active since we're on this page
  int _selectedIndex = 3;

  // ── STATIC CHAT DATA (covers all message types) ─────────
  final List<ChatMessage> _messages = const [
    ChatMessage(
      type: MessageType.text,
      isMe: false,
      time: "9:02 AM",
      text: "Hi Gauri! Thanks for applying to the Flutter Developer role.",
    ),
    ChatMessage(
      type: MessageType.text,
      isMe: true,
      time: "9:05 AM",
      text: "Hi! Thank you, I'm really excited about this opportunity.",
    ),
    ChatMessage(
      type: MessageType.resume,
      isMe: true,
      time: "9:06 AM",
      fileName: "Gauri_Salunkhe_Resume.pdf",
      fileSize: "482 KB",
    ),
    ChatMessage(
      type: MessageType.text,
      isMe: false,
      time: "9:10 AM",
      text: "Great, got your resume. Can you share a sample of your work?",
    ),
    ChatMessage(
      type: MessageType.document,
      isMe: true,
      time: "9:12 AM",
      fileName: "Project_Portfolio.pdf",
      fileSize: "1.2 MB",
    ),
    ChatMessage(
      type: MessageType.image,
      isMe: true,
      time: "9:13 AM",
    ),
    ChatMessage(
      type: MessageType.text,
      isMe: false,
      time: "9:20 AM",
      text: "Looks good! Can we do a quick voice intro before the interview?",
    ),
    ChatMessage(
      type: MessageType.voice,
      isMe: true,
      time: "9:24 AM",
      duration: "0:38",
    ),
    ChatMessage(
      type: MessageType.text,
      isMe: false,
      time: "9:30 AM",
      text: "Perfect. Here's our office location for the in-person round.",
    ),
    ChatMessage(
      type: MessageType.location,
      isMe: false,
      time: "9:31 AM",
      locationLabel: "TechNova Solutions, Nagpur",
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Staggered list items entrance
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _entranceController.forward();

    // Pulse wave loop for voice waveform
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _entranceController.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  void _sendTextMessage() {
    if (_messageController.text.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sent: ${_messageController.text.trim()}")),
    );
    _messageController.clear();
  }

  // ── ATTACHMENT PICKER BOTTOM SHEET ──────────────────────
  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Share",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 10,
                children: [
                  _attachmentOption(Icons.image_rounded, "Image", AppColors.mint, AppColors.mintSoft),
                  _attachmentOption(Icons.insert_drive_file_rounded, "Document", AppColors.primary, AppColors.accentsSoft[0]),
                  _attachmentOption(Icons.badge_rounded, "Resume", AppColors.pink, AppColors.pinkSoft),
                  _attachmentOption(Icons.location_on_rounded, "Location", AppColors.coral, AppColors.coralSoft),
                  _attachmentOption(Icons.mic_rounded, "Voice Note", AppColors.primaryDeep, AppColors.accentsSoft[0]),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _attachmentOption(IconData icon, String label, Color iconColor, Color bgColor) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$label picker opening...")),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
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
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "TechNova Solutions",
              style: TextStyle(
                color: AppColors.buttonText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "HR Recruiter • Online",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined, color: AppColors.buttonText),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background decorative blobs (similar visual coherence)
          Positioned(
            top: 60,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            right: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withOpacity(0.03),
              ),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final double start = (index * 0.05).clamp(0.0, 0.6);
                    final double end = (start + 0.35).clamp(0.0, 1.0);

                    // Staggered list items entrance
                    return AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, childWidget) {
                        final double opacity = CurvedAnimation(
                          parent: _entranceController,
                          curve: Interval(start, end, curve: Curves.easeOut),
                        ).value;

                        final double slide = Tween<double>(begin: 24, end: 0).animate(CurvedAnimation(
                          parent: _entranceController,
                          curve: Interval(start, end, curve: Curves.easeOutCubic),
                        )).value;

                        return Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset(0, slide),
                            child: childWidget,
                          ),
                        );
                      },
                      child: _messageBubble(_messages[index]),
                    );
                  },
                ),
              ),
              _messageInputBar(),
            ],
          ),
        ],
      ),

      // ── FLOATING BOTTOM NAVIGATION BAR ─────────────────────────────
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomNavItem(
                  Icons.home_rounded,
                  "Home",
                  0,
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardPage(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                _bottomNavItem(
                  Icons.work_outline_rounded,
                  "Jobs",
                  1,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecommendedJobPage(),
                      ),
                    );
                  },
                ),
                _bottomNavItem(
                  Icons.description_outlined,
                  "History",
                  2,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ApplicationTrackerPage(),
                      ),
                    );
                  },
                ),
                _bottomNavItem(
                  Icons.chat_bubble_outline_rounded,
                  "Message",
                  3,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MessagePage(),
                      ),
                    );
                  },
                ),
                _bottomNavItem(
                  Icons.person_outline_rounded,
                  "Profile",
                  4,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── BOTTOM NAV ITEM HELPER (FULLY ANIMATED) ─────────────
  Widget _bottomNavItem(
    IconData icon,
    String label,
    int index, {
    VoidCallback? onTap,
  }) {
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected ? AppColors.selected : AppColors.unselected;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _selectedIndex = index);
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 1 + (value * 0.15),
                  child: child,
                );
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  icon,
                  key: ValueKey(isSelected),
                  color: color,
                  size: 23,
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 220),
                        opacity: isSelected ? 1 : 0,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ── MESSAGE BUBBLE ROUTER ───────────────────────────────
  Widget _messageBubble(ChatMessage msg) {
    Widget content;
    switch (msg.type) {
      case MessageType.text:
        content = _textBubble(msg);
        break;
      case MessageType.image:
        content = _imageBubble(msg);
        break;
      case MessageType.document:
        content = _documentBubble(msg);
        break;
      case MessageType.resume:
        content = _resumeBubble(msg);
        break;
      case MessageType.location:
        content = _locationBubble(msg);
        break;
      case MessageType.voice:
        content = _voiceBubble(msg);
        break;
    }

    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: content,
      ),
    );
  }

  // ── TEXT MESSAGE BUBBLE ─────────────────────────────────
  Widget _textBubble(ChatMessage msg) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: msg.isMe ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
          bottomRight: Radius.circular(msg.isMe ? 4 : 16),
        ),
        border: msg.isMe ? null : Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            msg.text ?? "",
            style: TextStyle(
              fontSize: 13.5,
              color: msg.isMe ? AppColors.buttonText : AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            msg.time,
            style: TextStyle(
              fontSize: 10,
              color: msg.isMe ? Colors.white70 : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  // ── IMAGE MESSAGE BUBBLE ─────────────────────────────────
  Widget _imageBubble(ChatMessage msg) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 150,
            color: AppColors.accentsSoft[0],
            child: const Icon(Icons.image_rounded, color: AppColors.primaryDeep, size: 44),
          ),
          Container(
            color: msg.isMe ? AppColors.primary : AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            alignment: Alignment.centerRight,
            child: Text(
              msg.time,
              style: TextStyle(
                fontSize: 10,
                color: msg.isMe ? Colors.white70 : AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── DOCUMENT MESSAGE BUBBLE ──────────────────────────────
  Widget _documentBubble(ChatMessage msg) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: msg.isMe ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
          bottomRight: Radius.circular(msg.isMe ? 4 : 16),
        ),
        border: msg.isMe ? null : Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: msg.isMe ? Colors.white.withOpacity(0.18) : AppColors.accentsSoft[0],
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.insert_drive_file_rounded,
                  color: msg.isMe ? Colors.white : AppColors.primaryDeep,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.fileName ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: msg.isMe ? AppColors.buttonText : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      msg.fileSize ?? "",
                      style: TextStyle(
                        fontSize: 10.5,
                        color: msg.isMe ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.download_rounded,
                size: 18,
                color: msg.isMe ? Colors.white : AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            msg.time,
            style: TextStyle(
              fontSize: 10,
              color: msg.isMe ? Colors.white70 : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  // ── RESUME SHARE BUBBLE ──────────────────────────────────
  Widget _resumeBubble(ChatMessage msg) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: msg.isMe ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
          bottomRight: Radius.circular(msg.isMe ? 4 : 16),
        ),
        border: msg.isMe ? null : Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: msg.isMe ? Colors.white.withOpacity(0.18) : AppColors.pinkSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.badge_rounded,
                  color: msg.isMe ? Colors.white : AppColors.pink,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Resume",
                      style: TextStyle(
                        fontSize: 11,
                        color: msg.isMe ? Colors.white70 : AppColors.textHint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      msg.fileName ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: msg.isMe ? AppColors.buttonText : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Opening ${msg.fileName}")),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: msg.isMe ? Colors.white.withOpacity(0.15) : AppColors.scaffoldBackground,
                side: BorderSide(color: msg.isMe ? Colors.white54 : AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                "View Resume",
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: msg.isMe ? AppColors.buttonText : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              msg.time,
              style: TextStyle(
                fontSize: 10,
                color: msg.isMe ? Colors.white70 : AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── LOCATION SHARE BUBBLE ────────────────────────────────
  Widget _locationBubble(ChatMessage msg) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      decoration: BoxDecoration(
        color: msg.isMe ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
          bottomRight: Radius.circular(msg.isMe ? 4 : 16),
        ),
        border: msg.isMe ? null : Border.all(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            color: AppColors.coralSoft,
            child: const Icon(Icons.map_rounded, color: AppColors.coral, size: 42),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: msg.isMe ? Colors.white : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        msg.locationLabel ?? "",
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: msg.isMe ? AppColors.buttonText : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    msg.time,
                    style: TextStyle(
                      fontSize: 10,
                      color: msg.isMe ? Colors.white70 : AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── VOICE MESSAGE BUBBLE ─────────────────────────────────
  Widget _voiceBubble(ChatMessage msg) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: msg.isMe ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
          bottomRight: Radius.circular(msg.isMe ? 4 : 16),
        ),
        border: msg.isMe ? null : Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: msg.isMe ? Colors.white : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: msg.isMe ? AppColors.primary : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              // Animated waveform bars
              AnimatedBuilder(
                animation: _waveformController,
                builder: (context, childWidget) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(14, (i) {
                      final heights = [6.0, 12.0, 8.0, 16.0, 10.0, 14.0, 6.0, 18.0, 9.0, 13.0, 7.0, 15.0, 11.0, 5.0];
                      // Real waveform wave simulation using sin function
                      final animatedHeight = heights[i] * (0.85 + 0.3 * sin((_waveformController.value * 2 * pi) + (i * 0.4)));
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.2),
                        width: 2.5,
                        height: animatedHeight,
                        decoration: BoxDecoration(
                          color: msg.isMe ? Colors.white70 : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(width: 10),
              Text(
                msg.duration ?? "",
                style: TextStyle(
                  fontSize: 11,
                  color: msg.isMe ? Colors.white70 : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            msg.time,
            style: TextStyle(
              fontSize: 10,
              color: msg.isMe ? Colors.white70 : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  // ── FLOATING MESSAGE INPUT BAR ───────────────────────────
  Widget _messageInputBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: _showAttachmentSheet,
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 26),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Recording voice message...")),
                );
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic_rounded, color: AppColors.buttonText, size: 18),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _sendTextMessage,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: AppColors.buttonText, size: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}