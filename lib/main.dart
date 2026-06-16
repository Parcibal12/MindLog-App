import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/journal/presentation/screens/main_layout_screen.dart';
void main() {
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
      home: const MainLayoutScreen(),
    );
  }
}