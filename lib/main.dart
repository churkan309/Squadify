import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'pages/login_page.dart';
import 'pages/main_navigation_page.dart';
import 'providers/party_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PartyProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Squadify',
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        scaffoldBackgroundColor: const Color.fromARGB(235, 10, 15, 13),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 231, 230, 231),
        ),
        fontFamily: 'Customfont',
      ),
      routes: {
        '/home': (context) => const MainNavigationPage(),
        '/login': (context) => const LoginPage(),
      },
      home: const StartupPage(),
    );
  }
}

// ตรวจสอบสถานะการล็อกอินตอนเปิดแอพ แล้วพาไปหน้าที่ถูกต้อง
class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    const secureStorage = FlutterSecureStorage();
    final isLoggedIn = await secureStorage.read(key: 'isLoggedIn') == 'true';
    if (!mounted) return;
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _isLoggedIn! ? const MainNavigationPage() : const LoginPage();
  }
}
