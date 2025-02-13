import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../config/color_scheme.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _authService.getProfile(token);
      if (result['statusCode'] == 200) {
        setState(() {
          _profileData = result['body'];
        });
      } else {
        setState(() {
          _error = result['body']['message'] ?? 'Error fetching profile';
        });
      }
    } catch (_) {
      setState(() {
        _error = 'An unexpected error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleLogout() {
    context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Widget _buildProfileRow({required IconData icon, required String label, required String value, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16, color: valueColor ?? Colors.black))),
        ],
      ),
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final token = context.watch<AuthProvider>().token;
    if (token == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), backgroundColor: AppColors.primary),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16)))
          : _profileData == null
          ? const Center(child: Text('No profile data'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.background.withOpacity(0.1),
                    child: const Icon(Icons.person, size: 50, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 24),
                _buildProfileRow(
                  icon: Icons.person,
                  label: 'Name:',
                  value: _profileData!['name'] ?? 'N/A',
                ),
                _buildProfileRow(
                  icon: Icons.phone,
                  label: 'Phone:',
                  value: _profileData!['phone_number'] ?? 'N/A',
                ),
                _buildProfileRow(
                  icon: Icons.badge,
                  label: 'Role:',
                  value: _profileData!['role'] != null ? _capitalize(_profileData!['role']) : 'N/A',
                ),
                _buildProfileRow(
                  icon: Icons.verified,
                  label: 'Status:',
                  value: _profileData!['is_verified'] == true ? 'Verified' : 'Not Verified',
                  valueColor: _profileData!['is_verified'] == true ? AppColors.success : AppColors.danger,
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: AppColors.danger,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
