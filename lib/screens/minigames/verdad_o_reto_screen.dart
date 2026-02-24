//lib/screens/minigames/verdad_o_reto_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Modelos y enums
// ---------------------------------------------------------------------------
enum CardKind { truth, dare }

enum IntensityLevel { suave, medio, intenso, vulnerable }

enum TurnPhase { choosing, revealed }

class GameCard {
  final String text;
  final CardKind kind;
  final IntensityLevel level;
  final bool isCustom;

  const GameCard({
    required this.text,
    required this.kind,
    required this.level,
    this.isCustom = false,
  });
}

// ---------------------------------------------------------------------------
// Banco de cartas fijo
// ---------------------------------------------------------------------------
const List<GameCard> _fixedCards = [
  // SUAVE — Verdades
  GameCard(
    text: '¿Cuál es tu canción favorita en este momento y por qué?',
    kind: CardKind.truth,
    level: IntensityLevel.suave,
  ),
  GameCard(
    text: '¿Qué es lo primero que notas cuando conoces a alguien?',
    kind: CardKind.truth,
    level: IntensityLevel.suave,
  ),
  GameCard(
    text: '¿Cuál ha sido el mejor día de tu año?',
    kind: CardKind.truth,
    level: IntensityLevel.suave,
  ),
  GameCard(
    text: '¿Qué hábito tuyo crees que sorprende a la gente?',
    kind: CardKind.truth,
    level: IntensityLevel.suave,
  ),
  GameCard(
    text: '¿Qué película o serie has visto más de tres veces?',
    kind: CardKind.truth,
    level: IntensityLevel.suave,
  ),
  // SUAVE — Retos
  GameCard(
    text: 'Imita a alguien famoso durante 30 segundos.',
    kind: CardKind.dare,
    level: IntensityLevel.suave,
  ),
  GameCard(
    text: 'Di tres cosas buenas de la persona que tienes enfrente.',
    kind: CardKind.dare,
    level: IntensityLevel.suave,
  ),
  GameCard(
    text: 'Habla con acento extranjero durante el siguiente turno.',
    kind: CardKind.dare,
    level: IntensityLevel.suave,
  ),
  GameCard(
    text: 'Muestra la última foto de tu galería.',
    kind: CardKind.dare,
    level: IntensityLevel.suave,
  ),
  GameCard(
    text: 'Escribe un poema de dos líneas sobre el otro jugador.',
    kind: CardKind.dare,
    level: IntensityLevel.suave,
  ),
  // MEDIO — Verdades
  GameCard(
    text: '¿Qué es lo que más te cuesta perdonar en una persona?',
    kind: CardKind.truth,
    level: IntensityLevel.medio,
  ),
  GameCard(
    text: '¿Cuál ha sido tu mayor decepción este año?',
    kind: CardKind.truth,
    level: IntensityLevel.medio,
  ),
  GameCard(
    text: '¿Qué cosa hacías de niño/a que ahora te da vergüenza?',
    kind: CardKind.truth,
    level: IntensityLevel.medio,
  ),
  GameCard(
    text:
        '¿Con qué persona de tu pasado te arrepientes de haber perdido contacto?',
    kind: CardKind.truth,
    level: IntensityLevel.medio,
  ),
  GameCard(
    text: '¿Qué opinas de ti mismo/a que nunca dices en voz alta?',
    kind: CardKind.truth,
    level: IntensityLevel.medio,
  ),
  // MEDIO — Retos
  GameCard(
    text: 'Lee el último mensaje de texto que enviaste en voz alta.',
    kind: CardKind.dare,
    level: IntensityLevel.medio,
  ),
  GameCard(
    text:
        'Llama a alguien y dile que lo extrañas. Sin colgar hasta que responda.',
    kind: CardKind.dare,
    level: IntensityLevel.medio,
  ),
  GameCard(
    text: 'Cuéntale al otro jugador algo que nunca le has contado a nadie.',
    kind: CardKind.dare,
    level: IntensityLevel.medio,
  ),
  GameCard(
    text: 'Muestra la última búsqueda de Google que hiciste.',
    kind: CardKind.dare,
    level: IntensityLevel.medio,
  ),
  GameCard(
    text:
        'Di en voz alta lo que pensaste la primera vez que viste al otro jugador.',
    kind: CardKind.dare,
    level: IntensityLevel.medio,
  ),
  // INTENSO — Verdades
  GameCard(
    text: '¿Qué es lo que más te asusta de una relación seria?',
    kind: CardKind.truth,
    level: IntensityLevel.intenso,
  ),
  GameCard(
    text: '¿Cuándo fue la última vez que lloraste y qué lo provocó?',
    kind: CardKind.truth,
    level: IntensityLevel.intenso,
  ),
  GameCard(
    text:
        '¿Qué decisión tuya has tratado de justificar pero en el fondo sabes que estuvo mal?',
    kind: CardKind.truth,
    level: IntensityLevel.intenso,
  ),
  GameCard(
    text: '¿Qué parte de ti mismo/a no le has mostrado a nadie todavía?',
    kind: CardKind.truth,
    level: IntensityLevel.intenso,
  ),
  GameCard(
    text: '¿Qué conversación pendiente tienes con alguien que evitas tener?',
    kind: CardKind.truth,
    level: IntensityLevel.intenso,
  ),
  // INTENSO — Retos
  GameCard(
    text:
        'Escríbele un mensaje honesto a alguien con quien tengas algo pendiente. Muéstraselo antes de enviarlo.',
    kind: CardKind.dare,
    level: IntensityLevel.intenso,
  ),
  GameCard(
    text:
        'Di en voz alta tres cosas que admiras del otro jugador, mirándolo a los ojos.',
    kind: CardKind.dare,
    level: IntensityLevel.intenso,
  ),
  GameCard(
    text: 'Confiesa algo que hiciste y que nunca admitiste públicamente.',
    kind: CardKind.dare,
    level: IntensityLevel.intenso,
  ),
  // VULNERABLE — Verdades
  GameCard(
    text: '¿Cuál es el miedo que más influye en tus decisiones diarias?',
    kind: CardKind.truth,
    level: IntensityLevel.vulnerable,
  ),
  GameCard(
    text: '¿En qué momento de tu vida te has sentido más solo/a?',
    kind: CardKind.truth,
    level: IntensityLevel.vulnerable,
  ),
  GameCard(
    text: '¿Qué cosa no le has dicho a alguien cercano que debería saber?',
    kind: CardKind.truth,
    level: IntensityLevel.vulnerable,
  ),
  GameCard(
    text: '¿Qué versión de ti mismo/a extrañas?',
    kind: CardKind.truth,
    level: IntensityLevel.vulnerable,
  ),
  GameCard(
    text: '¿Qué necesitas de las personas en tu vida que no sabes cómo pedir?',
    kind: CardKind.truth,
    level: IntensityLevel.vulnerable,
  ),
  // VULNERABLE — Retos
  GameCard(
    text: 'Describe el momento más vulnerable de tu vida. Sin saltarte nada.',
    kind: CardKind.dare,
    level: IntensityLevel.vulnerable,
  ),
  GameCard(
    text:
        'Dile al otro jugador algo que siempre quisiste decirle pero no te atreviste.',
    kind: CardKind.dare,
    level: IntensityLevel.vulnerable,
  ),
  GameCard(
    text:
        'Cierra los ojos y di en voz alta lo que sientes en este momento, sin filtro.',
    kind: CardKind.dare,
    level: IntensityLevel.vulnerable,
  ),
];

enum GamePhase { setup, customCards, playing, levelUpPrompt }

// ---------------------------------------------------------------------------
// VerdadORetoScreen
// ---------------------------------------------------------------------------
class VerdadORetoScreen extends StatefulWidget {
  const VerdadORetoScreen({super.key});

  @override
  State<VerdadORetoScreen> createState() => _VerdadORetoScreenState();
}

class _VerdadORetoScreenState extends State<VerdadORetoScreen> {
  GamePhase _phase = GamePhase.setup;

  // Jugadores
  String _player1Name = '';
  String _player2Name = '';
  final TextEditingController _name1Controller = TextEditingController();
  final TextEditingController _name2Controller = TextEditingController();

  // Custom cards setup
  final List<TextEditingController> _customControllers = [];
  final List<CardKind> _customKinds = [];
  final List<GameCard> _customCards = [];

  // Estado del juego
  IntensityLevel _currentLevel = IntensityLevel.suave;
  int _currentPlayerIndex = 0;
  int _roundCount = 0;
  final Set<int> _usedFixedIndices = {};
  final Set<int> _usedCustomIndices = {};

  // Las 2 cartas en mesa (pueden ser null mientras se preparan)
  GameCard? _cardA;
  GameCard? _cardB;

  // Turno interno
  TurnPhase _turnPhase = TurnPhase.choosing;
  GameCard? _revealedCard;

  // Level up
  bool _player1AcceptsLevelUp = false;
  bool _player2AcceptsLevelUp = false;

  @override
  void dispose() {
    _name1Controller.dispose();
    _name2Controller.dispose();
    for (final c in _customControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _levelName(IntensityLevel l) => const {
    IntensityLevel.suave: 'Suave',
    IntensityLevel.medio: 'Medio',
    IntensityLevel.intenso: 'Intenso',
    IntensityLevel.vulnerable: 'Vulnerable',
  }[l]!;

  Color _levelColor(IntensityLevel l) => const {
    IntensityLevel.suave: Color(0xFF4CAF50),
    IntensityLevel.medio: Color(0xFFE07B3A),
    IntensityLevel.intenso: Color(0xFFD94F5C),
    IntensityLevel.vulnerable: Color(0xFFAB5FD4),
  }[l]!;

  String _levelEmoji(IntensityLevel l) => const {
    IntensityLevel.suave: '🌱',
    IntensityLevel.medio: '🔥',
    IntensityLevel.intenso: '⚡',
    IntensityLevel.vulnerable: '💜',
  }[l]!;

  IntensityLevel? get _nextLevel {
    final levels = IntensityLevel.values;
    final idx = levels.indexOf(_currentLevel);
    return idx < levels.length - 1 ? levels[idx + 1] : null;
  }

  String get _currentPlayerName =>
      _currentPlayerIndex == 0 ? _player1Name : _player2Name;

  Color get _currentPlayerColor => _currentPlayerIndex == 0
      ? const Color(0xFFD94F5C)
      : const Color(0xFFAB5FD4);

  // ---------------------------------------------------------------------------
  // Setup
  // ---------------------------------------------------------------------------
  void _submitSetup() {
    final n1 = _name1Controller.text.trim();
    final n2 = _name2Controller.text.trim();
    if (n1.isEmpty || n2.isEmpty) return;
    setState(() {
      _player1Name = n1;
      _player2Name = n2;
      _phase = GamePhase.customCards;
      _addCustomField();
      _addCustomField();
    });
  }

  void _addCustomField() {
    _customControllers.add(TextEditingController());
    _customKinds.add(CardKind.truth);
  }

  void _submitCustomCards() {
    for (int i = 0; i < _customControllers.length; i++) {
      final text = _customControllers[i].text.trim();
      if (text.isNotEmpty) {
        _customCards.add(
          GameCard(
            text: text,
            kind: _customKinds[i],
            level: IntensityLevel.suave,
            isCustom: true,
          ),
        );
      }
    }
    setState(() {
      _phase = GamePhase.playing;
      _dealCards();
    });
  }

  // ---------------------------------------------------------------------------
  // Lógica de cartas
  // ---------------------------------------------------------------------------
  GameCard _pickCard({GameCard? excluding}) {
    final pool = <({String src, int idx})>[];

    for (int i = 0; i < _fixedCards.length; i++) {
      if (_fixedCards[i].level == _currentLevel &&
          !_usedFixedIndices.contains(i) &&
          (excluding == null || _fixedCards[i] != excluding)) {
        pool.add((src: 'fixed', idx: i));
      }
    }
    for (int i = 0; i < _customCards.length; i++) {
      if (!_usedCustomIndices.contains(i) &&
          (excluding == null || _customCards[i] != excluding)) {
        pool.add((src: 'custom', idx: i));
      }
    }

    if (pool.isEmpty) {
      // Resetear usadas del nivel actual y reintentar
      _usedFixedIndices.removeWhere(
        (i) => _fixedCards[i].level == _currentLevel,
      );
      return _pickCard(excluding: excluding);
    }

    final pick = pool[Random().nextInt(pool.length)];
    if (pick.src == 'fixed') {
      _usedFixedIndices.add(pick.idx);
      return _fixedCards[pick.idx];
    } else {
      _usedCustomIndices.add(pick.idx);
      return _customCards[pick.idx];
    }
  }

  void _dealCards() {
    final a = _pickCard();
    final b = _pickCard(excluding: a);
    setState(() {
      _cardA = a;
      _cardB = b;
      _turnPhase = TurnPhase.choosing;
      _revealedCard = null;
    });
  }

  void _onCardChosen(int cardIndex) {
    if (_turnPhase != TurnPhase.choosing) return;
    final chosen = cardIndex == 0 ? _cardA! : _cardB!;
    setState(() {
      _revealedCard = chosen;
      _turnPhase = TurnPhase.revealed;
    });
  }

  void _onAnswered() {
    _roundCount++;
    setState(() {
      _currentPlayerIndex = _currentPlayerIndex == 0 ? 1 : 0;
      if (_roundCount % 4 == 0 && _nextLevel != null) {
        _player1AcceptsLevelUp = false;
        _player2AcceptsLevelUp = false;
        _phase = GamePhase.levelUpPrompt;
      } else {
        _dealCards();
      }
    });
  }

  void _onSkip() {
    setState(() => _dealCards());
  }

  // ---------------------------------------------------------------------------
  // Level up
  // ---------------------------------------------------------------------------
  void _acceptLevelUp(bool isPlayer1) {
    setState(() {
      if (isPlayer1) {
        _player1AcceptsLevelUp = true;
      } else {
        _player2AcceptsLevelUp = true;
      }

      if (_player1AcceptsLevelUp && _player2AcceptsLevelUp) {
        _currentLevel = _nextLevel!;
        _phase = GamePhase.playing;
        _dealCards();
      }
    });
  }

  void _declineLevelUp() {
    setState(() {
      _phase = GamePhase.playing;
      _dealCards();
    });
  }

  void _resetGame() {
    for (final c in _customControllers) {
      c.dispose();
    }
    _customControllers.clear();
    _customKinds.clear();
    _name1Controller.clear();
    _name2Controller.clear();
    setState(() {
      _phase = GamePhase.setup;
      _player1Name = '';
      _player2Name = '';
      _currentLevel = IntensityLevel.suave;
      _currentPlayerIndex = 0;
      _roundCount = 0;
      _cardA = null;
      _cardB = null;
      _turnPhase = TurnPhase.choosing;
      _revealedCard = null;
      _usedFixedIndices.clear();
      _customCards.clear();
      _usedCustomIndices.clear();
      _player1AcceptsLevelUp = false;
      _player2AcceptsLevelUp = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5EF),
      body: SafeArea(
        child: switch (_phase) {
          GamePhase.setup => _buildSetup(),
          GamePhase.customCards => _buildCustomCards(),
          GamePhase.playing => _buildPlaying(),
          GamePhase.levelUpPrompt => _buildLevelUpPrompt(),
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Setup
  // ---------------------------------------------------------------------------
  Widget _buildSetup() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.go('/minigames'),
              child: const Icon(
                Icons.close_rounded,
                size: 26,
                color: Colors.black87,
              ),
            ),
          ),
          const Spacer(),
          const Text('🔥', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Verdad o Reto',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Elige una carta. Descubre qué te espera.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E8A8A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),
          _InputBox(
            controller: _name1Controller,
            hint: 'Nombre del Jugador 1',
            maxLines: 1,
            color: const Color(0xFFD94F5C),
          ),
          const SizedBox(height: 12),
          _InputBox(
            controller: _name2Controller,
            hint: 'Nombre del Jugador 2',
            maxLines: 1,
            color: const Color(0xFFAB5FD4),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE07B3A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text(
                'Siguiente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Custom cards
  // ---------------------------------------------------------------------------
  Widget _buildCustomCards() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.go('/minigames'),
            child: const Icon(
              Icons.close_rounded,
              size: 26,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Agrega tus cartas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Opcional. Se mezclarán con el banco de preguntas.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF9E8A8A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          StatefulBuilder(
            builder: (context, setInner) => Column(
              children: [
                ...List.generate(
                  _customControllers.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _InputBox(
                            controller: _customControllers[i],
                            hint: 'Pregunta o reto...',
                            maxLines: 2,
                            color: const Color(0xFFE07B3A),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => setInner(() {
                            _customKinds[i] = _customKinds[i] == CardKind.truth
                                ? CardKind.dare
                                : CardKind.truth;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _customKinds[i] == CardKind.truth
                                  ? const Color(0xFFE8F0FE)
                                  : const Color(0xFFFFEDD5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                _customKinds[i] == CardKind.truth ? 'V' : 'R',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _customKinds[i] == CardKind.truth
                                      ? const Color(0xFF1A73E8)
                                      : const Color(0xFFE07B3A),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setInner(_addCustomField),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0D5D5)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: Color(0xFF9E8A8A),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Agregar otra',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E8A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitCustomCards,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE07B3A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text(
                '¡Empezar!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          TextButton(
            onPressed: _submitCustomCards,
            child: const Center(
              child: Text(
                'Saltar — usar solo el banco',
                style: TextStyle(fontSize: 13, color: Color(0xFF9E8A8A)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Playing — 2 cartas en mesa
  // ---------------------------------------------------------------------------
  Widget _buildPlaying() {
    final levelColor = _levelColor(_currentLevel);
    final isChoosing = _turnPhase == TurnPhase.choosing;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.go('/minigames'),
                child: const Icon(
                  Icons.close_rounded,
                  size: 26,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_levelEmoji(_currentLevel)),
                    const SizedBox(width: 4),
                    Text(
                      _levelName(_currentLevel),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: levelColor,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _resetGame,
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 26,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Indicador de turno
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_currentPlayerIndex),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _currentPlayerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                isChoosing
                    ? '$_currentPlayerName — elige una carta'
                    : 'Turno de $_currentPlayerName',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _currentPlayerColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Las 2 cartas o la carta revelada
          if (isChoosing) _buildTwoCards() else _buildRevealedCard(),

          const Spacer(),

          // Botones de acción
          if (!isChoosing) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _onSkip,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCCBBBB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Pasar',
                      style: TextStyle(
                        color: Color(0xFF9E8A8A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _onAnswered,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _revealedCard?.kind == CardKind.truth
                          ? const Color(0xFF1A73E8)
                          : const Color(0xFFE07B3A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Respondí ✓',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTwoCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _FaceDownCard(
          label: 'A',
          color: _currentPlayerColor,
          onTap: () => _onCardChosen(0),
        ),
        const SizedBox(width: 20),
        _FaceDownCard(
          label: 'B',
          color: _currentPlayerColor,
          onTap: () => _onCardChosen(1),
        ),
      ],
    );
  }

  Widget _buildRevealedCard() {
    if (_revealedCard == null) return const SizedBox.shrink();
    final card = _revealedCard!;
    final isTruth = card.kind == CardKind.truth;
    final cardColor = isTruth
        ? const Color(0xFF1A73E8)
        : const Color(0xFFE07B3A);
    final cardBg = isTruth ? const Color(0xFFE8F0FE) : const Color(0xFFFFEDD5);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge tipo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              isTruth ? '🔵 VERDAD' : '🟠 RETO',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: cardColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // La carta
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cardColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: cardColor.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                if (card.isCustom) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF5EF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '✨ Carta personalizada',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9E8A8A)),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Text(
                  card.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Level up prompt
  // ---------------------------------------------------------------------------
  Widget _buildLevelUpPrompt() {
    final next = _nextLevel!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _resetGame,
              child: const Icon(
                Icons.refresh_rounded,
                size: 26,
                color: Colors.black87,
              ),
            ),
          ),
          const Spacer(),
          Text(_levelEmoji(next), style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            '¿Subir a "${_levelName(next)}"?',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Las preguntas se volverán más personales.\nSolo si ambos quieren.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E8A8A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _LevelUpVote(
            name: _player1Name,
            accepted: _player1AcceptsLevelUp,
            color: const Color(0xFFD94F5C),
            onAccept: () => _acceptLevelUp(true),
          ),
          const SizedBox(height: 12),
          _LevelUpVote(
            name: _player2Name,
            accepted: _player2AcceptsLevelUp,
            color: const Color(0xFFAB5FD4),
            onAccept: () => _acceptLevelUp(false),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _declineLevelUp,
            child: Text(
              'No, seguir en "${_levelName(_currentLevel)}"',
              style: const TextStyle(fontSize: 14, color: Color(0xFF9E8A8A)),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets auxiliares
// ---------------------------------------------------------------------------
class _FaceDownCard extends StatelessWidget {
  const _FaceDownCard({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 200,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.controller,
    required this.hint,
    required this.maxLines,
    required this.color,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF1A1A1A),
          height: 1.4,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _LevelUpVote extends StatelessWidget {
  const _LevelUpVote({
    required this.name,
    required this.accepted,
    required this.color,
    required this.onAccept,
  });

  final String name;
  final bool accepted;
  final Color color;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: accepted ? null : onAccept,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: accepted ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accepted ? color : const Color(0xFFE0D5D5),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: accepted ? color : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: accepted
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: color,
                      size: 28,
                      key: const ValueKey('y'),
                    )
                  : Icon(
                      Icons.radio_button_unchecked_rounded,
                      color: Colors.grey[300],
                      size: 28,
                      key: const ValueKey('n'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
