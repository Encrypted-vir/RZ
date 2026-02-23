//lib/screens/conversation/conversation_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rz/models/capsule_item.dart';
import 'package:rz/providers/capsule_provider.dart';

class ConversationScreen extends StatelessWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el listenable desde el provider, no desde Hive directamente
    final listenable = context.read<CapsuleProvider>().listenable;

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
              child: ValueListenableBuilder<Box<CapsuleItem>>(
                valueListenable: listenable,
                builder: (context, box, _) {
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
                        // ✅ Elimina a través del provider, no directo a Hive
                        onDismissed: (_) => context
                            .read<CapsuleProvider>()
                            .deleteCapsule(capsule),
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
// Capsule Card — lógica de negocio delegada al modelo
// ---------------------------------------------------------------------------
class _CapsuleCard extends StatelessWidget {
  const _CapsuleCard({required this.capsule});

  final CapsuleItem capsule;

  @override
  Widget build(BuildContext context) {
    // ✅ Ya no calculamos nada aquí — el modelo lo expone
    final isUnlocked = capsule.isUnlocked;
    final countdown = capsule.countdownText;

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
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        title: Text('Mensaje de ${capsule.from}'),
        content: Text(capsule.content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
