class ExportCustomerModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String customerNote;
  final int total;
  final int remaining;
  final String status;
  final String createdAt;

  ExportCustomerModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerNote,
    required this.total,
    required this.remaining,
    required this.status,
    required this.createdAt,
  });

  factory ExportCustomerModel.fromJson(Map<String, dynamic> json) {
    return ExportCustomerModel(
      id: json['id'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerNote: json['customerNote'] ?? '',
      total: json['total'] ?? 0,
      remaining: json['remaining'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
