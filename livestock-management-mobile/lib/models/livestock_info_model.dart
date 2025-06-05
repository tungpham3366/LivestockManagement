class LivestockInfo {
  final String livestockId;
  final String inspectionCode;
  final String specieName;
  final String color;
  final List<VaccinationInfo> vaccinationInfos;

  LivestockInfo({
    required this.livestockId,
    required this.inspectionCode,
    required this.specieName,
    required this.color,
    required this.vaccinationInfos,
  });

  factory LivestockInfo.fromJson(Map<String, dynamic> json) {
    return LivestockInfo(
      livestockId: json['livestockId'],
      inspectionCode: json['inspectionCode'],
      specieName: json['specieName'],
      color: json['color'],
      vaccinationInfos: (json['vaccinationInfos'] as List)
          .map((e) => VaccinationInfo.fromJson(e))
          .toList(),
    );
  }
}

class VaccinationInfo {
  final String diseaseName;
  final int numberOfVaccination;

  VaccinationInfo(
      {required this.diseaseName, required this.numberOfVaccination});

  factory VaccinationInfo.fromJson(Map<String, dynamic> json) {
    return VaccinationInfo(
      diseaseName: json['diseaseName'],
      numberOfVaccination: json['numberOfVaccination'],
    );
  }
}
