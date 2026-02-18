import 'dart:async';
import 'package:flutter/material.dart';
import 'capsule_screen.dart';

// ---------------------------------------------------------------------------
// Configuración por modo
// ---------------------------------------------------------------------------
class ModeConfig {
  final String title;
  final Color bgColor;
  final Color accentColor;
  final IconData icon;
  final List<String> questions;

  const ModeConfig({
    required this.title,
    required this.bgColor,
    required this.accentColor,
    required this.icon,
    required this.questions,
  });
}

final Map<String, ModeConfig> modeConfigs = {
  'pareja': ModeConfig(
    title: 'CONVERSACIÓN',
    bgColor: const Color(0xFFFDF5EF),
    accentColor: const Color(0xFFD94F5C),
    icon: Icons.favorite_border_rounded,
    questions: [
      '¿Qué es lo que más valoras en una relación?',
      '¿Cuál ha sido tu momento favorito juntos?',
      '¿Qué sueño tienes que aún no me has contado?',
      '¿Qué cualidad mía es la que más aprecias?',
      '¿Cómo imaginas nuestro futuro en 5 años?',
      '¿Qué es lo que más te hace reír de mí?',
      '¿Hay algo que siempre quisiste preguntarme?',
      '¿Qué momento de nuestra historia repetirías?',
    ],
  ),
  'amigos': ModeConfig(
    title: 'CONVERSACIÓN',
    bgColor: const Color(0xFFFFF8F0),
    accentColor: const Color(0xFFE07B3A),
    icon: Icons.group_rounded,
    questions: [
      '¿Cuál es tu recuerdo favorito con amigos?',
      '¿Qué harías si no tuvieras miedo al fracaso?',
      '¿Cuál es tu mayor logro hasta ahora?',
      '¿Qué hábito tuyo crees que sorprende a los demás?',
      '¿A qué lugar del mundo irías mañana si pudieras?',
      '¿Qué canción define tu vida en este momento?',
      '¿Cuál es tu mayor miedo y por qué?',
      '¿Qué te hace sentir más vivo/a?',
    ],
  ),
  'citas': ModeConfig(
    title: 'CONVERSACIÓN',
    bgColor: const Color(0xFFF9F0FF),
    accentColor: const Color(0xFFAB5FD4),
    icon: Icons.auto_awesome_rounded,
    questions: [
      '¿Qué es lo primero que notas en una persona?',
      '¿Cuál es tu idea de una cita perfecta?',
      '¿Qué cualidad buscas en una pareja?',
      '¿Eres más de rutina o de aventura?',
      '¿Qué te hace sentir mariposas en el estómago?',
      '¿Cuál es tu lenguaje del amor favorito?',
      '¿Qué es lo más romántico que has hecho?',
      '¿Qué canción pondrías en nuestra primera cita?',
    ],
  ),
  'picante': ModeConfig(
    title: 'CONVERSACIÓN',
    bgColor: const Color(0xFFFFF3EE),
    accentColor: const Color(0xFFE05C2A),
    icon: Icons.local_fire_department_rounded,
    questions: [
      '¿Cuál es tu fantasía más secreta?',
      '¿Qué es lo más atrevido que has hecho?',
      '¿Qué te resulta irresistible en otra persona?',
      '¿Cuál es tu mayor tabú que en secreto te atrae?',
      '¿Qué harías si estuviéramos solos toda la noche?',
      '¿Cuál es el lugar más atrevido donde has estado?',
      '¿Qué prenda te parece más seductora?',
      '¿Verdad o reto? Elige y te lanzo uno.',
    ],
  ),
};

// ---------------------------------------------------------------------------
// QuestionScreen
// ---------------------------------------------------------------------------
class QuestionScreen extends StatefulWidget {
  final String mode;

  const QuestionScreen({super.key, required this.mode});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late ModeConfig _config;
  late List<String> _questions;

  // _currentIndex: controla la barra de progreso, solo avanza con "Siguiente"
  int _currentIndex = 0;

  // _replacementIndex: controla qué pregunta se muestra, null = usa _currentIndex
  int? _replacementIndex;

  int _secondsLeft = 90;
  Timer? _timer;

  // La pregunta visible es la de reemplazo si existe, si no la del índice actual
  int get _displayIndex => _replacementIndex ?? _currentIndex;

  @override
  void initState() {
    super.initState();
    _config = modeConfigs[widget.mode] ?? modeConfigs['pareja']!;
    _questions = List.from(_config.questions)..shuffle();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 90);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _replacementIndex = null; // vuelve a la secuencia normal
      });
      _startTimer();
    }
  }

  void _changeQuestion() {
    // Cambia solo la pregunta visible sin mover el índice de progreso
    final pool = List.generate(_questions.length, (i) => i)
      ..remove(_displayIndex);
    if (pool.isEmpty) return;
    pool.shuffle();
    setState(() => _replacementIndex = pool.first);
    _startTimer();
  }

  String get _timerText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m : $s';
  }

  // La barra solo depende de _currentIndex
  double get _progress => (_currentIndex + 1) / _questions.length;

  bool get _isTimerWarning => _secondsLeft <= 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _config.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildTopBar(context),
              const SizedBox(height: 20),
              _buildProgress(),
              const SizedBox(height: 20),
              _buildTimer(),
              const SizedBox(height: 32),
              Expanded(child: _buildQuestionCard()),
              const SizedBox(height: 24),
              _buildNextButton(),
              const SizedBox(height: 12),

              // Cambiar pregunta
              GestureDetector(
                onTap: _changeQuestion,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: _config.accentColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Cambiar pregunta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _config.accentColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'CONECTA PROFUNDAMENTE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.8,
                  color: _config.accentColor.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.close_rounded,
            size: 26,
            color: Colors.black87,
          ),
        ),
        Text(
          _config.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const Icon(Icons.share_outlined, size: 24, color: Colors.black87),
      ],
    );
  }

  Widget _buildProgress() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pregunta ${_currentIndex + 1} de ${_questions.length}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9E8A8A),
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _config.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${(_progress * 100).round()}% COMPLETADO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _config.accentColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 5,
            backgroundColor: _config.accentColor.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(_config.accentColor),
          ),
        ),
      ],
    );
  }

  Widget _buildTimer() {
    final timerColor = _isTimerWarning
        ? const Color(0xFFD94F5C)
        : const Color(0xFF9E8A8A);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: _isTimerWarning
            ? const Color(0xFFFFE4E6)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: timerColor.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: timerColor),
          const SizedBox(width: 6),
          Text(
            _timerText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: timerColor,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _config.accentColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _config.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_config.icon, color: _config.accentColor, size: 28),
            ),

            const SizedBox(height: 28),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                _questions[_displayIndex], // usa _displayIndex, no _currentIndex
                key: ValueKey(_displayIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  height: 1.35,
                  letterSpacing: -0.3,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Tómate tu tiempo para responder\ncon sinceridad y profundidad.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF9E8A8A),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final bool isLast = _currentIndex == _questions.length - 1;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLast
            ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CapsuleScreen(mode: widget.mode),
                ),
              )
            : _nextQuestion,
        style: ElevatedButton.styleFrom(
          backgroundColor: _config.accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLast ? Icons.send_rounded : Icons.arrow_forward_rounded,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isLast ? 'Send message' : 'Siguiente',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
