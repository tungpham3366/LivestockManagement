class ProcurementResponse {
  final int statusCode;
  final bool success;
  final List<ProcurementItem>? data;
  final dynamic errors;
  final String message;

  ProcurementResponse({
    required this.statusCode,
    required this.success,
    this.data,
    this.errors,
    required this.message,
  });

  factory ProcurementResponse.fromJson(Map<String, dynamic> json) {
    List<ProcurementItem> procurementList = [];
    if (json['data'] != null && json['data'] is List) {
      procurementList = List<ProcurementItem>.from(
        json['data'].map((item) => ProcurementItem.fromJson(item)),
      );
    }

    return ProcurementResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      data: procurementList,
      errors: json['errors'],
      message: json['message'],
    );
  }
}

class ProcurementDetailResponse {
  final int statusCode;
  final bool success;
  final ProcurementDetail? data;
  final dynamic errors;
  final String message;

  ProcurementDetailResponse({
    required this.statusCode,
    required this.success,
    this.data,
    this.errors,
    required this.message,
  });

  factory ProcurementDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProcurementDetailResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      data: json['data'] != null
          ? ProcurementDetail.fromJson(json['data'])
          : null,
      errors: json['errors'],
      message: json['message'],
    );
  }
}

class ProcurementItem {
  final String procurementId;
  final String procurementName;
  final String procurementCode;
  final DateTime expirationDate;
  final int livestockQuantity;
  final List<DiseaseInfo> diseaseRequires;

  ProcurementItem({
    required this.procurementId,
    required this.procurementName,
    required this.procurementCode,
    required this.expirationDate,
    required this.livestockQuantity,
    required this.diseaseRequires,
  });

  factory ProcurementItem.fromJson(Map<String, dynamic> json) {
    List<DiseaseInfo> diseaseList = [];
    if (json['diseaseRequires'] != null) {
      diseaseList = List<DiseaseInfo>.from(
        json['diseaseRequires'].map((item) => DiseaseInfo.fromJson(item)),
      );
    }

    return ProcurementItem(
      procurementId: json['procurementId'],
      procurementName: json['procurementName'],
      procurementCode: json['procurementCode'],
      expirationDate: DateTime.parse(json['expirationDate']),
      livestockQuantity: json['livestockQuantity'],
      diseaseRequires: diseaseList,
    );
  }
}

class DiseaseInfo {
  final String diseaseName;
  final int hasDone;

  DiseaseInfo({
    required this.diseaseName,
    required this.hasDone,
  });

  factory DiseaseInfo.fromJson(Map<String, dynamic> json) {
    return DiseaseInfo(
      diseaseName: json['diseaseName'],
      hasDone: json['hasDone'],
    );
  }
}

class ProcurementDetail {
  final String procurementId;
  final String procurementName;
  final String procurementCode;
  final DateTime expirationDate;
  final int livestockQuantity;
  final List<DiseaseRequire> diseaseRequiresForSpecie;

  ProcurementDetail({
    required this.procurementId,
    required this.procurementName,
    required this.procurementCode,
    required this.expirationDate,
    required this.livestockQuantity,
    required this.diseaseRequiresForSpecie,
  });

  factory ProcurementDetail.fromJson(Map<String, dynamic> json) {
    List<DiseaseRequire> diseaseList = [];
    if (json['diseaseRequiresForSpecie'] != null) {
      diseaseList = List<DiseaseRequire>.from(
        json['diseaseRequiresForSpecie']
            .map((item) => DiseaseRequire.fromJson(item)),
      );
    }

    return ProcurementDetail(
      procurementId: json['procurementId'],
      procurementName: json['procurementName'],
      procurementCode: json['procurementCode'],
      expirationDate: DateTime.parse(json['expirationDate']),
      livestockQuantity: json['livestockQuantity'],
      diseaseRequiresForSpecie: diseaseList,
    );
  }
}

class DiseaseRequire {
  final String diseaseName;
  final String specieName;
  final String batchVaccinationId;
  final int hasDone;
  final String medicineName;
  final int isCreated;
  final int totalQuantity;

  DiseaseRequire({
    required this.diseaseName,
    required this.specieName,
    required this.batchVaccinationId,
    required this.hasDone,
    required this.medicineName,
    required this.isCreated,
    required this.totalQuantity,
  });

  factory DiseaseRequire.fromJson(Map<String, dynamic> json) {
    return DiseaseRequire(
      diseaseName: json['diseaseName'] ?? '',
      specieName: json['specieName'] ?? '',
      batchVaccinationId: json['batchVaccinationId'] ?? '',
      hasDone: json['hasDone'] ?? 0,
      medicineName: json['medicineName'] ?? '',
      isCreated: json['isCreated'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
    );
  }
}
