class ApiConfig {
  static const String baseUrl = 'http://localhost:8080'; // Replace with your actual backend URL
  
  // You can add different URLs for different environments
  static const String devUrl = 'http://localhost:8080';
  static const String prodUrl = 'https://your-production-api.com';
  
  // Other API configuration
  static const Duration timeout = Duration(seconds: 30);
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
