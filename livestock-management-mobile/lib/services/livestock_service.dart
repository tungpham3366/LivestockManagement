import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/livestock_vaccination_model.dart';
import '../constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LivestockService {
  Future<LivestockVaccinationResponse> getLivestockVaccinationInfo(
      String procurementId, String livestockId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      final response = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/api/vaccination-management/get-livestock-require-vaccination-for-procurement/$procurementId/$livestockId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);
      return LivestockVaccinationResponse.fromJson(responseData);
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(AppConstants.networkError);
      }
      throw Exception(AppConstants.serverError);
    }
  }

  Future<LivestockVaccinationResponse> getLivestockVaccinationInfoByCode(
      String procurementId, int specieType, String inspectionCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      final response = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/api/vaccination-management/get-livestock-require-vaccination-for-procurement/$procurementId/$specieType/$inspectionCode'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);
      return LivestockVaccinationResponse.fromJson(responseData);
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(AppConstants.networkError);
      }
      throw Exception(AppConstants.serverError);
    }
  }

  // Phương thức xác nhận tiêm vật nuôi
  Future<Map<String, dynamic>> confirmVaccination(
      String livestockId, String batchVaccinationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final userData = prefs.getString(AppConstants.userKey);

      // Lấy thông tin người dùng từ token đã lưu
      final user = json.decode(userData ?? '{}');
      final String createdBy = user['id'] ?? '';

      final response = await http.post(
        Uri.parse(
            '${AppConstants.baseUrl}/api/vaccination-management/add-livestock-vacination-to-vacination-batch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "livestockId": livestockId,
          "batchVaccinationId": batchVaccinationId,
          "createdBy": createdBy,
        }),
      );

      final responseData = json.decode(response.body);
      return responseData;
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(AppConstants.networkError);
      }
      throw Exception(AppConstants.serverError);
    }
  }

  // Phương thức xác nhận tiêm vật nuôi bằng mã thẻ tai và loài
  Future<Map<String, dynamic>> confirmVaccinationByInspectionCode(
      String inspectionCode, int specieType, String batchVaccinationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final userData = prefs.getString(AppConstants.userKey);

      // Lấy thông tin người dùng từ token đã lưu
      final user = json.decode(userData ?? '{}');
      final String createdBy = user['id'] ?? '';

      final response = await http.post(
        Uri.parse(
            '${AppConstants.baseUrl}/api/vaccination-management/add-livestock-vacination-to-vacination-batch-by-inspection-code'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "inspectionCoded": inspectionCode,
          "specie_Type": specieType,
          "batchVaccinationId": batchVaccinationId,
          "createdBy": createdBy,
        }),
      );

      final responseData = json.decode(response.body);
      return responseData;
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(AppConstants.networkError);
      }
      throw Exception(AppConstants.serverError);
    }
  }
}
