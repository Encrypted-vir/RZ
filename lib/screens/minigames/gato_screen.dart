//lib/screens/minigames/gato_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Enums y modelos
// ---------------------------------------------------------------------------
enum GamePhase { player1Input, player2Input, playing, finished }

enum Player { x, o }

class Cell {
  Player? owner;
  bool isFading; // para animación visual de la pieza que se va a borrar
  Cell({this.owner, this.isFading = false});
}

// ---------------------------------------------------------------------------
// GatoScreen
// ---------------------------------------------------------------------------
class GatoScreen extends StatefulWidget {
  const GatoScreen({super.key});

  @override
  State<GatoScreen> createState() => _GatoScreenState();
}

class _GatoScreenState extends State<GatoScreen> {
  GamePhase _phase = GamePhase.player1Input;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();

  String _player1Name = '';
  String _player2Name = '';
  String _player1Question = '';
  String _player2Question = '';

  late List<Cell> _board;
  Player _currentPlayer = Player.x;
  Player? _winner;

  // Historial de movimientos por jugador (índices en orden de colocación)
  final List<int> _xMoves = [];
  final List<int> _oMoves = [];

  static const int _maxPieces = 3;

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _initBoard() {
    _board = List.generate(9, (_) => Cell());
    _xMoves.clear();
    _oMoves.clear();
  }

  void _submitInput() {
    final name = _nameController.text.trim();
    final question = _questionController.text.trim();
    if (name.isEmpty || question.isEmpty) return;

    if (_phase == GamePhase.player1Input) {
      _player1Name = name;
      _player1Question = question;
      _nameController.clear();
      _questionController.clear();
      setState(() => _phase = GamePhase.player2Input);
    } else {
      _player2Name = name;
      _player2Question = question;
      _nameController.clear();
      _questionController.clear();
      setState(() => _phase = GamePhase.playing);
    }
  }

  void _onCellTap(int index) {
    if (_phase != GamePhase.playing || _board[index].owner != null) return;

    final moves = _currentPlayer == Player.x ? _xMoves : _oMoves;

    setState(() {
      // Si ya tiene 3 piezas, borrar la más antigua
      if (moves.length >= _maxPieces) {
        final oldest = moves.removeAt(0);
        _board[oldest].owner = null;
        _board[oldest].isFading = false;
      }

      // Marcar la siguiente que se borrará (la más antigua actual)
      // Primero limpiar todos los fading del jugador actual
      for (final m in moves) {
        _board[m].isFading = false;
      }

      // Colocar nueva pieza
      _board[index].owner = _currentPlayer;
      _board[index].isFading = false;
      moves.add(index);

      // Si tiene 3 piezas, marcar la más antigua como "próxima a borrarse"
      if (moves.length == _maxPieces) {
        _board[moves.first].isFading = true;
      }
    });

    final winner = _checkWinner();
    if (winner != null) {
      setState(() {
        _winner = winner;
        _phase = GamePhase.finished;
      });
      Future.delayed(const Duration(milliseconds: 500), _showResultDialog);
      return;
    }

    setState(() {
      _currentPlayer = _currentPlayer == Player.x ? Player.o : Player.x;

      // Marcar la más antigua del siguiente jugador
      final nextMoves = _currentPlayer == Player.x ? _xMoves : _oMoves;
      for (final m in nextMoves) {
        _board[m].isFading = false;
      }
      if (nextMoves.length == _maxPieces) {
        _board[nextMoves.first].isFading = true;
      }
    });
  }

  Player? _checkWinner() {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final line in lines) {
      final a = _board[line[0]].owner;
      final b = _board[line[1]].owner;
      final c = _board[line[2]].owner;
      if (a != null && a == b && b == c) return a;
    }
    return null;
  }

  void _resetGame() {
    _nameController.clear();
    _questionController.clear();
    _player1Name = '';
    _player2Name = '';
    _player1Question = '';
    _player2Question = '';
    _currentPlayer = Player.x;
    _winner = null;
    _initBoard();
    setState(() => _phase = GamePhase.player1Input);
  }

  // ---------------------------------------------------------------------------
  // Diálogos
  // ---------------------------------------------------------------------------
  void _showResultDialog() {
    final isXWinner = _winner == Player.x;
    final winnerName = isXWinner ? _player1Name : _player2Name;
    final loserName = isXWinner ? _player2Name : _player1Name;
    final question = isXWinner ? _player1Question : _player2Question;
    final color = isXWinner ? const Color(0xFFD94F5C) : const Color(0xFFAB5FD4);
    final bgColor = isXWinner
        ? const Color(0xFFFFE4E6)
        : const Color(0xFFF3E8FF);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isXWinner ? '✕' : '○',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¡$winnerName gana!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$loserName debe responder:',
                style: const TextStyle(fontSize: 13, color: Color(0xFF9E8A8A)),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '"$question"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/minigames');
                      },
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
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Otra ronda',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          GamePhase.player1Input => _buildInputPhase(playerNum: 1),
          GamePhase.player2Input => _buildInputPhase(playerNum: 2),
          GamePhase.playing || GamePhase.finished => _buildBoardPhase(),
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pantalla de nombre + pregunta
  // ---------------------------------------------------------------------------
  Widget _buildInputPhase({required int playerNum}) {
    final isPlayer1 = playerNum == 1;
    final color = isPlayer1 ? const Color(0xFFD94F5C) : const Color(0xFFAB5FD4);
    final symbol = isPlayer1 ? '✕' : '○';

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
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'JUGADOR $playerNum',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tu nombre y tu pregunta',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Si ganas, el otro deberá responder tu pregunta.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 28),
          _buildField(
            controller: _nameController,
            hint: 'Tu nombre',
            maxLines: 1,
            color: color,
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: _questionController,
            hint: '¿Cuál es tu mayor secreto?',
            maxLines: 3,
            color: color,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitInput,
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
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1A1A1A),
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          contentPadding: const EdgeInsets.all(18),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pantalla de tablero
  // ---------------------------------------------------------------------------
  Widget _buildBoardPhase() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildTopBar(),
          const SizedBox(height: 28),
          _buildTurnIndicator(),
          const SizedBox(height: 16),
          _buildPieceCounters(),
          const SizedBox(height: 28),
          _buildBoard(),
        ],
      ),
    );
  }

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
        const Text(
          'GATO CON CASTIGO',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
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

  Widget _buildTurnIndicator() {
    if (_phase == GamePhase.finished) return const SizedBox.shrink();
    final isX = _currentPlayer == Player.x;
    final color = isX ? const Color(0xFFD94F5C) : const Color(0xFFAB5FD4);
    final name = isX ? _player1Name : _player2Name;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_currentPlayer),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isX ? '✕' : '○',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Turno de $name',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Muestra cuántas piezas tiene cada jugador y cuál se borrará
  Widget _buildPieceCounters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _PieceCounter(
          name: _player1Name,
          symbol: '✕',
          color: const Color(0xFFD94F5C),
          placed: _xMoves.length,
          max: _maxPieces,
          nextToRemove: _xMoves.isNotEmpty && _xMoves.length == _maxPieces
              ? _xMoves.first
              : null,
        ),
        _PieceCounter(
          name: _player2Name,
          symbol: '○',
          color: const Color(0xFFAB5FD4),
          placed: _oMoves.length,
          max: _maxPieces,
          nextToRemove: _oMoves.isNotEmpty && _oMoves.length == _maxPieces
              ? _oMoves.first
              : null,
        ),
      ],
    );
  }

  Widget _buildBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 9,
        itemBuilder: (_, i) => _buildCell(i),
      ),
    );
  }

  Widget _buildCell(int index) {
    final cell = _board[index];
    final isOwned = cell.owner != null;
    final isX = cell.owner == Player.x;
    final color = isX ? const Color(0xFFD94F5C) : const Color(0xFFAB5FD4);

    return GestureDetector(
      onTap: () => _onCellTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOwned
                ? (cell.isFading
                      ? color.withValues(alpha: 0.15)
                      : color.withValues(alpha: 0.35))
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isOwned
              ? AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  // La pieza más antigua aparece semitransparente
                  opacity: cell.isFading ? 0.25 : 1.0,
                  child: Text(
                    isX ? '✕' : '○',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget contador de piezas
// ---------------------------------------------------------------------------
class _PieceCounter extends StatelessWidget {
  const _PieceCounter({
    required this.name,
    required this.symbol,
    required this.color,
    required this.placed,
    required this.max,
    this.nextToRemove,
  });

  final String name;
  final String symbol;
  final Color color;
  final int placed;
  final int max;
  final int? nextToRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(max, (i) {
            final isPlaced = i < placed;
            final isOldest = placed == max && i == 0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPlaced
                      ? (isOldest ? color.withValues(alpha: 0.25) : color)
                      : color.withValues(alpha: 0.1),
                ),
              ),
            );
          }),
        ),
        if (placed == max)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'se borrará la más antigua',
              style: TextStyle(
                fontSize: 9,
                color: color.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }
}
