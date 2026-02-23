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

  bool get isUnlocked =>
      isInstant || (unlockDate != null && DateTime.now().isAfter(unlockDate!));

  Duration? get remainingTime {
    if (isInstant || unlockDate == null) return null;
    final diff = unlockDate!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String get countdownText {
    final d = remainingTime;
    if (d == null) return '';
    return '${d.inDays}D ${d.inHours % 24}H ${d.inMinutes % 60}M';
  }
}
