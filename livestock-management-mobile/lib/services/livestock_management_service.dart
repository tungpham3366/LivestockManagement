import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class LivestockManagementService {
  Future<String?> getLivestockIdByInspectionCodeAndType(
      String inspectionCode, int specieType) async {
    final url = AppConstants.baseUrl +
        '/api/livestock-management/get-livestockId-by-inspectioncode-and-type';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'inspectionCode': inspectionCode,
        'specieType': specieType,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true &&
          data['data'] != null &&
          data['data']['id'] != null) {
        return data['data']['id'] as String;
      }
    }
    return null;
  }
}
