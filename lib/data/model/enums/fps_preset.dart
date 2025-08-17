enum FpsPreset {
  fps30("30", 30),
  fps60("60", 60);

  final String label;
  final int value;

  const FpsPreset(this.label, this.value);

  @override
  String toString() => label; // "30", "60"
}
