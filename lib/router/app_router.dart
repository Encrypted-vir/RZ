//lib/router/app_router.dart
import 'package:go_router/go_router.dart';

import '../screens/welcome_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/conversation/conversation_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/game/question_screen.dart';
import '../screens/game/capsule_screen.dart';
import '../widgets/app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Welcome ──────────────────────────────────────────────────────────────
    GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),

    // ── Shell con bottom nav (tabs) ──────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/capsules',
          builder: (context, state) => const ConversationScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),

    // ── Flujo de juego (sin bottom nav) ──────────────────────────────────────
    GoRoute(
      path: '/game/:mode',
      builder: (context, state) {
        final mode = state.pathParameters['mode']!;
        return QuestionScreen(mode: mode);
      },
      routes: [
        GoRoute(
          path: 'capsule',
          builder: (context, state) {
            final mode = state.pathParameters['mode']!;
            return CapsuleScreen(mode: mode);
          },
        ),
      ],
    ),
  ],
);
