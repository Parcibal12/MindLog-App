import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  await Hive.initFlutter();  
  await Hive.openBox('privacyVault');
  await Hive.initFlutter();
  await Hive.openBox('privacyVault');

  runApp(const ProviderScope(child: MindLogApp()));

  await Hive.openBox<String>('offline_journals');
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