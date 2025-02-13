import 'package:flutter/material.dart';
import 'package:maktabati/screens/auth/forgot_password_choice_screen.dart';
import 'package:maktabati/screens/auth/forgot_password_email_screen.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/books_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/admin_provider.dart';

// Auth
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verify_otp_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

// User
import 'screens/user/home_screen.dart';
import 'screens/user/cart_screen.dart';
import 'screens/user/orders_screen.dart';
import 'screens/user/profile_screen.dart';

// Admin
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_books_screen.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/admin/user_management_screen.dart';
import 'screens/admin/analytics_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<BooksProvider>(create: (_) => BooksProvider()),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<OrdersProvider>(create: (_) => OrdersProvider()),
        ChangeNotifierProvider<AdminProvider>(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'El Maktaba',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        routes: {

          '/login': (ctx) => const LoginScreen(),
          '/register': (ctx) => const RegisterScreen(),
          '/verify': (ctx) => const VerifyOtpScreen(),
          // '/forgot': (ctx) => const ForgotPasswordScreen(),

          '/forgot-choice': (ctx) => const ForgotPasswordChoiceScreen(),
          '/forgot-sms': (ctx) => const ForgotPasswordScreen(),    // your existing screen
          '/forgot-email': (ctx) => const ForgotPasswordEmailScreen(),

          '/home': (ctx) => const HomeScreen(),
          '/cart': (ctx) => const CartScreen(),
          '/orders': (ctx) => const OrdersScreen(),
          '/profile': (ctx) => const ProfileScreen(),

          '/admin-dashboard': (ctx) => const AdminDashboardScreen(),
          '/admin-books': (ctx) => const AdminBooksScreen(),
          '/admin-orders': (ctx) => const AdminOrdersScreen(),
          '/admin-users': (ctx) => const UserManagementScreen(),
          '/admin-analytics': (ctx) => const AnalyticsScreen(),
        },
      ),
    );
  }
}
