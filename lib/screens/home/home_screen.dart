//lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../game/question_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5EF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Welcome back label
                    const Center(
                      child: Text(
                        'WELCOME BACK',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD94F5C),
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Title
                    const Text(
                      'What are you looking for?',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A1A),
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Subtitle
                    const Text(
                      'Select your experience to begin. You can change this later in settings.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9E8A8A),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Mode cards
                    _ModeCard(
                      title: 'Modo Pareja',
                      description: 'Nurture and grow your current relationship',
                      iconColor: const Color(0xFFFFE4E6),
                      icon: Icons.favorite_rounded,
                      iconTint: const Color(0xFFD94F5C),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QuestionScreen(mode: 'pareja'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ModeCard(
                      title: 'Modo Amigos',
                      description:
                          'Meet people with similar interests and hobbies',
                      iconColor: const Color(0xFFFFEDD5),
                      icon: Icons.group_rounded,
                      iconTint: const Color(0xFFE07B3A),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QuestionScreen(mode: 'amigos'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ModeCard(
                      title: 'Modo Citas',
                      description:
                          'Discover new romantic possibilities and chemistry',
                      iconColor: const Color(0xFFF3E8FF),
                      icon: Icons.auto_awesome_rounded,
                      iconTint: const Color(0xFFAB5FD4),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QuestionScreen(mode: 'citas'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ModeCard(
                      title: 'Modo Picante',
                      description:
                          'Sube la temperatura con preguntas más atrevidas',
                      iconColor: const Color(0xFFFFEDD5),
                      icon: Icons.local_fire_department_rounded,
                      iconTint: const Color(0xFFE05C2A),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QuestionScreen(mode: 'picante'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top Bar
// ---------------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button — usa el context local del build que sí tiene Navigator
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD94F5C).withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),

          // Center dot indicator
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: Color(0xFFD94F5C),
              shape: BoxShape.circle,
            ),
          ),

          // Help button
          _CircleButton(icon: Icons.help_outline_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD94F5C).withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mode Card
// ---------------------------------------------------------------------------
class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.description,
    required this.iconColor,
    required this.icon,
    required this.iconTint,
    required this.onTap,
  });

  final String title;
  final String description;
  final Color iconColor;
  final IconData icon;
  final Color iconTint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD94F5C).withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconTint, size: 28),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9E8A8A),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Arrow
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCCBBBB),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}