//lib/screens/conversation/conversation_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rz/models/capsule_item.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => ConversationScreenState();
}

class ConversationScreenState extends State<ConversationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar — sin back button (es un tab, no una pantalla push)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Center(
                child: Text(
                  'Cápsulas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<CapsuleItem>('capsules').listenable(),
                builder: (context, Box<CapsuleItem> box, _) {
                  if (box.isEmpty) return _buildEmptyState();

                  final capsules = box.values.toList().reversed.toList();

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: capsules.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final capsule = capsules[index];
                      return Dismissible(
                        key: Key(capsule.key.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => capsule.delete(),
                        child: _CapsuleCard(capsule: capsule),
                      );
                    },
                  );
                },
              ),
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
}

// ---------------------------------------------------------------------------
// Capsule Card (sin cambios)
// ---------------------------------------------------------------------------
class _CapsuleCard extends StatelessWidget {
  const _CapsuleCard({required this.capsule});

  final CapsuleItem capsule;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isUnlocked =
        capsule.isInstant ||
        (capsule.unlockDate != null && now.isAfter(capsule.unlockDate!));

    Duration? difference;
    if (!capsule.isInstant && capsule.unlockDate != null) {
      final diff = capsule.unlockDate!.difference(now);
      difference = diff.isNegative ? Duration.zero : diff;
    }

    String countdown = '';
    if (difference != null) {
      countdown =
          '${difference.inDays}D ${difference.inHours % 24}H ${difference.inMinutes % 60}M';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUnlocked
            ? Border.all(
                color: const Color(0xFFD94F5C).withValues(alpha: 0.35),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
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
                isUnlocked
                    ? const Text(
                        '¡LISTA PARA ABRIR!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD94F5C),
                        ),
                      )
                    : Text(
                        'DESBLOQUEA EN: $countdown',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9E8A8A),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          isUnlocked
              ? ElevatedButton(
                  onPressed: () => _showCapsuleContent(context),
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

  void _showCapsuleContent(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: true, // 👈 esto soluciona el bug
      builder: (_) => AlertDialog(
        title: Text('Mensaje de ${capsule.from}'),
        content: Text(capsule.content),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(), // 👈
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
