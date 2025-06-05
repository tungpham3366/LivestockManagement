import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/procurement_general_info_model.dart';

class ProcurementGeneralInfoService {
  Future<ProcurementGeneralInfoModel?> fetchGeneralInfo(String id) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/procurement-management/general-info/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return ProcurementGeneralInfoModel.fromJson(data['data']);
      }
    }
    return null;
  }
}
