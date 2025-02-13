import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  ApiService({required this.baseUrl});


  Future<dynamic> getRequest(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(
      url,
      headers: _buildHeaders(token),
    );
    return _processResponse(response);
  }

  Future<dynamic> postRequest(String endpoint, Map<String, dynamic> body, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: _buildHeaders(token),
      body: json.encode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> putRequest(String endpoint, Map<String, dynamic> body, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(
      url,
      headers: _buildHeaders(token),
      body: json.encode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> deleteRequest(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(
      url,
      headers: _buildHeaders(token),
    );
    return _processResponse(response);
  }

  Map<String, String> _buildHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final data = json.decode(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        statusCode: statusCode,
        message: data['message'] ?? 'Unknown error',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $statusCode => $message';
}
