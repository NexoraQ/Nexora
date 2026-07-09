import 'package:flutter/material.dart';
import 'session.dart';
import 'screens/login.dart';
import 'screens/rooms.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Session().load();
  runApp(const NexoraApp());
}

class NexoraApp extends StatelessWidget {
  const NexoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    const grad = LinearGradient(
      colors: [Color(0xFF5b8def), Color(0xFF7c5cff)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return MaterialApp(
      title: 'Nexora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7c5cff),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          flexibleSpace: DecoratedBox(
            decoration: BoxDecoration(gradient: grad),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF7c5cff),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
      home: Session().isAuth ? const RoomsScreen() : const LoginScreen(),
    );
  }
}
