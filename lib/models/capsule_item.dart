import 'package:hive/hive.dart';

part 'capsule_item.g.dart';

@HiveType(typeId: 0)
class CapsuleItem extends HiveObject {
  @HiveField(0)
  final String from;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime? unlockDate;

  @HiveField(3)
  final bool isInstant;

  CapsuleItem({
    required this.from,
    required this.content,
    this.unlockDate,
    this.isInstant = false,
  });
}
