import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ApiService {
  Future<http.Response> fetchDevices() async {
    return http.get(Uri.parse('${AppConstants.apiBaseUrl}/devices'));
  }
}