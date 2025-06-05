class AppConstants {
  // API URLs
  static const String baseUrl = 'https://lms.autopass.blog';

  // API Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String googleLoginEndpoint = '/api/auth/google-login';
  static const String getLivestockSummaryEndpoint =
      '/api/livestock-management/get-summary-info';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String rememberMeKey = 'remember_me';
  static const String usernameKey = 'saved_username';
  static const String passwordKey = 'saved_password';

  // Error Messages
  static const String networkError =
      'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet của bạn.';
  static const String serverError =
      'Đã xảy ra lỗi từ máy chủ. Vui lòng thử lại sau.';
  static const String invalidCredentials =
      'Email hoặc mật khẩu không chính xác.';

  // Validation Messages
  static const String emailRequired = 'Vui lòng nhập email';
  static const String passwordRequired = 'Vui lòng nhập mật khẩu';
  static const String invalidEmail = 'Email không hợp lệ';
  static const String passwordTooShort = 'Mật khẩu phải có ít nhất 6 ký tự';
}
