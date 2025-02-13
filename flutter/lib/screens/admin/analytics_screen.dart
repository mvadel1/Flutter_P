import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/color_scheme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      adminProvider.fetchAnalytics(token);
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        title: const Text('Analytics'),
        backgroundColor: AppColors.primary,
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminProvider.errorMessage != null
          ? Center(child: Text('Error: ${adminProvider.errorMessage}'))
          : adminProvider.analytics == null
          ? const Center(child: Text('No analytics data'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatCard(
              title: 'Total Users',
              value: '${adminProvider.analytics!['total_users']}',
              icon: Icons.people,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: 'Total Books',
              value: '${adminProvider.analytics!['total_books']}',
              icon: Icons.book,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: 'Total Orders',
              value: '${adminProvider.analytics!['total_orders']}',
              icon: Icons.shopping_cart,
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: 'Total Revenue',
              value: '\$0.00', // Placeholder value
              icon: Icons.attach_money,
              color: AppColors.warning,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: 'Benefits',
              value: '\$0.00', // Placeholder value
              icon: Icons.trending_up,
              color: AppColors.danger,
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Chart Placeholder',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
