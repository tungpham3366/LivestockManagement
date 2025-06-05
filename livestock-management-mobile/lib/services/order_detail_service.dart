import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class OrderDetailService {
  Future<Map<String, dynamic>?> fetchOrderDetail(String orderId) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/order-management/get-order-details-info/$orderId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      return null;
    }
  }
}
