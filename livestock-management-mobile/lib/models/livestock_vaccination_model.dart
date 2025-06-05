class LivestockVaccinationResponse {
  final int statusCode;
  final bool success;
  final LivestockVaccinationInfo? data;
  final dynamic errors;
  final String message;

  LivestockVaccinationResponse({
    required this.statusCode,
    required this.success,
    this.data,
    this.errors,
    required this.message,
  });

  factory LivestockVaccinationResponse.fromJson(Map<String, dynamic> json) {
    return LivestockVaccinationResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      data: json['data'] != null
          ? LivestockVaccinationInfo.fromJson(json['data'])
          : null,
      errors: json['errors'],
      message: json['message'],
    );
  }
}

class LivestockVaccinationInfo {
  final String livestockId;
  final String inspectionCode;
  final String specieName;
  final String color;
  final List<LivestockRequireDisease> livestockRequireDisease;

  LivestockVaccinationInfo({
    required this.livestockId,
    required this.inspectionCode,
    required this.specieName,
    required this.color,
    required this.livestockRequireDisease,
  });

  factory LivestockVaccinationInfo.fromJson(Map<String, dynamic> json) {
    List<LivestockRequireDisease> diseaseList = [];
    if (json['livestockRequireDisease'] != null) {
      diseaseList = List<LivestockRequireDisease>.from(
        json['livestockRequireDisease']
            .map((item) => LivestockRequireDisease.fromJson(item)),
      );
    }

    return LivestockVaccinationInfo(
      livestockId: json['livestockId'],
      inspectionCode: json['inspectionCode'],
      specieName: json['specieName'],
      color: json['color'],
      livestockRequireDisease: diseaseList,
    );
  }
}

class LivestockRequireDisease {
  final String diseaseName;
  final String medicineName;
  final String batchVaccinationId;

  LivestockRequireDisease({
    required this.diseaseName,
    required this.medicineName,
    required this.batchVaccinationId,
  });

  factory LivestockRequireDisease.fromJson(Map<String, dynamic> json) {
    return LivestockRequireDisease(
      diseaseName: json['diseaseName'],
      medicineName: json['medicineName'],
      batchVaccinationId: json['batchVaccinationId'],
    );
  }
}
