//lib/screens/minigames/minigames_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MinigamesScreen extends StatelessWidget {
  const MinigamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              const Text(
                'MINI GAMES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD94F5C),
                  letterSpacing: 1.4,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Juega y conecta.',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Tres juegos diseñados para conocerse de verdad.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9E8A8A),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              Expanded(
                child: ListView(
                  children: [
                    _GameCard(
                      number: '01',
                      title: 'Verdad Estratégica',
                      description:
                          'Juego psicológico de lectura y confianza. ¿Puedes distinguir la verdad de la mentira?',
                      icon: Icons.psychology_rounded,
                      accentColor: const Color(0xFFD94F5C),
                      bgColor: const Color(0xFFFFE4E6),
                      // En minigames_screen.dart
                      onTap: () => context.go('/verdad-estrategica'),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      number: '02',
                      title: 'Verdad o Reto',
                      description:
                          'Con niveles de intensidad que escalan solos. Del ligero al vulnerable.',
                      icon: Icons.local_fire_department_rounded,
                      accentColor: const Color(0xFFE07B3A),
                      bgColor: const Color(0xFFFFEDD5),
                      onTap: () => context.go(
                        '/verdad-reto',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      number: '03',
                      title: 'Gato con Castigo',
                      description:
                          'El clásico 3×3 con un giro. Perder tiene consecuencias interesantes.',
                      icon: Icons.grid_3x3_rounded,
                      accentColor: const Color(0xFFAB5FD4),
                      bgColor: const Color(0xFFF3E8FF),
                      // En minigames_screen.dart
                      onTap: () => context.go('/gato'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    required this.onTap,
  });

  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
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
            Icon(
              Icons.chevron_right_rounded,
              color: accentColor.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
