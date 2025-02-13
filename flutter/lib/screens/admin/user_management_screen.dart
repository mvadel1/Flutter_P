import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../widgets/custom_text_field.dart';
import '../../config/color_scheme.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      adminProvider.fetchAllUsers(token).then((_) {
        setState(() {
          _filteredUsers = adminProvider.allUsers;
        });
      });
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = adminProvider.allUsers.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.phoneNumber.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _updateUserRole(UserModel user, String newRole) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Role Change'),
        content: Text('Change role of ${user.name} to $newRole?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm')),
        ],
      ),
    );
    if (confirm != true) return;

    await adminProvider.updateUserRole(token, int.parse(user.id), newRole);
    if (adminProvider.errorMessage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('User role updated successfully')));
      adminProvider.fetchAllUsers(token).then((_) {
        setState(() {
          _filteredUsers = adminProvider.allUsers;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(adminProvider.errorMessage ?? 'Error updating role')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final authProvider = context.watch<AuthProvider>();
    final token = authProvider.token;
    if (token == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in as admin')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.primary,
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminProvider.errorMessage != null
          ? Center(child: Text('Error: ${adminProvider.errorMessage}'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: _searchController,
              label: 'Search Users by Name or Phone',
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredUsers.isEmpty
                  ? const Center(child: Text('No users found.'))
                  : ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (ctx, index) {
                  final UserModel user = _filteredUsers[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Phone: ${user.phoneNumber}'),
                      trailing: DropdownButton<String>(
                        value: user.role,
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (newRole) {
                          if (newRole != null && newRole != user.role) {
                            _updateUserRole(user, newRole);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
