import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/walkininterviewspage.dart';
import '../utils/app_colors.dart';

class HyperlocalFeaturesPage extends StatefulWidget {
  const HyperlocalFeaturesPage({super.key});

  @override
  State<HyperlocalFeaturesPage> createState() => _HyperlocalFeaturesPageState();
}

class _HyperlocalFeaturesPageState extends State<HyperlocalFeaturesPage> {
  String _selectedRadius = "within 5 km";

  final List<String> _radiusOptions = [
    "within 2 km",
    "within 5 km",
    "within 10 km",
    "within 20 km",
  ];

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
          "Jobs Near You",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.buttonText),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── FILTER DROPDOWN ────────────────────
          Container(
            width: double.infinity,
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: PopupMenuButton<String>(
                onSelected: (value) => setState(() => _selectedRadius = value),
                itemBuilder: (context) => _radiusOptions
                    .map(
                      (option) =>
                          PopupMenuItem(value: option, child: Text(option)),
                    )
                    .toList(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedRadius,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── MAP AREA WITH HEATMAP ────────────────────
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _MapHeatmapPainter()),
                ),

                // Floating job card at bottom
                Positioned(left: 16, right: 16, bottom: 16, child: _jobCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM JOB CARD ────────────────────
  Widget _jobCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                "Z",
                style: TextStyle(
                  color: AppColors.buttonText,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delivery Partner",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Text(
                      "Zomato",
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "1.2 km",
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "₹18,000 - ₹28,000",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WalkinInterviewsPage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  "View Job",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── CUSTOM PAINTER: MAP + HEATMAP EFFECT ────────────────────
class _MapHeatmapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base map background
    final basePaint = Paint()..color = const Color(0xFFEAF1E6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // Simple road lines
    final roadPaint = Paint()
      ..color = const Color(0xFFD8DEE0)
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(0, size.height * 0.35),
      Offset(size.width, size.height * 0.45),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.35, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.62),
      roadPaint,
    );

    // Water body (bottom right, like image)
    final waterPaint = Paint()..color = const Color(0xFFB3D9F2);
    final waterPath = Path()
      ..moveTo(size.width * 0.6, size.height)
      ..lineTo(size.width, size.height * 0.65)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Green patches (parks)
    final parkPaint = Paint()..color = const Color(0xFFCDE8C7);
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.25),
      40,
      parkPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.55),
      35,
      parkPaint,
    );

    // Heatmap blobs (red/orange/green concentric glow)
    _drawHeatBlob(canvas, Offset(size.width * 0.55, size.height * 0.28), 70);
    _drawHeatBlob(canvas, Offset(size.width * 0.3, size.height * 0.55), 60);
    _drawHeatBlob(canvas, Offset(size.width * 0.2, size.height * 0.72), 45);
    _drawHeatBlob(canvas, Offset(size.width * 0.42, size.height * 0.66), 40);
  }

  void _drawHeatBlob(Canvas canvas, Offset center, double radius) {
    final gradient = RadialGradient(
      colors: [
        AppColors.success.withOpacity(0.9),
        AppColors.warning.withOpacity(0.6),
        AppColors.error.withOpacity(0.35),
        AppColors.error.withOpacity(0.0),
      ],
      stops: const [0.0, 0.35, 0.7, 1.0],
    );

    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(center, radius, paint);

    // Center dot
    canvas.drawCircle(center, 5, Paint()..color = AppColors.success);
    canvas.drawCircle(
      center,
      5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _MapHeatmapPainter oldDelegate) => false;
}
