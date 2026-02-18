class CapsuleItem {
  final String from;
  final bool isUnlocked;
  final String? unlockCountdown;

  const CapsuleItem({
    required this.from,
    required this.isUnlocked,
    this.unlockCountdown,
  });
}
