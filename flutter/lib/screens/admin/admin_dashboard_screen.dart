import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  void _handleLogout(BuildContext context) {
    context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final List<_DashboardItem> items = [
      _DashboardItem(
        title: 'Manage Books',
        icon: Icons.book,
        color: Colors.indigo,
        route: '/admin-books',
      ),
      _DashboardItem(
        title: 'Manage Orders',
        icon: Icons.shopping_cart,
        color: Colors.teal,
        route: '/admin-orders',
      ),
      _DashboardItem(
        title: 'Manage Users',
        icon: Icons.people,
        color: Colors.amber,
        route: '/admin-users',
      ),
      _DashboardItem(
        title: 'View Analytics',
        icon: Icons.bar_chart,
        color: Colors.deepPurple,
        route: '/admin-analytics',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = items[index];
            return _DashboardCard(item: item);
          },
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  _DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _DashboardCard extends StatelessWidget {
  final _DashboardItem item;
  const _DashboardCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, item.route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              item.color.withOpacity(0.3),
              item.color.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: item.color.withOpacity(0.2),
              child: Icon(item.icon, size: 30, color: item.color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
