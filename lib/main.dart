import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/screens/home_screen.dart';

void main() {
  // ProviderScope es OBLIGATORIO para que Riverpod funcione en toda la app
  runApp(const ProviderScope(child: MindLogApp()));
}

class MindLogApp extends StatelessWidget {
  const MindLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14B8A6)),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const HomeScreen(),
    );
  }
}