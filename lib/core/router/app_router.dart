import 'package:go_router/go_router.dart';
import '../../features/auth/auth.dart';
import '../../features/journal/journal.dart';
import '../../features/profile/profile.dart';

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
    GoRoute(
      path: '/labeled',
      name: 'labeled',
      builder: (context, state) => const LabeledScreen(),
    ),
    GoRoute(
      path: '/calendar',
      name: 'calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/catalog',
      name: 'catalog',
      builder: (context, state) => const WidgetCatalogScreen(),
    ),
  ],
);