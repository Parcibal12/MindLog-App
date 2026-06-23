import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindlog_design_system/mindlog_design_system.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('privacyVault');
  await Hive.openBox<String>('offline_journals');

  runApp(const ProviderScope(child: MindLogApp()));
}

class MindLogApp extends ConsumerWidget {
  const MindLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'MindLog v2.0',
      debugShowCheckedModeBanner: false,

      theme: MindLogTheme.lightTheme,
      darkTheme: MindLogTheme.darkTheme,
      themeMode: themeMode,

      routerConfig: appRouter,
    );
  }
}
