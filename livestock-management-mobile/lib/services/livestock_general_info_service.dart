import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class LivestockGeneralInfoService {
  Future<String?> getLivestockIdByInspectionCodeAndSpecie(
      String inspectionCode, int specieIndex) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/livestock-management/get-general-info-of-livestock/$inspectionCode/$specieIndex');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true &&
          data['data'] != null &&
          data['data']['id'] != null) {
        return data['data']['id'];
      }
    }
    return null;
  }
}
