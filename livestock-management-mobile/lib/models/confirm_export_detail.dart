class ConfirmExportDetailModel {
  final String id;
  final String code;
  final String customerName;
  final int total;
  final int received;
  final int exportCount;

  ConfirmExportDetailModel({
    required this.id,
    required this.code,
    required this.customerName,
    required this.total,
    required this.received,
    required this.exportCount,
  });
}
