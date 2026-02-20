//lib/providers/capsule_provider.dart
import 'package:flutter/material.dart';
import '../models/capsule_item.dart';
import '../data/repositories/capsule_repository.dart';

class CapsuleProvider extends ChangeNotifier {
  final CapsuleRepository _repository;

  // El repository se inyecta, no se crea aquí
  CapsuleProvider(this._repository);

  List<CapsuleItem> get capsules => _repository.getAll();

  void addCapsule(CapsuleItem capsule) {
    _repository.add(capsule);
    notifyListeners();
  }

  void deleteCapsule(int index) {
    _repository.deleteAt(index);
    notifyListeners();
  }
}