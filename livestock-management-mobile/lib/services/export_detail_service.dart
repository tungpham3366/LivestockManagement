import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/export_detail_model.dart';

class ExportDetailService {
  Future<ExportDetailListModel?> fetchExportDetails(String customerId) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/procurement-management/list-export-details/$customerId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return ExportDetailListModel.fromJson(data['data']);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> addLivestockToBatchExportDetail({
    required String batchExportId,
    required String livestockId,
    required String expiredInsuranceDate,
    required String createdBy,
  }) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/export-management/add-livestock-to-batch-export-detail');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'batchExportId': batchExportId,
        'livestockId': livestockId,
        'expiredInsuranceDate': expiredInsuranceDate,
        'createdBy': createdBy,
      }),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> changeLivestockToBatchExportDetail({
    required String batchExportDetailId,
    required String batchExportId,
    required String livestockId,
    required String updatedBy,
  }) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/export-management/change-livestock-to-batch-export-detail/$batchExportDetailId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'batchExportId': batchExportId,
        'livestockId': livestockId,
        'updatedBy': updatedBy,
      }),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> confirmHandoverBatchExportDetail({
    required String batchExportDetailId,
    required String userId,
  }) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/export-management/confirm-handover-batch-export-detail/$batchExportDetailId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userId),
    );
    return json.decode(response.body);
  }
}
