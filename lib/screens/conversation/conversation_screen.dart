import 'package:flutter/material.dart';
import 'package:rz/models/capsule_item.dart';

// ---------------------------------------------------------------------------
// ConversationScreen
// ---------------------------------------------------------------------------
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => ConversationScreenState();
}

// Estado PÚBLICO para que GlobalKey pueda accederlo desde main_screen
class ConversationScreenState extends State<ConversationScreen> {
  // Datos de ejemplo para previsualizar el diseño
  final List<CapsuleItem> _capsules = [
    const CapsuleItem(
      from: 'Valentina',
      isUnlocked: false,
      unlockCountdown: '12D 05H 20M',
    ),
    const CapsuleItem(from: 'Mateo', isUnlocked: true),
    const CapsuleItem(
      from: 'El Equipo',
      isUnlocked: false,
      unlockCountdown: '03D 14H 05M',
    ),
    const CapsuleItem(from: 'Sofía', isUnlocked: true),
  ];

  void addCapsule(CapsuleItem capsule) {
    setState(() => _capsules.add(capsule));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 24,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Cápsulas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24), // balance
                ],
              ),
            ),

            // Lista o estado vacío
            Expanded(
              child: _capsules.isEmpty
                  ? _buildEmptyState()
                  : _buildCapsuleList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFD94F5C).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFFD94F5C),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún no hay cápsulas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Juega una partida y sella un momento',
            style: TextStyle(fontSize: 13, color: Color(0xFF9E8A8A)),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsuleList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _capsules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _CapsuleCard(capsule: _capsules[index]),
    );
  }
}

// ---------------------------------------------------------------------------
// Capsule Card
// ---------------------------------------------------------------------------
class _CapsuleCard extends StatelessWidget {
  const _CapsuleCard({required this.capsule});

  final CapsuleItem capsule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: capsule.isUnlocked
            ? Border.all(
                color: const Color(0xFFD94F5C).withValues(alpha: 0.35),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          // Info izquierda
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'De: ${capsule.from}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                capsule.isUnlocked
                    ? const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: Color(0xFFD94F5C),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '¡LISTA PARA ABRIR!',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD94F5C),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: Color(0xFF9E8A8A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'DESBLOQUEA EN: ${capsule.unlockCountdown}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9E8A8A),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Botón derecha
          capsule.isUnlocked
              ? ElevatedButton(
                  onPressed: () {
                    // TODO: abrir cápsula
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD94F5C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Abrir ahora',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Bloqueada',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9E8A8A),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
