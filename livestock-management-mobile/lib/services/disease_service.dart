import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/disease_model.dart';

class DiseaseService {
  Future<List<Disease>> getDiseases() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final response = await http.get(
      Uri.parse(
          '${AppConstants.baseUrl}/api/disease-management/get-list-diseases'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['data']['items'] as List;
      return items.map((e) => Disease.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load diseases');
    }
  }

  Future<List<Medicine>> getMedicinesByDisease(String diseaseId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final response = await http.get(
      Uri.parse(
          '${AppConstants.baseUrl}/api/medicine-management/get-list-medicine-by-disease/$diseaseId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['data'] as List;
      return items.map((e) => Medicine.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load medicines');
    }
  }
}
