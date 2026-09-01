import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CoverLettersPage extends StatefulWidget {
  final String role;
  final String company;
  final String ctc;
  final String joiningDate;
  final Color logoColor;
  final String logoText;

  const CoverLettersPage({
    super.key,
    this.role = "React Developer",
    this.company = "TCS Pvt. Ltd.",
    this.ctc = "₹6.5 - ₹8.0 LPA",
    this.joiningDate = "August 15, 2026",
    this.logoColor = const Color(0xFF1E3A8A),
    this.logoText = "T",
  });

  @override
  State<CoverLettersPage> createState() => _CoverLettersPageState();
}

class _CoverLettersPageState extends State<CoverLettersPage> with SingleTickerProviderStateMixin {
  // Offer Status: 'Pending', 'Accepted', 'Declined'
  String _offerStatus = 'Pending';
  String _declineReason = '';
  bool _signed = false;

  late AnimationController _badgeAnimController;
  late Animation<double> _scaleAnimation;

  // Confetti Particle System
  final List<_ConfettiParticle> _particles = [];
  Timer? _confettiTimer;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _badgeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _badgeAnimController,
      curve: Curves.elasticOut,
    );
    _badgeAnimController.forward();
  }

  @override
  void dispose() {
    _badgeAnimController.dispose();
    _confettiTimer?.cancel();
    super.dispose();
  }

  void _triggerConfetti() {
    _particles.clear();
    final Size size = MediaQuery.of(context).size;
    
    // Spawn from the center of the screen
    for (int i = 0; i < 150; i++) {
      _particles.add(_ConfettiParticle(
        x: size.width / 2,
        y: size.height * 0.35,
        vx: (_random.nextDouble() - 0.5) * 14,
        vy: -(_random.nextDouble() * 10 + 4),
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
        size: _random.nextDouble() * 8 + 6,
        rotation: _random.nextDouble() * 2 * math.pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.25,
      ));
    }

    _confettiTimer?.cancel();
    _confettiTimer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (!mounted) return;
      setState(() {
        for (var p in _particles) {
          p.x += p.vx;
          p.y += p.vy;
          p.vy += 0.38; // gravity
          p.rotation += p.rotationSpeed;
        }
        // Remove particles that went off the screen
        _particles.removeWhere((p) => p.y > size.height || p.x < -20 || p.x > size.width + 20);
        if (_particles.isEmpty) {
          timer.cancel();
        }
      });
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
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "Offer Letter Desk",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                const SizedBox(height: 10),

                // ── Illustration (Pulsating Scale Transition) ──
                Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SizedBox(
                      width: 170,
                      height: 170,
                      child: CustomPaint(painter: _OfferBadgePainter()),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Congratulations Title ──────────────────
                Center(
                  child: Text(
                    _offerStatus == 'Accepted'
                        ? "Offer Accepted!"
                        : _offerStatus == 'Declined'
                            ? "Offer Declined"
                            : "Congratulations!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _offerStatus == 'Declined' ? Colors.red : AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Subtitle / Selection Text ────────────────
                Center(
                  child: Text(
                    _offerStatus == 'Accepted'
                        ? "You have successfully signed and accepted the offer contract. Welcome to ${widget.company} team!"
                        : _offerStatus == 'Declined'
                            ? "You declined this offer. Reason: $_declineReason"
                            : "You have been selected for the role of ${widget.role} at ${widget.company}.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── MOCK IT JOB OFFER SUMMARY CARD ───────────
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
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: widget.logoColor,
                            child: Text(
                              widget.logoText,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.role, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5)),
                                Text(widget.company, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusBadgeColor().withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _offerStatus,
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: _getStatusBadgeColor()),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _summaryDetailRow(Icons.monetization_on_rounded, "Offered CTC / Salary", widget.ctc),
                      const SizedBox(height: 8),
                      _summaryDetailRow(Icons.calendar_today_rounded, "Tentative Joining Date", widget.joiningDate),
                      const SizedBox(height: 8),
                      _summaryDetailRow(Icons.badge_rounded, "Employment Model", "Full-time (On-site / WFH hybrid)"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── EXPANDABLE CONTRACT DOCUMENT VIEW ──────
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: const Text(
                      "Read Full Offer Agreement",
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    leading: const Icon(Icons.description_rounded, color: AppColors.primary),
                    childrenPadding: const EdgeInsets.all(12),
                    backgroundColor: AppColors.scaffoldBackground,
                    collapsedBackgroundColor: AppColors.scaffoldBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    children: [
                      Text(
                        "Dear Candidate,\n\nWe are pleased to offer you employment at ${widget.company} for the position of ${widget.role}.\n\n"
                        "1. COMPENSATION STRUCTURE\nYour annual CTC is specified as ${widget.ctc}. All tax deductions will comply with standard regulations.\n\n"
                        "2. PROBATION PERIOD\nYou will undergo a probation review process for 3 months from your joining date.\n\n"
                        "3. TERMINATION CLAUSE\nEither party may terminate the contract with a notice period of 30 days or compensation in lieu thereof.\n\n"
                        "Please review and sign to initiate onboarding steps.",
                        style: const TextStyle(fontSize: 12, height: 1.45, color: Colors.black87),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── SIGNATURE SIMULATION BLOCK ──
                if (_offerStatus == 'Pending') ...[
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
                        const Text(
                          "Candidate Signature Verification",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _signed = !_signed;
                            });
                          },
                          child: Container(
                            height: 80,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _signed ? AppColors.primary : Colors.grey[400]!,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Center(
                              child: _signed
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Signed: ${widget.role} Candidate",
                                          style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                                      ],
                                    )
                                  : const Text(
                                      "Tap here to sign contract digitally",
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── ACTION BUTTONS ──
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _onDeclinePressed,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Colors.red, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Decline Offer", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13.5)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _signed ? _onAcceptPressed : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text("Accept Offer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Return button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Return to Applications", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          ),

          // ── CONFETTI PARTICLE OVERLAY ──
          if (_particles.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ConfettiPainter(_particles),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryDetailRow(IconData icon, String title, String val) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Text("$title: ", style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.black54)),
        Expanded(
          child: Text(val, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.black87)),
        )
      ],
    );
  }

  Color _getStatusBadgeColor() {
    if (_offerStatus == 'Accepted') return AppColors.success;
    if (_offerStatus == 'Declined') return Colors.red;
    return Colors.orange;
  }

  void _onAcceptPressed() {
    setState(() {
      _offerStatus = 'Accepted';
    });
    _triggerConfetti();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Offer accepted! Confetti celebratory system activated."),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _onDeclinePressed() {
    String selectedReason = "Salary compensation range is low";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Decline Job Offer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("We are sorry to see you go. Please specify a reason for declining:"),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedReason,
                decoration: const InputDecoration(labelText: "Reason"),
                items: const [
                  DropdownMenuItem(value: "Salary compensation range is low", child: Text("Low Compensation")),
                  DropdownMenuItem(value: "Accepted another company offer", child: Text("Better Offer")),
                  DropdownMenuItem(value: "Hybrid location distance constraints", child: Text("Distance / Location")),
                  DropdownMenuItem(value: "Personal emergencies", child: Text("Other Reason")),
                ],
                onChanged: (val) {
                  if (val != null) selectedReason = val;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Keep Reviewing"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  _offerStatus = 'Declined';
                  _declineReason = selectedReason;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Offer declined.")),
                );
              },
              child: const Text("Confirm Decline"),
            ),
          ],
        );
      },
    );
  }
}

// ── CONFETTI PARTICLE MODEL & PAINTER ──
class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    for (var p in particles) {
      paint.color = p.color;
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── OFFER BADGE PAINTER ───────────────────────────────────
class _OfferBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Soft circular backdrop
    final Paint backdropPaint = Paint()
      ..color = AppColors.primaryLight.withOpacity(0.15);
    canvas.drawCircle(Offset(cx, cy), r, backdropPaint);

    final Paint backdropInnerPaint = Paint()
      ..color = AppColors.primaryLight.withOpacity(0.22);
    canvas.drawCircle(Offset(cx, cy), r * 0.78, backdropInnerPaint);

    // Envelope body
    final double envW = size.width * 0.62;
    final double envH = size.height * 0.42;
    final double envLeft = cx - envW / 2;
    final double envTop = cy - envH * 0.15;

    final Rect envRect = Rect.fromLTWH(envLeft, envTop, envW, envH);
    final RRect envRRect = RRect.fromRectAndRadius(
      envRect,
      const Radius.circular(10),
    );

    final Paint envPaint = Paint()..color = AppColors.primary;
    canvas.drawRRect(envRRect, envPaint);

    // Envelope flap (triangle)
    final Path flapPath = Path()
      ..moveTo(envLeft, envTop + 6)
      ..lineTo(cx, envTop + envH * 0.58)
      ..lineTo(envLeft + envW, envTop + 6)
      ..close();

    final Paint flapPaint = Paint()..color = AppColors.primaryDark;
    canvas.drawPath(flapPath, flapPaint);

    // Location pin (bottom-left of envelope, blue accent)
    final double pinCx = envLeft + envW * 0.14;
    final double pinCy = envTop + envH + 6;
    final double pinR = size.width * 0.075;

    final Paint pinPaint = Paint()..color = AppColors.mapPinBlue;
    canvas.drawCircle(Offset(pinCx, pinCy), pinR, pinPaint);

    final Path pinTail = Path()
      ..moveTo(pinCx - pinR * 0.7, pinCy + pinR * 0.55)
      ..lineTo(pinCx, pinCy + pinR * 1.9)
      ..lineTo(pinCx + pinR * 0.7, pinCy + pinR * 0.55)
      ..close();
    canvas.drawPath(pinTail, pinPaint);

    final Paint pinHolePaint = Paint()..color = AppColors.background;
    canvas.drawCircle(Offset(pinCx, pinCy), pinR * 0.38, pinHolePaint);

    // Checkmark badge (top-right of envelope, green)
    final double badgeCx = envLeft + envW - 6;
    final double badgeCy = envTop + 2;
    final double badgeR = size.width * 0.11;

    final Paint badgeBgPaint = Paint()..color = AppColors.background;
    canvas.drawCircle(Offset(badgeCx, badgeCy), badgeR + 4, badgeBgPaint);

    final Paint badgePaint = Paint()..color = AppColors.success;
    canvas.drawCircle(Offset(badgeCx, badgeCy), badgeR, badgePaint);

    final Paint checkPaint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Path checkPath = Path()
      ..moveTo(badgeCx - badgeR * 0.45, badgeCy)
      ..lineTo(badgeCx - badgeR * 0.1, badgeCy + badgeR * 0.4)
      ..lineTo(badgeCx + badgeR * 0.5, badgeCy - badgeR * 0.4);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(_OfferBadgePainter oldDelegate) => false;
}