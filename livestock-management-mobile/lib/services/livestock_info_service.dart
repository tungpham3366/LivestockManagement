import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/livestock_info_model.dart';

class LivestockInfoService {
  Future<LivestockInfo> getLivestockInfo(
      {String? livestockId,
      String? inspectionCode,
      required int specieType}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final queryParams = <String, String>{
      if (livestockId != null) 'livestockId': livestockId,
      if (inspectionCode != null) 'inspectionCode': inspectionCode,
      'specieType': specieType.toString(),
    };
    final uri = Uri.parse(
            '${AppConstants.baseUrl}/api/vaccination-management/get-livestock-info')
        .replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return LivestockInfo.fromJson(data['data']);
    } else {
      throw Exception('Không lấy được thông tin vật nuôi');
    }
  }
}
