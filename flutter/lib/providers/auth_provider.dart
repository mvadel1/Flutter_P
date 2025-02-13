import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../config/env.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _token;
  String? get token => _token;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _emailResetToken;
  String? get emailResetToken => _emailResetToken;

  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }


  Future<bool> register({
    required String name,
    required String phoneNumber,
    required String password,
    required String lang,
    String? email,
  }) async {
    _startLoading();
    final result = await _authService.register(
      name: name,
      phoneNumber: phoneNumber,
      password: password,
      lang: lang,
      email: email,
    );
    _stopLoading();

    if (result['statusCode'] == 201) {
      return true;
    } else {
      _errorMessage = result['body']['message'] ?? 'Registration failed';
      return false;
    }
  }


  Future<bool> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    _startLoading();
    final result = await _authService.verifyOtp(
      phoneNumber: phoneNumber,
      code: code,
    );
    _stopLoading();

    if (result['statusCode'] == 200) {
      return true;
    } else {
      _errorMessage = result['body']['message'] ?? 'OTP verification failed';
      return false;
    }
  }


  Future<bool> login({
    required String phoneNumber,
    required String password,
  }) async {
    _startLoading();
    final result = await _authService.login(
      phoneNumber: phoneNumber,
      password: password,
    );
    _stopLoading();

    if (result['statusCode'] == 200) {
      final body = result['body'];


      _token = body['access_token'];
      final role = body['role'] ?? 'user';

      final profileResult = await _authService.getProfile(_token!);
      if (profileResult['statusCode'] == 200) {
        final profileData = profileResult['body'];
        _currentUser = UserModel.fromJson(profileData);
      } else {
        _errorMessage = profileResult['body']['message'] ?? 'Failed to load user profile';
        return false;
      }

      notifyListeners();
      return true;
    } else {
      _errorMessage = result['body']['message'] ?? 'Login failed';
      return false;
    }
  }


  Future<bool> forgotPassword({
    required String phoneNumber,
    required String lang,
  }) async {
    _startLoading();
    final result = await _authService.forgotPassword(
      phoneNumber: phoneNumber,
      lang: lang,
    );
    _stopLoading();

    if (result['statusCode'] == 200) {
      return true;
    } else {
      _errorMessage = result['body']['message'] ?? 'Error sending reset SMS';
      return false;
    }
  }


  Future<bool> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    _startLoading();
    final result = await _authService.resetPassword(
      phoneNumber: phoneNumber,
      code: code,
      newPassword: newPassword,
    );
    _stopLoading();

    if (result['statusCode'] == 200) {
      return true;
    } else {
      _errorMessage = result['body']['message'] ?? 'Reset password failed';
      return false;
    }
  }


  Future<bool> forgotPasswordEmail(String email) async {
    _startLoading();
    final result = await _authService.forgotPasswordEmail(email);
    _stopLoading();

    if (result['statusCode'] == 200) {
      _emailResetToken = result['body']['token'];
      return true;
    } else {
      _errorMessage = result['body']['message'] ?? 'Error sending reset email';
      return false;
    }
  }


  Future<bool> checkResetToken(String token) async {
    _startLoading();
    final result = await _authService.checkResetToken(token);
    _stopLoading();

    if (result['statusCode'] == 200) {
      return true;
    } else {
      _errorMessage = result['body']['message'] ?? 'Token check failed';
      return false;
    }
  }


  Future<bool> confirmResetEmail({
    required String token,
    required String newPassword,
  }) async {
    _startLoading();
    final result = await _authService.confirmResetEmail(token, newPassword);
    _stopLoading();

    if (result['statusCode'] == 200) {
      return true;
    } else {
      _errorMessage = result['body']['message'] ?? 'Error updating password';
      return false;
    }
  }


  void logout() {
    _token = null;
    _currentUser = null;
    _emailResetToken = null;
    notifyListeners();
  }
}
