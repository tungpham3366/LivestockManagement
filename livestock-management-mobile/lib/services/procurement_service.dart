import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/procurement_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProcurementService {
  Future<ProcurementResponse> getProcurementList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      final response = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/api/vaccination-management/get-list-procurement-require-vaccination'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final parsedResponse = jsonDecode(response.body);
      return ProcurementResponse.fromJson(parsedResponse);
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(AppConstants.networkError);
      }
      throw Exception(AppConstants.serverError);
    }
  }

  Future<ProcurementDetailResponse> getProcurementDetail(
      String procurementId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      final response = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/api/vaccination-management/get-procurement-require-vaccination/$procurementId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final parsedResponse = jsonDecode(response.body);
      return ProcurementDetailResponse.fromJson(parsedResponse);
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(AppConstants.networkError);
      }
      throw Exception(AppConstants.serverError);
    }
  }
}
