class CityModel {
  final int id;
  final String cityName;
  final int? stateId;
  final String? stateName;

  CityModel({
    required this.id,
    required this.cityName,
    this.stateId,
    this.stateName,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'] ?? json['city_id'] ?? json['cityId'];
    return CityModel(
      id: idVal is int ? idVal : int.tryParse(idVal?.toString() ?? '0') ?? 0,
      cityName: (json['city_name'] ?? json['cityName'] ?? json['name'] ?? '').toString().trim(),
      stateId: json['state_id'] != null ? int.tryParse(json['state_id'].toString()) : null,
      stateName: json['state_name']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_name': cityName,
      if (stateId != null) 'state_id': stateId,
      if (stateName != null) 'state_name': stateName,
    };
  }
}
