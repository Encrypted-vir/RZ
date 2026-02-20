//lib/screens/game/capsule_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/capsule_item.dart';
import '../../providers/capsule_provider.dart';

class CapsuleScreen extends StatefulWidget {
  final String mode;

  const CapsuleScreen({super.key, required this.mode});

  @override
  State<CapsuleScreen> createState() => _CapsuleScreenState();
}

class _CapsuleScreenState extends State<CapsuleScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reflectionController = TextEditingController();
  String? _selectedDate;

  final List<String> _dateOptions = [
    'Sin fecha (abrir ahora)',
    'En 12 horas',
    'En 1 día',
    'En 3 días',
    'En 7 días',
    'En 1 mes',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  DateTime _convertToDate(String? option) {
    final now = DateTime.now();
    switch (option) {
      case 'Sin fecha (abrir ahora)':
        return now;
      case 'En 12 horas':
        return now.add(const Duration(hours: 12));
      case 'En 1 día':
        return now.add(const Duration(days: 1));
      case 'En 3 días':
        return now.add(const Duration(days: 3));
      case 'En 7 días':
        return now.add(const Duration(days: 7));
      case 'En 1 mes':
        return now.add(const Duration(days: 30));
      default:
        return now;
    }
  }

  Color get _accentColor {
    switch (widget.mode) {
      case 'amigos':
        return const Color(0xFFE07B3A);
      case 'citas':
        return const Color(0xFFAB5FD4);
      case 'picante':
        return const Color(0xFFE05C2A);
      default:
        return const Color(0xFFD94F5C);
    }
  }

  Color get _bgColor {
    switch (widget.mode) {
      case 'amigos':
        return const Color(0xFFFFF8F0);
      case 'citas':
        return const Color(0xFFF9F0FF);
      case 'picante':
        return const Color(0xFFFFF3EE);
      default:
        return const Color(0xFFFDF5EF);
    }
  }

  void _onSealMoment() {
    final name = _nameController.text.trim();

    if (_reflectionController.text.trim().isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe tu reflexión y elige una fecha')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_rounded, color: _accentColor, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Momento sellado!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu cápsula quedó guardada.\nSolo podrá abrirse en la fecha elegida.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9E8A8A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final capsule = CapsuleItem(
                    from: name.isNotEmpty ? name : 'Anónimo',
                    content: _reflectionController.text.trim(),
                    unlockDate: _convertToDate(_selectedDate),
                  );

                  Provider.of<CapsuleProvider>(
                    context,
                    listen: false,
                  ).addCapsule(capsule);

                  Navigator.pop(dialogContext);
                  context.go(
                    '/capsules',
                  ); // 👈 una sola línea, va al tab correcto
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Ver mis cápsulas',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(), // 👈 go_router
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 24,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Cápsula de Sentimientos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_open_rounded,
                          color: _accentColor,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Un mensaje para el futuro',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Escribe hoy lo que tu corazón siente. Solo\npodrá ser leído en la fecha que elijas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E8A8A),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildLabel('¿CON QUIÉN JUGASTE?'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Nombre de tu acompañante...',
                      suffixIcon: Icons.person_outline_rounded,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('TU REFLEXIÓN ÍNTIMA'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _reflectionController,
                      hint: 'Mis pensamientos hoy son...',
                      maxLines: 5,
                      showPrivacyNote: true,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('¿CUÁNDO DEBE ABRIRSE?'),
                    const SizedBox(height: 8),
                    _buildDateDropdown(),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _accentColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shield_outlined,
                              color: _accentColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Al sellar este momento, el contenido permanecerá oculto bajo llave hasta la fecha acordada.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9E8A8A),
                                height: 1.5,
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
                      child: ElevatedButton.icon(
                        onPressed: _onSealMoment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        icon: const Icon(Icons.copy_outlined, size: 20),
                        label: const Text(
                          'Sellar Momento',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'SOULSYNC INTIMACY PROTOCOL © 2024',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.4,
                          color: _accentColor.withValues(alpha: 0.35),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _accentColor,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? suffixIcon,
    bool showPrivacyNote = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFCCBBBB),
              ),
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: const Color(0xFFCCBBBB), size: 20)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                showPrivacyNote ? 32 : 14,
              ),
            ),
          ),
          if (showPrivacyNote)
            Positioned(
              bottom: 10,
              right: 14,
              child: Text(
                'Privado y encriptado',
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFFCCBBBB),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          Icons.calendar_today_outlined,
          color: _accentColor,
          size: 22,
        ),
        title: Text(
          _selectedDate ?? 'Fecha de apertura',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: _selectedDate == null
            ? const Text(
                'Selecciona un momento especial',
                style: TextStyle(fontSize: 12, color: Color(0xFF9E8A8A)),
              )
            : null,
        trailing: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF9E8A8A),
        ),
        onTap: _showDateOptions,
      ),
    );
  }

  void _showDateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0D0D0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Cuándo abrir la cápsula?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            ..._dateOptions.map(
              (option) => ListTile(
                title: Text(option, style: const TextStyle(fontSize: 15)),
                leading: Icon(
                  Icons.schedule_rounded,
                  color: _accentColor,
                  size: 20,
                ),
                trailing: _selectedDate == option
                    ? Icon(Icons.check_rounded, color: _accentColor)
                    : null,
                onTap: () {
                  setState(() => _selectedDate = option);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
