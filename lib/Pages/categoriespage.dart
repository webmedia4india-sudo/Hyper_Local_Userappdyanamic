import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/category_service.dart';
import '../services/api_service.dart';
import '../models/category/category_model.dart';
import 'recommendedjpbpage.dart';

/// Categories listing page — dynamically connected to Admin Panel Backend (/api/categories)
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final CategoryService _categoryService = CategoryService();
  List<CategoryModel> _categoriesList = [];
  bool _isLoading = true;

  static final List<Map<String, dynamic>> _fallbackCategories = [
    {
      "title": "Delivery & Courier",
      "icon": Icons.local_shipping_rounded,
      "color": const Color(0xFFFF7043),
    },
    {
      "title": "Sales & Marketing",
      "icon": Icons.show_chart_rounded,
      "color": const Color(0xFF7E57C2),
    },
    {
      "title": "Retail & Store",
      "icon": Icons.storefront_rounded,
      "color": const Color(0xFFEC407A),
    },
    {
      "title": "Hotel & Hospitality",
      "icon": Icons.hotel_rounded,
      "color": const Color(0xFFAB47BC),
    },
    {
      "title": "Manufacturing",
      "icon": Icons.factory_rounded,
      "color": AppColors.primary,
    },
    {
      "title": "Healthcare",
      "icon": Icons.medical_services_rounded,
      "color": AppColors.success,
    },
    {
      "title": "Driver Jobs",
      "icon": Icons.directions_car_filled_rounded,
      "color": const Color(0xFF5C6BC0),
    },
    {
      "title": "Back Office",
      "icon": Icons.business_center_rounded,
      "color": AppColors.textSecondary,
    },
    {
      "title": "Construction",
      "icon": Icons.construction_rounded,
      "color": const Color(0xFFFFA726),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final list = await _categoryService.getCategories();
      if (mounted) {
        setState(() {
          _categoriesList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final p = raw.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    final base = ApiService.baseUrl.replaceAll('/api', '');
    final clean = p.startsWith('/') ? p.substring(1) : p;
    return '$base/$clean';
  }

  IconData _getIconForTitle(String title, int index) {
    final t = title.toLowerCase();
    if (t.contains('delivery') || t.contains('courier')) return Icons.electric_moped_rounded;
    if (t.contains('retail') || t.contains('store')) return Icons.shopping_bag_rounded;
    if (t.contains('hotel') || t.contains('hospitality')) return Icons.room_service_rounded;
    if (t.contains('sales') || t.contains('marketing')) return Icons.campaign_rounded;
    if (t.contains('tech') || t.contains('code') || t.contains('it') || t.contains('software')) return Icons.code_rounded;
    if (t.contains('design')) return Icons.palette_rounded;
    if (t.contains('office')) return Icons.business_center_rounded;
    if (t.contains('driver')) return Icons.directions_car_filled_rounded;
    if (t.contains('manufactur') || t.contains('factory')) return Icons.factory_rounded;
    if (t.contains('health') || t.contains('medical')) return Icons.medical_services_rounded;
    if (t.contains('construct')) return Icons.construction_rounded;

    final defaultList = [
      Icons.work_rounded,
      Icons.category_rounded,
      Icons.business_center_rounded,
      Icons.stars_rounded,
      Icons.widgets_rounded,
    ];
    return defaultList[index % defaultList.length];
  }

  Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFFFF7043),
      const Color(0xFF7E57C2),
      const Color(0xFFEC407A),
      const Color(0xFFAB47BC),
      AppColors.primary,
      AppColors.success,
      const Color(0xFF5C6BC0),
      const Color(0xFFFFA726),
    ];
    return colors[index % colors.length];
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
          "Categories",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCategories,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                children: [
                  if (_categoriesList.isNotEmpty)
                    ...List.generate(_categoriesList.length, (i) {
                      final cat = _categoriesList[i];
                      final isLast = i == _categoriesList.length - 1;
                      final iconUrl = _formatUrl(cat.iconImg);
                      final color = _getColorForIndex(i);

                      return Column(
                        children: [
                          _categoryTile(
                            title: cat.title,
                            subtitle: cat.subtitle,
                            iconUrl: iconUrl,
                            fallbackIcon: _getIconForTitle(cat.title, i),
                            color: color,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RecommendedJobPage(),
                                ),
                              );
                            },
                          ),
                          if (!isLast)
                            const Divider(
                              height: 1,
                              color: AppColors.divider,
                              indent: 56,
                            ),
                        ],
                      );
                    })
                  else
                    ...List.generate(_fallbackCategories.length, (i) {
                      final cat = _fallbackCategories[i];
                      final isLast = i == _fallbackCategories.length - 1;
                      return Column(
                        children: [
                          _categoryTile(
                            title: cat["title"] as String,
                            subtitle: null,
                            iconUrl: '',
                            fallbackIcon: cat["icon"] as IconData,
                            color: cat["color"] as Color,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RecommendedJobPage(),
                                ),
                              );
                            },
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
            ),
    );
  }

  Widget _categoryTile({
    required String title,
    String? subtitle,
    required String iconUrl,
    required IconData fallbackIcon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: iconUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          iconUrl,
                          width: 26,
                          height: 26,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(fallbackIcon, color: color, size: 22),
                        ),
                      )
                    : Icon(fallbackIcon, color: color, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
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

