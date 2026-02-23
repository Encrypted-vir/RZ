//lib/data/repositories/capsule_repository.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart'; 
import '../../models/capsule_item.dart';

class CapsuleRepository {
  final Box<CapsuleItem> _box = Hive.box<CapsuleItem>('capsules');

  // Obtener todas las cápsulas
  List<CapsuleItem> getAll() => _box.values.toList();

  // Agregar una cápsula
  Future<void> add(CapsuleItem capsule) async {
    await _box.add(capsule);
  }

  // ✅ deleteAt eliminado — ahora se elimina por objeto desde el provider

  // Escuchar cambios en tiempo real (para ValueListenableBuilder)
  ValueListenable<Box<CapsuleItem>> get listenable =>
      _box.listenable(); // 👈 dos cambios aquí
}
