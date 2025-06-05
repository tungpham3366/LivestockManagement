import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/auth_model.dart';
import '../widgets/error_dialog.dart';
import '../constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(AppConstants.rememberMeKey) ?? false;

    if (rememberMe) {
      final savedUsername = prefs.getString(AppConstants.usernameKey) ?? '';
      final savedPassword = prefs.getString(AppConstants.passwordKey) ?? '';

      setState(() {
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(AppConstants.rememberMeKey, _rememberMe);

    if (_rememberMe) {
      await prefs.setString(AppConstants.usernameKey, _usernameController.text);
      await prefs.setString(AppConstants.passwordKey, _passwordController.text);
    } else {
      // Xóa thông tin đăng nhập đã lưu nếu không chọn ghi nhớ
      await prefs.remove(AppConstants.usernameKey);
      await prefs.remove(AppConstants.passwordKey);
    }
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = LoginRequest(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      final response = await _authService.loginWithEmail(request);

      if (response.success && response.data != null) {
        // Lấy token từ response
        final token = response.data;

        // Lưu token vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token!);

        // Giải mã token để lấy thông tin người dùng
        Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

        // Lưu thông tin người dùng từ token
        Map<String, dynamic> userData = {
          'id': decodedToken['UserId'] ??
              decodedToken[
                  'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'],
          'username': decodedToken['name'],
          'email': decodedToken['email'],
          'phoneNumber': decodedToken['PhoneNumber'] ??
              decodedToken[
                  'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/mobilephone'],
          'role': decodedToken['PrimaryRole'],
          'roles': decodedToken['Role']
        };

        // Lưu thông tin người dùng vào SharedPreferences
        await prefs.setString(AppConstants.userKey, jsonEncode(userData));

        // Lưu thông tin đăng nhập nếu chọn ghi nhớ
        await _saveCredentials();

        if (mounted) {
          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message)),
          );

          // Chuyển hướng đến trang chính
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(
              message: response.message,
              onRetry: _loginWithEmail,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              ErrorDialog(message: e.toString(), onRetry: _loginWithEmail),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final response = await _authService.loginWithGoogle();

      if (response.success && response.data != null) {
        // Lấy token từ response
        final token = response.data;

        // Lưu token vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token!);

        // Giải mã token để lấy thông tin người dùng
        Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

        // Lưu thông tin người dùng từ token
        Map<String, dynamic> userData = {
          'id': decodedToken['UserId'] ??
              decodedToken[
                  'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'],
          'username': decodedToken['name'],
          'email': decodedToken['email'],
          'phoneNumber': decodedToken['PhoneNumber'] ??
              decodedToken[
                  'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/mobilephone'],
          'role': decodedToken['PrimaryRole'],
          'roles': decodedToken['Role']
        };

        // Lưu thông tin người dùng vào SharedPreferences
        await prefs.setString(AppConstants.userKey, jsonEncode(userData));

        if (mounted) {
          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message)),
          );

          // Chuyển hướng đến trang chính
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(
              message: response.message,
              onRetry: _loginWithGoogle,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              ErrorDialog(message: e.toString(), onRetry: _loginWithGoogle),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Hãy xác thực tài khoản của bạn',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Tên đăng nhập',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên đăng nhập';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppConstants.passwordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                      ),
                      const Text('Ghi nhớ mật khẩu'),
                      Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Đăng nhập',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('hoặc tiếp tục với'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _loginWithGoogle,
                      child: const Text('Google'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
