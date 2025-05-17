import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final bool isCorrect;
  final bool isSelected;
  final bool wasAnswered;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.text,
    required this.isCorrect,
    required this.isSelected,
    required this.wasAnswered,
    required this.onTap,
  });

  Color getColor() {
    if (!wasAnswered) return Colors.blue;
    if (isSelected && isCorrect) return Colors.green;
    if (isSelected && !isCorrect) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: getColor(),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
}
