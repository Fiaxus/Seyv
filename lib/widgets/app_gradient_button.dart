import 'package:flutter/material.dart';

class AppGradientButton extends StatelessWidget {
  final String label;

  /// null verilirse buton pasif olur (soluk görünür, tıklanamaz).
  final VoidCallback? onPressed;
  final double? fontSize;

  const AppGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Align(
                  alignment: Alignment.center,
                  heightFactor: 1,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize ?? 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}