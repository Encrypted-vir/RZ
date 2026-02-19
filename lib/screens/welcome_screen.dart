//lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // Animación de entrada (fade + scale inicial)
  late AnimationController _entryController;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleRings;

  // Animación de ondas en loop
  late AnimationController _waveController;

  static const int _waveCount = 3;
  static const double _waveDelay = 0.33; // desfase entre ondas (0.0 - 1.0)

  @override
  void initState() {
    super.initState();

    // --- Animación de entrada ---
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleRings = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    _entryController.forward();

    // --- Animación de ondas en loop ---
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDF5EF), Color(0xFFFAECE3), Color(0xFFF5E0D5)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              children: [
                const SizedBox(height: 48),

                // App Icon
                FadeTransition(
                  opacity: _fadeIn,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE8A598).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      color: Color(0xFFD94F5C),
                      size: 36,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Title + Subtitle
                FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Soul',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A1A),
                                letterSpacing: -1,
                              ),
                            ),
                            TextSpan(
                              text: 'Sync',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFD94F5C),
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Conecta más allá de las palabras',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF8A7070),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Rings illustration + Ripple waves
                Expanded(
                  child: Align(
                    alignment: const Alignment(0, -0.4),
                    child: ScaleTransition(
                      scale: _scaleRings,
                      child: FadeTransition(
                        opacity: _fadeIn,
                        child: SizedBox(
                          width: 260,
                          height: 260,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ondas animadas (ripple) con desfase entre cada una
                              ...List.generate(_waveCount, (i) {
                                return _WaveRipple(
                                  controller: _waveController,
                                  delay: i * _waveDelay,
                                  maxRadius: 150,
                                  color: const Color(0xFFD94F5C),
                                );
                              }),

                              // Círculo central con iconos
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(
                                    0xFFD94F5C,
                                  ).withValues(alpha: 0.12),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      top: 18,
                                      left: 14,
                                      child: Icon(
                                        Icons.auto_awesome,
                                        color: const Color(
                                          0xFFD94F5C,
                                        ).withValues(alpha: 0.9),
                                        size: 30,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 16,
                                      right: 14,
                                      child: Icon(
                                        Icons.bubble_chart_outlined,
                                        color: const Color(
                                          0xFFD94F5C,
                                        ).withValues(alpha: 0.7),
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Buttons
                FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD94F5C),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Comenzar',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Navigate to how it works screen
                            // Navigator.pushNamed(context, '/how-it-works');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A1A1A),
                            side: BorderSide.none,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Text(
                            'Cómo funciona',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E8A8A),
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Al continuar, aceptas nuestros ',
                            ),
                            TextSpan(
                              text: 'Términos y Condiciones',
                              style: const TextStyle(
                                color: Color(0xFFD94F5C),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFFD94F5C),
                              ),
                            ),
                            const TextSpan(text: ' y nuestra '),
                            TextSpan(
                              text: 'Política de Privacidad',
                              style: const TextStyle(
                                color: Color(0xFFD94F5C),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFFD94F5C),
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget que pinta una sola onda expandiéndose y desvaneciéndose en loop.
// ---------------------------------------------------------------------------
class _WaveRipple extends StatelessWidget {
  const _WaveRipple({
    required this.controller,
    required this.delay,
    required this.maxRadius,
    required this.color,
  });

  final AnimationController controller;
  final double delay; // 0.0 – 1.0, desfase relativo en el ciclo
  final double maxRadius; // radio máximo al que llega la onda
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Progreso de esta onda (cíclico con su desfase)
        final double progress = (controller.value + delay) % 1.0;

        // Radio: parte desde el borde del círculo central (40px) hasta maxRadius
        final double radius = 40 + (maxRadius - 40) * progress;

        // Opacidad: fuerte al inicio, se desvanece al crecer
        final double opacity = (1.0 - progress) * 0.4;

        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: opacity),
              width: 1.8,
            ),
          ),
        );
      },
    );
  }
}
