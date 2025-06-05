class BatchVaccination {
  final String id;
  final String name;
  final String medcicalType;
  final String symptom;
  final String dateSchedule;
  final String conductedBy;
  final String status;
  final String? dateConduct;
  final String createdAt;

  BatchVaccination({
    required this.id,
    required this.name,
    required this.medcicalType,
    required this.symptom,
    required this.dateSchedule,
    required this.conductedBy,
    required this.status,
    this.dateConduct,
    required this.createdAt,
  });

  factory BatchVaccination.fromJson(Map<String, dynamic> json) {
    return BatchVaccination(
      id: json['id'],
      name: json['name'],
      medcicalType: json['medcicalType'],
      symptom: json['symptom'],
      dateSchedule: json['dateSchedule'],
      conductedBy: json['conductedBy'],
      status: json['status'],
      dateConduct: json['dateConduct'],
      createdAt: json['createdAt'],
    );
  }
}
