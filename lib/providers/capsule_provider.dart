//lib/providers/capsule_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/capsule_item.dart';
import '../data/repositories/capsule_repository.dart';

class CapsuleProvider extends ChangeNotifier {
  final CapsuleRepository _repository;

  CapsuleProvider(this._repository);

  List<CapsuleItem> get capsules => _repository.getAll();

  ValueListenable<Box<CapsuleItem>> get listenable => _repository.listenable;

  void addCapsule(CapsuleItem capsule) {
    _repository.add(capsule);
    notifyListeners();
  }

  void deleteCapsule(CapsuleItem capsule) {
    capsule.delete();
    notifyListeners();
  }
}