//lib/router/app_router.dart
import 'package:go_router/go_router.dart';

import '../screens/welcome_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/conversation/conversation_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/minigames/minigames_screen.dart';
import '../screens/minigames/gato_screen.dart';
import '../screens/game/question_screen.dart';
import '../screens/game/capsule_screen.dart';
import '../widgets/app_shell.dart';
import '../screens/minigames/verdad_estrategica_screen.dart';
import '../screens/minigames/verdad_o_reto_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),

    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/capsules',
          builder: (context, state) => const ConversationScreen(),
        ),
        GoRoute(
          path: '/minigames',
          builder: (context, state) => const MinigamesScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // Flujo de conversación (sin bottom nav)
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

    // Minijuegos (sin bottom nav) 👈 nuevo
    GoRoute(path: '/gato', builder: (context, state) => const GatoScreen()),
    // En app_router.dart
    GoRoute(
      path: '/verdad-estrategica',
      builder: (context, state) => const VerdadEstrategicaScreen(),
    ),
    GoRoute(
      path: '/verdad-reto',
      builder: (context, state) => const VerdadORetoScreen(),
    ),
  ],
);
