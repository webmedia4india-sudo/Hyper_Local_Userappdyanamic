class BannerModel {
  final int id;
  final String title;
  final String? subtitle;
  final String? tag;
  final String imageUrl;
  final String? buttonText;
  final String? redirectType;
  final String? redirectValue;

  BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.tag,
    required this.imageUrl,
    this.buttonText,
    this.redirectType,
    this.redirectValue,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      tag: (json['tag'] ?? json['badge'])?.toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? json['image'])?.toString() ?? '',
      buttonText: (json['button_text'] ?? json['buttonText'])?.toString(),
      redirectType: (json['redirect_type'] ?? json['redirectType'])?.toString(),
      redirectValue: (json['redirect_value'] ?? json['redirectValue'])?.toString(),
    );
  }
}