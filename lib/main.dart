import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/landing/landing_page.dart';
import 'features/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Other's Trash My Treasure",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5DB075),
          primary: const Color(0xFF5DB075),
        ),
        useMaterial3: true,
      ),
      home: isFirstTime ? const LandingPage() : const LoginPage(),
    );
  }
}
