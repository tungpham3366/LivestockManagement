import '../utils/specie_helper.dart';

class SpecieResponse {
  final int statusCode;
  final bool success;
  final SpecieData? data;
  final dynamic errors;
  final String message;

  SpecieResponse({
    required this.statusCode,
    required this.success,
    this.data,
    this.errors,
    required this.message,
  });

  factory SpecieResponse.fromJson(Map<String, dynamic> json) {
    return SpecieResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      data: json['data'] != null ? SpecieData.fromJson(json['data']) : null,
      errors: json['errors'],
      message: json['message'],
    );
  }
}

class SpecieData {
  final int total;
  final List<String> items;
  final List<Specie> specieList;

  SpecieData({
    required this.total,
    required this.items,
    required this.specieList,
  });

  factory SpecieData.fromJson(Map<String, dynamic> json) {
    // Tạo specieList từ dữ liệu thô
    List<Specie> specieList = [];
    if (json['specieDetails'] != null) {
      specieList = List<Specie>.from(
          json['specieDetails'].map((item) => Specie.fromJson(item)));
    }

    // Nếu không có specieDetails, tạo một danh sách mặc định
    if (specieList.isEmpty) {
      // Sử dụng defaultSpecieTypesMap từ SpecieHelper
      final defaultTypes = SpecieHelper.specieTypeMap;

      // Tạo danh sách mặc định từ items
      List<String> items = List<String>.from(json['items']);
      for (var name in items) {
        specieList.add(Specie(
            id: name.toLowerCase().replaceAll(" ", "_"),
            name: name,
            type: defaultTypes[name] ?? 0));
      }
    }

    return SpecieData(
      total: json['total'],
      items: List<String>.from(json['items']),
      specieList: specieList,
    );
  }
}

class Specie {
  final String id;
  final String name;
  final int type;

  Specie({
    required this.id,
    required this.name,
    required this.type,
  });

  factory Specie.fromJson(Map<String, dynamic> json) {
    return Specie(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 0,
    );
  }
}
