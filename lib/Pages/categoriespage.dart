import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Static Categories listing page — matches reference design:
/// "Categories" title, "All Categories" link, subtitle, then a list of
/// category rows with a colored icon chip, name, and trailing chevron.
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  // ── STATIC CATEGORY DATA ──────────────────────────────
  static final List<Map<String, dynamic>> _categories = [
    {
      "title": "Delivery & Courier",
      "icon": Icons.local_shipping_rounded,
      "color": const Color(0xFFFF7043), // orange
    },
    {
      "title": "Sales & Marketing",
      "icon": Icons.show_chart_rounded,
      "color": const Color(0xFF7E57C2), // purple
    },
    {
      "title": "Retail & Store",
      "icon": Icons.storefront_rounded,
      "color": const Color(0xFFEC407A), // pink
    },
    {
      "title": "Hotel & Hospitality",
      "icon": Icons.hotel_rounded,
      "color": const Color(0xFFAB47BC), // magenta
    },
    {
      "title": "Manufacturing",
      "icon": Icons.factory_rounded,
      "color": AppColors.primary, // blue
    },
    {
      "title": "Healthcare",
      "icon": Icons.medical_services_rounded,
      "color": AppColors.success, // green
    },
    {
      "title": "Driver Jobs",
      "icon": Icons.directions_car_filled_rounded,
      "color": const Color(0xFF5C6BC0), // indigo
    },
    {
      "title": "Back Office",
      "icon": Icons.business_center_rounded,
      "color": AppColors.textSecondary, // gray
    },
    {
      "title": "Construction",
      "icon": Icons.construction_rounded,
      "color": const Color(0xFFFFA726), // amber/orange
    },
    {
      "title": "More Categories",
      "icon": Icons.apps_rounded,
      "color": AppColors.unselected, // light gray
    },
  ];

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
          "Categories",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 4),
          // const Text(
          //   "Categories",
          //   style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          // ),
          const SizedBox(height: 10),

          // "All Categories" link
          // GestureDetector(
          //   onTap: () {},
          //   child: const Text(
          //     "All Categories",
          //     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
          //   ),
          // ),
          const SizedBox(height: 4),

          // Subtitle
          // const Text(
          //   "Choose a category",
          //   style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          // ),
          const SizedBox(height: 18),

          // Category list
          ...List.generate(_categories.length, (i) {
            final cat = _categories[i];
            final isLast = i == _categories.length - 1;
            return Column(
              children: [
                _categoryTile(
                  title: cat["title"] as String,
                  icon: cat["icon"] as IconData,
                  color: cat["color"] as Color,
                  onTap: () {},
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    color: AppColors.divider,
                    indent: 56,
                  ),
              ],
            );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── SINGLE CATEGORY ROW ───────────────────────────────
  Widget _categoryTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Icon chip
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.buttonText, size: 19),
            ),
            const SizedBox(width: 14),

            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Trailing chevron
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
