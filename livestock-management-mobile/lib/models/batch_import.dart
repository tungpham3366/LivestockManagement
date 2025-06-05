class BatchImport {
  final String? id;
  final String batchImportId;
  final String batchImportName;
  final String batchImportCompletedDate;
  final String createdAt;
  final String? dayOver;
  final String? totalMissing;
  final String? dayleft;

  BatchImport({
    this.id,
    required this.batchImportId,
    required this.batchImportName,
    required this.batchImportCompletedDate,
    required this.createdAt,
    this.dayOver,
    this.totalMissing,
    this.dayleft,
  });

  factory BatchImport.fromJson(Map<String, dynamic> json) {
    return BatchImport(
      id: json['id'],
      batchImportId: json['batchImportId'],
      batchImportName: json['batchImportName'],
      batchImportCompletedDate: json['batchImportCompletedDate'],
      createdAt: json['createdAt'],
      dayOver: json['dayOver'],
      totalMissing: json['totalMissing'],
      dayleft: json['dayleft'],
    );
  }
}

class BatchImportResponse {
  final int total;
  final List<BatchImport> items;

  BatchImportResponse({
    required this.total,
    required this.items,
  });

  factory BatchImportResponse.fromJson(Map<String, dynamic> json) {
    return BatchImportResponse(
      total: json['total'],
      items: (json['items'] as List)
          .map((item) => BatchImport.fromJson(item))
          .toList(),
    );
  }
}
