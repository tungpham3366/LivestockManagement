import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/batch_import.dart';
import '../constants/app_constants.dart';

class BatchImportService {
  final String baseUrl = AppConstants.baseUrl;

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.userKey);
    if (userData != null) {
      final userMap = json.decode(userData);
      return userMap['id'] as String?;
    }
    return null;
  }

  Future<BatchImportResponse> getPinnedBatchImports(String userId) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/api/import-management/get-list-pinned-batchimport/$userId'),
    );
    return _handleResponse(response);
  }

  Future<BatchImportResponse> getOverdueBatchImports() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/import-management/get-list-overdue-batchimport'),
    );
    return _handleResponse(response);
  }

  Future<BatchImportResponse> getMissingBatchImports() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/import-management/get-list-missing-batchimport'),
    );
    return _handleResponse(response);
  }

  Future<BatchImportResponse> getNearDueBatchImports(int number) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/api/import-management/get-list-neardue-batchimport/$number'),
    );
    return _handleResponse(response);
  }

  Future<BatchImportResponse> getUpcomingBatchImports(int number) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/api/import-management/get-list-upcoming-batchimport/$number'),
    );
    return _handleResponse(response);
  }

  Future<bool> addPinnedBatchImport(String batchImportId, String userId) async {
    final response = await http.post(
      Uri.parse(
          '$baseUrl/api/import-management/add-to-pinned-importbatch/$batchImportId?requestedBy=$userId'),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['success'] == true;
    }
    return false;
  }

  Future<bool> removePinnedBatchImport(String pinnedId, String userId) async {
    final response = await http.delete(
      Uri.parse(
          '$baseUrl/api/import-management/remove-from-pinned-batch-import/$pinnedId?requestedBy=$userId'),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['success'] == true;
    }
    return false;
  }

  Future<String?> getInspectionCodeFromSpecie(String specie) async {
    final url = Uri.parse(
        '${baseUrl}/api/inspection-code-range/revice-an-inspection-code/${Uri.encodeComponent(specie)}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'] as String?;
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getSpecieNamesById(int specieId) async {
    final url = Uri.parse(
        '${baseUrl}/api/specie-mangament/get-list-specie-name/$specieId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        return List<Map<String, dynamic>>.from(jsonResponse['data']);
      }
    }
    return [];
  }

  Future<bool> addLivestockToBatchImport({
    required String batchImportId,
    required Map<String, dynamic> body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId;
    final userData = prefs.getString(AppConstants.userKey);
    if (userData != null) {
      final userMap = json.decode(userData);
      userId = userMap['id'] as String?;
    }
    final Map<String, dynamic> requestBody = Map<String, dynamic>.from(body);
    requestBody['requestedBy'] = userId ?? '';
    final url = Uri.parse(
        '$baseUrl/api/import-management/add-livestock-to-batchimport/$batchImportId');
    final response = await http.put(url,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['success'] == true;
    }
    return false;
  }

  BatchImportResponse _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return BatchImportResponse.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Unknown error occurred');
    }
    throw Exception('Failed to load data');
  }
}
