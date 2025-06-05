class ExportConfirmModel {
  final String id;
  final String code;
  final String customerName;
  final String phoneNumber;
  final int total;
  final int received;
  final String status;
  final String type;
  final String createdAt;

  ExportConfirmModel({
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

  factory ExportConfirmModel.fromJson(Map<String, dynamic> json) {
    return ExportConfirmModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      customerName: json['customerName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      total: json['total'] ?? 0,
      received: json['received'] ?? 0,
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'total': total,
      'received': received,
      'status': status,
      'type': type,
      'createdAt': createdAt,
    };
  }
}
