import 'package:flutter/material.dart';

class MDevFloatingBtn extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;

  const MDevFloatingBtn({
    super.key,
    this.onPressed,
    this.icon = Icons.bug_report,
  });

  @override
  Widget build(BuildContext context) {
    const bool isDevMode = true;

    if (!isDevMode) return const SizedBox.shrink();

    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}
