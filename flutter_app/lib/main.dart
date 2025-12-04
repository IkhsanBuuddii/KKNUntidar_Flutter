import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/activity_log_screen.dart';
import 'screens/activity_detail_screen.dart';
import 'screens/announcement_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/report_screen.dart';
import 'screens/location_screen.dart';
import 'screens/debug_screen.dart';

void main() {
  runApp(const KknApp());
}

class KknApp extends StatelessWidget {
  const KknApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KKN Untidar',
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (ctx) => const LoginScreen(),
        '/home': (ctx) => const HomeScreen(),
        '/register': (ctx) => const RegisterScreen(),
        '/profile': (ctx) => const ProfileScreen(),
        '/edit_profile': (ctx) => const EditProfileScreen(),
        '/change_password': (ctx) => const ChangePasswordScreen(),
        '/activities': (ctx) => const ActivityLogScreen(),
        '/activity_detail': (ctx) => const ActivityDetailScreen(),
        '/announcements': (ctx) => const AnnouncementScreen(),
        '/settings': (ctx) => const SettingsScreen(),
        '/report': (ctx) => const ReportScreen(),
        '/location': (ctx) => const LocationScreen(),
        '/debug': (ctx) => const DebugScreen(),
      },
    );
  }
}
