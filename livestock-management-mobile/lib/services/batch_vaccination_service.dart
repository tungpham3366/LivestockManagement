import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/batch_vaccination_model.dart';

class BatchVaccinationService {
  Future<List<BatchVaccination>> getBatchVaccinations(
      {int skip = 0, int take = 10, String? fromDate, String? toDate}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final queryParams = {
      'skip': skip.toString(),
      'take': take.toString(),
      if (fromDate != null) 'fromDate': fromDate,
      if (toDate != null) 'toDate': toDate,
    };
    final uri = Uri.parse(
            '${AppConstants.baseUrl}/api/vaccination-management/get-batch-vaccinations-list')
        .replace(queryParameters: queryParams);
    final response =
        await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['data']['items'] as List;
      return items.map((e) => BatchVaccination.fromJson(e)).toList();
    } else {
      throw Exception('Không lấy được danh sách lô tiêm');
    }
  }
}
