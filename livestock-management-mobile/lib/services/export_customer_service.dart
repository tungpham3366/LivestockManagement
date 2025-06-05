import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/export_customer_model.dart';

class ExportCustomerService {
  Future<List<ExportCustomerModel>> fetchCustomers({
    required String procurementId,
    String? keyword,
    String? fromDate,
    String? toDate,
    String? status,
    int skip = 0,
    int take = 20,
  }) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/export-management/get-list-customers/$procurementId');
    final body = {
      'keyword': keyword ?? '',
      'fromDate': fromDate,
      'toDate': toDate,
      'status': status ?? '',
      'skip': skip,
      'take': take,
    };
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true &&
          data['data'] != null &&
          data['data']['items'] != null) {
        return (data['data']['items'] as List)
            .map((e) => ExportCustomerModel.fromJson(e))
            .toList();
      }
    }
    return [];
  }
}
