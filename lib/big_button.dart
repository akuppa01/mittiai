import 'package:flutter/material.dart';

class BigButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String? semanticsLabel;
  const BigButton({super.key, required this.onPressed, required this.child, this.semanticsLabel});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: child,
      ),
    );
  }
}
