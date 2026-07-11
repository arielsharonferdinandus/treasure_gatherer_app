import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/item_provider.dart';
import 'data/services/notification_service.dart';

import 'features/landing/landing_page.dart';
import 'features/auth/login_page.dart';
import 'features/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.loadInitialState();

  await NotificationService().init();

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ItemProvider>(create: (_) => ItemProvider()),
      ],
      child: MaterialApp(
        title: "Other's Trash My Treasure",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5DB075),
            primary: const Color(0xFF5DB075),
          ),
          useMaterial3: true,
        ),
        home: _resolveStartPage(authProvider),
      ),
    );
  }

  Widget _resolveStartPage(AuthProvider auth) {
    if (auth.isFirstTime) return const LandingPage();
    if (auth.isLoggedIn) return const HomePage();
    return const LoginPage();
  }
}