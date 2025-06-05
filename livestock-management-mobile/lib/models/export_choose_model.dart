class ExportOrderModel {
  final String id;
  final String code;
  final String customerName;
  final String phoneNumber;
  final int total;
  final int received;
  final String status;
  final String type;
  final DateTime createdAt;

  ExportOrderModel({
    required this.id,
    required this.code,
    required this.customerName,
    required this.phoneNumber,
    required this.total,
    required this.received,
    required this.status,
    required this.type,
    required this.createdAt,
  });

  factory ExportOrderModel.fromJson(Map<String, dynamic> json) {
    return ExportOrderModel(
      id: json['id'],
      code: json['code'],
      customerName: json['customerName'],
      phoneNumber: json['phoneNumber'],
      total: json['total'],
      received: json['received'],
      status: json['status'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ExportProcurementModel {
  final String id;
  final String code;
  final String name;
  final DateTime? successDate;
  final DateTime? expirationDate;
  final DateTime? completionDate;
  final int totalExported;
  final int totalRequired;
  final int totalSelected;
  final DateTime createdAt;
  final String status;
  final HandoverInformation? handoverInformation;

  ExportProcurementModel({
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

  factory ExportProcurementModel.fromJson(Map<String, dynamic> json) {
    return ExportProcurementModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      successDate: json['successDate'] != null
          ? DateTime.parse(json['successDate'])
          : null,
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'])
          : null,
      completionDate: json['completionDate'] != null
          ? DateTime.tryParse(json['completionDate'])
          : null,
      totalExported: json['totalExported'],
      totalRequired: json['totalRequired'],
      totalSelected: json['totalSelected'],
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
      handoverInformation: json['handoverinformation'] != null
          ? HandoverInformation.fromJson(json['handoverinformation'])
          : null,
    );
  }
}

class HandoverInformation {
  final int totalSelected;
  final int completeCount;
  final int totalCount;

  HandoverInformation({
    required this.totalSelected,
    required this.completeCount,
    required this.totalCount,
  });

  factory HandoverInformation.fromJson(Map<String, dynamic> json) {
    return HandoverInformation(
      totalSelected: json['totalSelected'],
      completeCount: json['completeCount'],
      totalCount: json['totalCount'],
    );
  }
}
