import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/journal/presentation/screens/main_layout_screen.dart';
import '../../features/journal/presentation/screens/editor_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainLayoutScreen(),
    ),

    GoRoute(
      path: '/write',
      name: 'write',
      builder: (context, state) => const EditorScreen(),
    ),
  ],
);