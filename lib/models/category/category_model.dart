class CategoryModel {
  final int id;
  final String title;
  final String? subtitle;
  final String? backgroundImg;
  final String? iconImg;

  CategoryModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.backgroundImg,
    this.iconImg,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'] ?? json['_id'] ?? json['category_id'] ?? json['categoryId'];
    final titleVal = json['title'] ??
        json['category_name'] ??
        json['categoryName'] ??
        json['name'] ??
        json['label'] ??
        '';

    return CategoryModel(
      id: idVal is int
          ? idVal
          : int.tryParse(idVal?.toString() ?? '0') ?? 0,
      title: titleVal.toString().trim().isNotEmpty
          ? titleVal.toString().trim()
          : 'Category',
      subtitle: (json['subtitle'] ?? json['openings'] ?? json['description'])?.toString(),
      backgroundImg: (json['background_img'] ??
              json['backgroundImg'] ??
              json['bgImage'] ??
              json['bg_image'])
          ?.toString(),
      iconImg: (json['icon_img'] ??
              json['iconImg'] ??
              json['icon'] ??
              json['icon_image'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'background_img': backgroundImg,
      'icon_img': iconImg,
    };
  }
}
