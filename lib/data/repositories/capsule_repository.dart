//lib/data/repositories/capsule_repository.dart
import 'package:hive/hive.dart';
import '../../models/capsule_item.dart';

class CapsuleRepository {
  final Box<CapsuleItem> _box = Hive.box<CapsuleItem>('capsules');

  // Obtener todas las cápsulas
  List<CapsuleItem> getAll() => _box.values.toList();

  // Agregar una cápsula
  Future<void> add(CapsuleItem capsule) async {
    await _box.add(capsule);
  }

  // Eliminar por índice
  Future<void> deleteAt(int index) async {
    await _box.deleteAt(index);
  }

  // Escuchar cambios en tiempo real (para ValueListenableBuilder)
  Box<CapsuleItem> get listenable => _box;
}
