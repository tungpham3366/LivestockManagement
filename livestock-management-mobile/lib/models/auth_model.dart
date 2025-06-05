class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class AuthResponse {
  final int statusCode;
  final bool success;
  final String? data;
  final dynamic errors;
  final String message;

  AuthResponse({
    required this.statusCode,
    required this.success,
    this.data,
    this.errors,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      data: json['data'],
      errors: json['errors'],
      message: json['message'],
    );
  }
}

class User {
  final String id;
  final String email;
  final String name;

  User({required this.id, required this.email, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], email: json['email'], name: json['name']);
  }
}
