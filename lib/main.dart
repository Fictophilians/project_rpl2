import 'package:flutter/material.dart';
import 'package:project_rpl2/pages/LoginPage.dart';
import 'package:project_rpl2/pages/MenuPage.dart';
import 'package:project_rpl2/pages/Register.dart';
import 'package:project_rpl2/pages/StarterPage.dart';
import 'package:project_rpl2/service/api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameHaven',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF22D3EE),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/starter': (context) => const StarterPage(),
        '/login': (context) => const Loginpage(),
        '/register': (context) => const Registerpage(),
        '/menu': (context) => const Menupage(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<String?> _cekToken;

  @override
  void initState() {
    super.initState();
    _cekToken = Apiservice.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _cekToken,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
          return const Menupage();
        }

        return const StarterPage();
      },
    );
  }
}
