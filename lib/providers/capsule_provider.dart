import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/capsule_item.dart';

class CapsuleProvider extends ChangeNotifier {
  final Box<CapsuleItem> _capsuleBox = Hive.box<CapsuleItem>('capsules');

  List<CapsuleItem> get capsules => _capsuleBox.values.toList();

  void addCapsule(CapsuleItem capsule) {
    _capsuleBox.add(capsule);
    notifyListeners();
  }

  void deleteCapsule(int index) {
    _capsuleBox.deleteAt(index);
    notifyListeners();
  }
}
