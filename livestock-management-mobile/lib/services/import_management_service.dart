import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImportManagementService {
  Future<Map<String, dynamic>?> getBatchImportLivestockScanInfo(
      String livestockId) async {
    final url = AppConstants.baseUrl +
        '/api/import-management/get-batchimport-livestock-scan-info/' +
        livestockId;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
    }
    return null;
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // hoặc key user phù hợp
  }

  Future<bool> confirmLivestockForMeatSale(String livestockId) async {
    final userId = await _getUserId();
    if (userId == null) return false;
    final url = AppConstants.baseUrl +
        '/api/import-management/confirm-livestock-for-meat-sale/$livestockId?requestedBy=$userId';
    final response = await http.put(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  Future<bool> confirmImported(String livestockId) async {
    final userId = await _getUserId();
    if (userId == null) return false;
    final url = AppConstants.baseUrl +
        '/api/import-management/confirm-imported/$livestockId?requestedBy=$userId';
    final response = await http.put(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> getListMissingBatchImport() async {
    final url = AppConstants.baseUrl +
        '/api/import-management/get-list-missing-batchimport';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true &&
          data['data'] != null &&
          data['data']['items'] is List) {
        return List<Map<String, dynamic>>.from(data['data']['items']);
      }
    }
    return [];
  }

  Future<Map<String, dynamic>> confirmReplaceLivestockToBatchImport(
      String batchImportId, Map<String, dynamic> body) async {
    final url = AppConstants.baseUrl +
        '/api/import-management/confirm-replace-livestock-to-batch-import/$batchImportId';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    }
    return {'success': false, 'message': 'Lỗi kết nối máy chủ'};
  }
}
