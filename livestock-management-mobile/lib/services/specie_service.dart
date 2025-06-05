import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/specie_model.dart';
import '../constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpecieService {
  Future<SpecieResponse> getAllSpecies() async {
    try {
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

      final responseData = json.decode(response.body);
      return SpecieResponse.fromJson(responseData);
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(AppConstants.networkError);
      }
      throw Exception(AppConstants.serverError);
    }
  }
}
