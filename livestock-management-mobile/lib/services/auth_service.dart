import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  Future<AuthResponse> loginWithEmail(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      final parsedResponse = jsonDecode(response.body);
      return AuthResponse.fromJson(parsedResponse);
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(AppConstants.networkError);
      }
      throw Exception(AppConstants.serverError);
    }
  }

  Future<AuthResponse> loginWithGoogle() async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.googleLoginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
      );

      final parsedResponse = jsonDecode(response.body);
      return AuthResponse.fromJson(parsedResponse);
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(AppConstants.networkError);
      }
      throw Exception(AppConstants.serverError);
    }
  }
}
