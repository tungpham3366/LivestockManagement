import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ExportChooseScanService {
  Future<List<Map<String, dynamic>>> getAllSpecies() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final response = await http.get(
      Uri.parse(
          '${AppConstants.baseUrl}/api/inspection-code-range/get-all-specie'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['data'] as List;
      return items.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Lỗi lấy danh sách loài');
    }
  }

  Future<String?> getLivestockIdByInspectionCodeAndType(
      String inspectionCode, int specieType) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final response = await http.post(
      Uri.parse(
          '${AppConstants.baseUrl}/api/livestock-management/get-livestockId-by-inspectioncode-and-type'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'inspectionCode': inspectionCode,
        'specieType': specieType,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return data['data']['id'];
      }
      return null;
    } else {
      throw Exception('Lỗi tìm livestockId');
    }
  }
}
