class LivestockSummaryModel {
  final String id;
  final String inspectionCode;
  final String species;
  final double weight;
  final String gender;
  final String color;
  final String origin;
  final String status;

  LivestockSummaryModel({
    required this.id,
    required this.inspectionCode,
    required this.species,
    required this.weight,
    required this.gender,
    required this.color,
    required this.origin,
    required this.status,
  });

  factory LivestockSummaryModel.fromJson(Map<String, dynamic> json) {
    return LivestockSummaryModel(
      id: json['id'] ?? '',
      inspectionCode: json['inspectionCode'] ?? '',
      species: json['species'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      gender: json['gender'] ?? '',
      color: json['color'] ?? '',
      origin: json['origin'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
