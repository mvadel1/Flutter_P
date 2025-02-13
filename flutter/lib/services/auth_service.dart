import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user.dart';

class AuthService {
  static const String BASE_URL = 'http://10.0.2.2:5000/api/auth';


  Future<Map<String, dynamic>> register({
    required String name,
    required String phoneNumber,
    required String password,
    required String lang,
    String? email,
  }) async {
    final url = Uri.parse('$BASE_URL/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'phone_number': phoneNumber,
        'password': password,
        'lang': lang,
        'email': email,
      }),
    );

    final data = json.decode(response.body);
    return {
      'statusCode': response.statusCode,
      'body': data,
    };
  }


  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    final url = Uri.parse('$BASE_URL/verify');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone_number': phoneNumber,
        'code': code,
      }),
    );
    final data = json.decode(response.body);
    return {
      'statusCode': response.statusCode,
      'body': data,
    };
  }


  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    final url = Uri.parse('$BASE_URL/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone_number': phoneNumber,
        'password': password,
      }),
    );
    final data = json.decode(response.body);
    return {
      'statusCode': response.statusCode,
      'body': data,
    };
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String phoneNumber,
    required String lang,
  }) async {
    final url = Uri.parse('$BASE_URL/forgot_password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone_number': phoneNumber,
        'lang': lang,
      }),
    );
    final data = json.decode(response.body);
    return {
      'statusCode': response.statusCode,
      'body': data,
    };
  }


  Future<Map<String, dynamic>> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    final url = Uri.parse('$BASE_URL/reset_password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone_number': phoneNumber,
        'code': code,
        'new_password': newPassword,
      }),
    );
    final data = json.decode(response.body);
    return {
      'statusCode': response.statusCode,
      'body': data,
    };
  }


  Future<Map<String, dynamic>> getProfile(String token) async {
    final url = Uri.parse('$BASE_URL/profile');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final data = json.decode(response.body);
    return {
      'statusCode': response.statusCode,
      'body': data,
    };
  }


  Future<Map<String, dynamic>> forgotPasswordEmail(String email) async {
    final url = Uri.parse('$BASE_URL/forgot_password_email');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
    final data = json.decode(response.body);
    return {
      'statusCode': response.statusCode,
      'body': data,
    };
  }


  Future<Map<String, dynamic>> checkResetToken(String token) async {
    final url = Uri.parse('$BASE_URL/check_reset_token/$token');
    final response = await http.get(url, headers: {'Content-Type': 'application/json'});
    final data = json.decode(response.body);
    return {
      'statusCode': response.statusCode,
      'body': data,
    };
  }



  Future<Map<String, dynamic>> confirmResetEmail(String token, String newPassword) async {
    final url = Uri.parse('$BASE_URL/confirm_reset_email');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'token': token,
        'new_password': newPassword,
      }),
    );
    final data = json.decode(response.body);
    return {
      'statusCode': response.statusCode,
      'body': data,
    };
  }
}
