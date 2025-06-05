import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/livestock_summary_model.dart';

class LivestockSummaryService {
  Future<LivestockSummaryModel?> fetchSummary(String livestockId) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/livestock-management/get-summary-info/$livestockId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return LivestockSummaryModel.fromJson(data['data']);
      }
    }
    return null;
  }
}
