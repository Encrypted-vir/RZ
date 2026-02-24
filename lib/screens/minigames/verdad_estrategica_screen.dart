//lib/screens/minigames/verdad_estrategica_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Enums y modelos
// ---------------------------------------------------------------------------
enum GamePhase {
  player1Setup,
  player2Setup,
  revealing, // Turno alternado destapando cartas
  player1Guessing, // J1 elige cuáles del otro son verdad
  player2Guessing, // J2 elige cuáles del otro son verdad
  roundResult,
  deepQuestion,
}

enum CardType { truth, lie }

class PlayerCard {
  final String text;
  final CardType type;
  bool isRevealed;
  bool? guessedAsTruth; // lo que el otro jugador eligió

  PlayerCard({required this.text, required this.type, this.isRevealed = false});
}

const List<String> _deepQuestions = [
  '¿Cuál es el secreto que más te cuesta guardar?',
  '¿En qué momento de tu vida te has sentido más solo/a?',
  '¿Qué es lo que más te asusta del futuro?',
  '¿Qué parte de ti mismo/a crees que nadie conoce realmente?',
  '¿Cuándo fue la última vez que lloraste y por qué?',
  '¿Qué harías diferente si pudieras volver atrás?',
  '¿Qué cosa nunca le has dicho a alguien que debería saber?',
];

// ---------------------------------------------------------------------------
// VerdadEstrategicaScreen
// ---------------------------------------------------------------------------
class VerdadEstrategicaScreen extends StatefulWidget {
  const VerdadEstrategicaScreen({super.key});

  @override
  State<VerdadEstrategicaScreen> createState() =>
      _VerdadEstrategicaScreenState();
}

class _VerdadEstrategicaScreenState extends State<VerdadEstrategicaScreen> {
  GamePhase _phase = GamePhase.player1Setup;

  // Datos de jugadores
  String _player1Name = '';
  String _player2Name = '';
  List<PlayerCard> _player1Cards = [];
  List<PlayerCard> _player2Cards = [];

  // Puntuación
  int _player1Score = 0;
  int _player2Score = 0;
  int _roundsPlayed = 0;
  static const int _totalRounds = 3;

  // Fase de revelado — quién destapa ahora (empieza J1 destapando cartas de J2)
  Player _revealingPlayer = Player.one; // quién tiene el turno de destapar
  int _revealedCount = 0; // cuántas cartas se han destapado en total

  // Fase de adivinanza — cartas seleccionadas como "verdad" por el adivinador
  Set<int> _selectedAsTrue = {};

  // Setup temporal
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _cardControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<CardType?> _cardTypes = [null, null, null];

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  // Las cartas que el jugador actual debe destapar (las del otro)
  List<PlayerCard> get _cardsToReveal =>
      _revealingPlayer == Player.one ? _player2Cards : _player1Cards;

  String get _revealingName =>
      _revealingPlayer == Player.one ? _player1Name : _player2Name;

  String get _otherName =>
      _revealingPlayer == Player.one ? _player2Name : _player1Name;

  bool get _allRevealed => _revealedCount >= 6;

  // ---------------------------------------------------------------------------
  // Setup
  // ---------------------------------------------------------------------------
  void _submitSetup(bool isPlayer1) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final texts = _cardControllers.map((c) => c.text.trim()).toList();
    if (texts.any((t) => t.isEmpty)) return;
    if (_cardTypes.any((t) => t == null)) return;

    final hasTruth = _cardTypes.any((t) => t == CardType.truth);
    if (!hasTruth) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debe haber al menos una verdad.'),
          backgroundColor: const Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final cards = List.generate(
      3,
      (i) => PlayerCard(text: texts[i], type: _cardTypes[i]!),
    );

    setState(() {
      if (isPlayer1) {
        _player1Name = name;
        _player1Cards = cards;
      } else {
        _player2Name = name;
        _player2Cards = cards;
      }
      _nameController.clear();
      for (final c in _cardControllers) {
        c.clear();
      }
      for (int i = 0; i < 3; i++) {
        _cardTypes[i] = null;
      }
      _phase = isPlayer1 ? GamePhase.player2Setup : GamePhase.revealing;
    });
  }

  // ---------------------------------------------------------------------------
  // Revelado alternado
  // ---------------------------------------------------------------------------
  void _onRevealTap(int cardIndex) {
    final cards = _cardsToReveal;
    if (cards[cardIndex].isRevealed) return;

    setState(() {
      cards[cardIndex].isRevealed = true;
      _revealedCount++;

      if (_allRevealed) {
        // Todas destapadas → empezar adivinanzas
        _selectedAsTrue = {};
        _phase = GamePhase.player1Guessing;
      } else {
        // Alternar turno
        _revealingPlayer = _revealingPlayer == Player.one
            ? Player.two
            : Player.one;
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Adivinanza
  // ---------------------------------------------------------------------------
  void _toggleGuess(int cardIndex) {
    setState(() {
      if (_selectedAsTrue.contains(cardIndex)) {
        _selectedAsTrue.remove(cardIndex);
      } else {
        _selectedAsTrue.add(cardIndex);
      }
    });
  }

  void _submitGuesses(bool isPlayer1Guessing) {
    // Guardar las elecciones en las cartas
    final cardsBeingGuessed = isPlayer1Guessing ? _player2Cards : _player1Cards;
    for (int i = 0; i < 3; i++) {
      cardsBeingGuessed[i].guessedAsTruth = _selectedAsTrue.contains(i);
    }

    // Calcular puntos: 1 punto por cada carta correctamente identificada
    int correct = 0;
    for (int i = 0; i < 3; i++) {
      final card = cardsBeingGuessed[i];
      final guessedTrue = card.guessedAsTruth ?? false;
      if ((guessedTrue && card.type == CardType.truth) ||
          (!guessedTrue && card.type == CardType.lie)) {
        correct++;
      }
    }

    setState(() {
      if (isPlayer1Guessing) {
        _player1Score += correct;
        _selectedAsTrue = {};
        _phase = GamePhase.player2Guessing;
      } else {
        _player2Score += correct;
        _phase = GamePhase.roundResult;
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Resultado y avance
  // ---------------------------------------------------------------------------
  void _advanceFromResult() {
    _roundsPlayed++;
    for (final c in _player1Cards) {
      c.isRevealed = false;
      c.guessedAsTruth = null;
    }
    for (final c in _player2Cards) {
      c.isRevealed = false;
      c.guessedAsTruth = null;
    }
    setState(() {
      _revealedCount = 0;
      _revealingPlayer = Player.one;
      _selectedAsTrue = {};
      if (_roundsPlayed >= _totalRounds) {
        _phase = GamePhase.deepQuestion;
      } else {
        _phase = GamePhase.player1Setup;
      }
    });
  }

  void _resetGame() {
    _nameController.clear();
    for (final c in _cardControllers) {
      c.clear();
    }
    for (int i = 0; i < 3; i++) {
      _cardTypes[i] = null;
    }
    setState(() {
      _phase = GamePhase.player1Setup;
      _player1Name = '';
      _player2Name = '';
      _player1Cards = [];
      _player2Cards = [];
      _player1Score = 0;
      _player2Score = 0;
      _roundsPlayed = 0;
      _revealedCount = 0;
      _revealingPlayer = Player.one;
      _selectedAsTrue = {};
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
          GamePhase.player1Setup => _buildSetup(isPlayer1: true),
          GamePhase.player2Setup => _buildSetup(isPlayer1: false),
          GamePhase.revealing => _buildRevealing(),
          GamePhase.player1Guessing => _buildGuessing(isPlayer1: true),
          GamePhase.player2Guessing => _buildGuessing(isPlayer1: false),
          GamePhase.roundResult => _buildRoundResult(),
          GamePhase.deepQuestion => _buildDeepQuestion(),
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Setup
  // ---------------------------------------------------------------------------
  Widget _buildSetup({required bool isPlayer1}) {
    final color = isPlayer1 ? const Color(0xFFD94F5C) : const Color(0xFFAB5FD4);
    final playerNum = isPlayer1 ? 1 : 2;

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
          Center(
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$playerNum',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jugador',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _FieldLabel(label: 'Nombre', color: color),
          const SizedBox(height: 8),
          _InputBox(
            controller: _nameController,
            hint: 'Tu nombre',
            maxLines: 1,
            color: color,
          ),
          const SizedBox(height: 24),
          _FieldLabel(label: 'Tus 3 frases', color: color),
          const SizedBox(height: 4),
          Text(
            'Marca T si es verdad, F si es mentira.',
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 10),
          ...List.generate(3, (i) => _buildCardRow(i, color)),
          const SizedBox(height: 4),
          Text(
            'Al menos una debe ser verdad.',
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _submitSetup(isPlayer1),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Text(
                isPlayer1 ? 'Listo — Pasar al Jugador 2' : 'Comenzar juego',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCardRow(int index, Color color) {
    final selectedType = _cardTypes[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _InputBox(
              controller: _cardControllers[index],
              hint: 'Frase ${index + 1}',
              maxLines: 2,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          _TFButton(
            label: 'T',
            isSelected: selectedType == CardType.truth,
            selectedColor: const Color(0xFF2E7D32),
            onTap: () => setState(() => _cardTypes[index] = CardType.truth),
          ),
          const SizedBox(width: 6),
          _TFButton(
            label: 'F',
            isSelected: selectedType == CardType.lie,
            selectedColor: const Color(0xFFC62828),
            onTap: () => setState(() => _cardTypes[index] = CardType.lie),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Revelado alternado — se ven las 6 cartas
  // ---------------------------------------------------------------------------
  Widget _buildRevealing() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildTopBar(),
          const SizedBox(height: 16),
          _buildScoreBar(),
          const SizedBox(height: 16),

          // Indicador de turno
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color:
                  (_revealingPlayer == Player.one
                          ? const Color(0xFFD94F5C)
                          : const Color(0xFFAB5FD4))
                      .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '$_revealingName — destapa una carta de $_otherName',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _revealingPlayer == Player.one
                    ? const Color(0xFFD94F5C)
                    : const Color(0xFFAB5FD4),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Las 6 cartas — J1 arriba, J2 abajo
          _buildCardSection(
            playerName: _player1Name,
            cards: _player1Cards,
            color: const Color(0xFFD94F5C),
            canReveal: _revealingPlayer == Player.two, // J2 destapa las de J1
            ownerIndex: 1,
          ),
          const SizedBox(height: 20),
          _buildCardSection(
            playerName: _player2Name,
            cards: _player2Cards,
            color: const Color(0xFFAB5FD4),
            canReveal: _revealingPlayer == Player.one, // J1 destapa las de J2
            ownerIndex: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({
    required String playerName,
    required List<PlayerCard> cards,
    required Color color,
    required bool canReveal,
    required int ownerIndex,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$ownerIndex',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              playerName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(3, (i) {
            final card = cards[i];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                child: GestureDetector(
                  onTap: canReveal && !card.isRevealed
                      ? () {
                          // Buscar el índice real en la lista correcta
                          final isP2Cards = ownerIndex == 2;
                          if (isP2Cards && _revealingPlayer == Player.one) {
                            _onRevealTap(i);
                          } else if (!isP2Cards &&
                              _revealingPlayer == Player.two) {
                            _onRevealTap(i);
                          }
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 110,
                    decoration: BoxDecoration(
                      color: card.isRevealed ? Colors.white : color,
                      borderRadius: BorderRadius.circular(14),
                      border: canReveal && !card.isRevealed
                          ? Border.all(
                              color: color.withValues(alpha: 0.5),
                              width: 2,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: card.isRevealed
                          ? Text(
                              card.text,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1A1A1A),
                                height: 1.4,
                              ),
                            )
                          : Center(
                              child: Icon(
                                canReveal
                                    ? Icons.touch_app_rounded
                                    : Icons.lock_outline_rounded,
                                color: Colors.white.withValues(alpha: 0.7),
                                size: 28,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Adivinanza — elige cuáles son verdad
  // ---------------------------------------------------------------------------
  Widget _buildGuessing({required bool isPlayer1}) {
    final guesserName = isPlayer1 ? _player1Name : _player2Name;
    final ownerName = isPlayer1 ? _player2Name : _player1Name;
    final cardsToGuess = isPlayer1 ? _player2Cards : _player1Cards;
    final color = isPlayer1 ? const Color(0xFFD94F5C) : const Color(0xFFAB5FD4);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildTopBar(),
          const SizedBox(height: 16),
          _buildScoreBar(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '$guesserName — ¿cuáles de $ownerName son verdad?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca las que crees que son verdad',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: List.generate(3, (i) {
                final card = cardsToGuess[i];
                final isSelected = _selectedAsTrue.contains(i);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _toggleGuess(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE8F5E9)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2E7D32)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              card.text,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1A1A1A),
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                'V',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedAsTrue.isNotEmpty
                  ? () => _submitGuesses(isPlayer1)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[200],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Text(
                isPlayer1
                    ? 'Confirmar — Pasar a $_player2Name'
                    : 'Ver resultado',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Resultado de ronda
  // ---------------------------------------------------------------------------
  Widget _buildRoundResult() {
    // Calcular aciertos de cada jugador en esta ronda
    int p1Correct = 0;
    for (final card in _player2Cards) {
      final guessed = card.guessedAsTruth ?? false;
      if ((guessed && card.type == CardType.truth) ||
          (!guessed && card.type == CardType.lie)) {
        p1Correct++;
      }
    }
    int p2Correct = 0;
    for (final card in _player1Cards) {
      final guessed = card.guessedAsTruth ?? false;
      if ((guessed && card.type == CardType.truth) ||
          (!guessed && card.type == CardType.lie)) {
        p2Correct++;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildTopBar(),
          const SizedBox(height: 16),
          _buildScoreBar(),
          const Spacer(),

          const Text('📊', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'Resultado de la ronda',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),

          // Resultado J1
          _ResultRow(
            name: _player1Name,
            correct: p1Correct,
            total: 3,
            color: const Color(0xFFD94F5C),
          ),
          const SizedBox(height: 12),
          // Resultado J2
          _ResultRow(
            name: _player2Name,
            correct: p2Correct,
            total: 3,
            color: const Color(0xFFAB5FD4),
          ),

          const SizedBox(height: 28),

          // Revelar respuestas correctas
          _buildAnswerReveal(),

          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _advanceFromResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD94F5C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Text(
                _roundsPlayed + 1 >= _totalRounds
                    ? 'Ver pregunta final'
                    : 'Siguiente ronda',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAnswerReveal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlayerAnswers(
          name: _player1Name,
          cards: _player1Cards,
          color: const Color(0xFFD94F5C),
        ),
        const SizedBox(height: 12),
        _buildPlayerAnswers(
          name: _player2Name,
          cards: _player2Cards,
          color: const Color(0xFFAB5FD4),
        ),
      ],
    );
  }

  Widget _buildPlayerAnswers({
    required String name,
    required List<PlayerCard> cards,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ...cards.map((card) {
            final isTruth = card.type == CardType.truth;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isTruth
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isTruth ? 'V' : 'F',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isTruth
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      card.text,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pregunta profunda final
  // ---------------------------------------------------------------------------
  Widget _buildDeepQuestion() {
    final question = _deepQuestions[Random().nextInt(_deepQuestions.length)];
    final winner = _player1Score > _player2Score
        ? _player1Name
        : _player2Score > _player1Score
        ? _player2Name
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildTopBar(),
          const Spacer(),
          const Text('✨', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          const Text(
            'Pregunta Profunda',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            winner != null
                ? '$winner ganó con $_player1Score vs $_player2Score. Ambos responden:'
                : 'Empate $_player1Score - $_player2Score. Ambos responden:',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E8A8A)),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD94F5C).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '"$question"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/minigames'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCCBBBB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Salir',
                    style: TextStyle(
                      color: Color(0xFF9E8A8A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD94F5C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Otra partida',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets reutilizables
  // ---------------------------------------------------------------------------
  Widget _buildTopBar() {
    return Row(
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
        Text(
          'RONDA ${_roundsPlayed + 1} DE $_totalRounds',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFF1A1A1A),
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
    );
  }

  Widget _buildScoreBar() {
    return Row(
      children: [
        Expanded(
          child: _ScoreChip(
            name: _player1Name,
            score: _player1Score,
            color: const Color(0xFFD94F5C),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ScoreChip(
            name: _player2Name,
            score: _player2Score,
            color: const Color(0xFFAB5FD4),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Enum Player
// ---------------------------------------------------------------------------
enum Player { one, two }

// ---------------------------------------------------------------------------
// Widgets auxiliares
// ---------------------------------------------------------------------------
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.3,
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

class _TFButton extends StatelessWidget {
  const _TFButton({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? selectedColor : const Color(0xFFDDDDDD),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : const Color(0xFF9E8A8A),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.name,
    required this.score,
    required this.color,
  });

  final String name;
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.name,
    required this.correct,
    required this.total,
    required this.color,
  });

  final String name;
  final int correct;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          Text(
            '$correct / $total correctas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: correct == total
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFF9E8A8A),
            ),
          ),
        ],
      ),
    );
  }
}
