import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../config/color_scheme.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordEmailScreen> createState() => _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final _emailController = TextEditingController();
  final _newPassController = TextEditingController();

  String? _token;
  bool _linkSent = false;
  bool _linkClicked = false;
  Timer? _pollTimer;

  @override
  void dispose() {
    _pollTimer?.cancel();
    _emailController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.forgotPasswordEmail(_emailController.text.trim());
    if (success) {
      setState(() {
        _linkSent = true;
        _token = authProvider.emailResetToken;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset link sent. Check your email.')),
      );
      _startPollingTokenValidation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Error sending reset link')),
      );
    }
  }

  void _startPollingTokenValidation() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_linkClicked || _token == null) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isValid = await authProvider.checkResetToken(_token!);

      if (isValid) {
        setState(() {
          _linkClicked = true;
        });
        _pollTimer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link verified! You can set new password now.')),
        );
      }
    });
  }

  Future<void> _handleConfirmNewPassword() async {

    if (_token == null || !_linkClicked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait until link is validated.')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.confirmResetEmail(
      token: _token!,
      newPassword: _newPassController.text.trim(),
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully!')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Error updating password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();


    Widget content;
    if (!_linkSent) {
      content = Column(
        children: [
          CustomTextField(
            controller: _emailController,
            label: 'Email Address',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleSendResetLink,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: authProvider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Send Reset Link'),
          ),
        ],
      );
    } else if (!_linkClicked) {
      // Step B: waiting for link click
      content = Column(
        children: [
          const Text(
            'A reset link was sent to your email.\nPlease click the link on your PC to continue.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text('Waiting for the link to be clicked...'),
          const SizedBox(height: 16),
          // Optional: Manual "Check Link" button if you want user to click manually
          ElevatedButton(
            onPressed: () => _startPollingTokenValidation(),
            child: const Text('Check Link Manually'),
          ),
        ],
      );
    } else {
      content = Column(
        children: [
          const Text(
            'Link verified! Enter your new password below:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _newPassController,
            label: 'New Password',
            prefixIcon: Icons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleConfirmNewPassword,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: authProvider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Update Password'),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password (Email)'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            child: content,
          ),
        ),
      ),
    );
  }
}
