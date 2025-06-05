class ImportLivestockInfoModel {
  final String livestockId;
  final String batchImportName;
  final String inspectionCode;
  final String specieName;
  final String gender;
  final String color;
  final double weight;
  final String dob;
  final String createdAt;
  final int total;
  final int imported;

  ImportLivestockInfoModel({
    required this.livestockId,
    required this.batchImportName,
    required this.inspectionCode,
    required this.specieName,
    required this.gender,
    required this.color,
    required this.weight,
    required this.dob,
    required this.createdAt,
    required this.total,
    required this.imported,
  });

  factory ImportLivestockInfoModel.fromJson(Map<String, dynamic> json) {
    return ImportLivestockInfoModel(
      livestockId: json['livestockId'] ?? '',
      batchImportName: json['batchImportName'] ?? '',
      inspectionCode: json['inspectionCode'] ?? '',
      specieName: json['specieName'] ?? '',
      gender: json['gender'] ?? '',
      color: json['color'] ?? '',
      weight: (json['weight'] is int)
          ? (json['weight'] as int).toDouble()
          : (json['weight'] ?? 0.0).toDouble(),
      dob: json['dob'] ?? '',
      createdAt: json['createdAt'] ?? '',
      total: json['total'] ?? 0,
      imported: json['imported'] ?? 0,
    );
  }
}
