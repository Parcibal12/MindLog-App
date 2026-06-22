import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'features/journal/presentation/screens/main_layout_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  await Hive.initFlutter();  
  await Hive.openBox('privacyVault');

  runApp(const ProviderScope(child: MindLogApp()));
}

class MindLogApp extends StatelessWidget {
  const MindLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MindLog v2.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}