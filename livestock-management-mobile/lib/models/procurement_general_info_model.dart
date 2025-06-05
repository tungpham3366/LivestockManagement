class ProcurementGeneralInfoModel {
  final String owner;
  final int expiredDuration;
  final String description;
  final String createdBy;
  final List<dynamic> details;
  final String id;
  final String code;
  final String name;
  final String? successDate;
  final String? expirationDate;
  final String? completionDate;
  final int totalExported;
  final int totalRequired;
  final int totalSelected;
  final String createdAt;
  final String status;
  final dynamic handoverInformation;

  ProcurementGeneralInfoModel({
    required this.owner,
    required this.expiredDuration,
    required this.description,
    required this.createdBy,
    required this.details,
    required this.id,
    required this.code,
    required this.name,
    required this.successDate,
    required this.expirationDate,
    required this.completionDate,
    required this.totalExported,
    required this.totalRequired,
    required this.totalSelected,
    required this.createdAt,
    required this.status,
    required this.handoverInformation,
  });

  factory ProcurementGeneralInfoModel.fromJson(Map<String, dynamic> json) {
    return ProcurementGeneralInfoModel(
      owner: json['owner'] ?? '',
      expiredDuration: json['expiredDuration'] ?? 0,
      description: json['description'] ?? '',
      createdBy: json['createdBy'] ?? '',
      details: json['details'] ?? [],
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      successDate: json['successDate'],
      expirationDate: json['expirationDate'],
      completionDate: json['completionDate'],
      totalExported: json['totalExported'] ?? 0,
      totalRequired: json['totalRequired'] ?? 0,
      totalSelected: json['totalSelected'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      status: json['status'] ?? '',
      handoverInformation: json['handoverinformation'],
    );
  }
}
