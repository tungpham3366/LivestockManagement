class ExportDetailModel {
  final String batchExportDetailId;
  final String livestockId;
  final String inspectionCode;
  final double? weightExport;
  final String? handoverDate;
  final String? exportDate;
  final String? expiredInsuranceDate;
  final String status;

  ExportDetailModel({
    required this.batchExportDetailId,
    required this.livestockId,
    required this.inspectionCode,
    this.weightExport,
    this.handoverDate,
    this.exportDate,
    this.expiredInsuranceDate,
    required this.status,
  });

  factory ExportDetailModel.fromJson(Map<String, dynamic> json) {
    return ExportDetailModel(
      batchExportDetailId: json['batchExportDetailId'] ?? '',
      livestockId: json['livestockId'] ?? '',
      inspectionCode: json['inspectionCode'] ?? '',
      weightExport: json['weightExport'] != null
          ? (json['weightExport'] as num).toDouble()
          : null,
      handoverDate: json['handoverDate'],
      exportDate: json['exportDate'],
      expiredInsuranceDate: json['expiredInsuranceDate'],
      status: json['status'] ?? '',
    );
  }
}

class ExportDetailListModel {
  final String batchExportId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String customerNote;
  final int totalLivestocks;
  final int received;
  final int remaining;
  final String status;
  final int total;
  final List<ExportDetailModel> items;

  ExportDetailListModel({
    required this.batchExportId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerNote,
    required this.totalLivestocks,
    required this.received,
    required this.remaining,
    required this.status,
    required this.total,
    required this.items,
  });

  factory ExportDetailListModel.fromJson(Map<String, dynamic> json) {
    return ExportDetailListModel(
      batchExportId: json['batchExportId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerNote: json['customerNote'] ?? '',
      totalLivestocks: json['totalLivestocks'] ?? 0,
      received: json['received'] ?? 0,
      remaining: json['remaining'] ?? 0,
      status: json['status'] ?? '',
      total: json['total'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => ExportDetailModel.fromJson(e))
          .toList(),
    );
  }
}
