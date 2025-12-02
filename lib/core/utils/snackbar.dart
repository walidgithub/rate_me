import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning }

void showAppSnackBar(
    BuildContext context,
    String message, {
      SnackBarType type = SnackBarType.success,
    }) {
  Color color;
  switch (type) {
    case SnackBarType.success:
      color = Colors.green;
      break;
    case SnackBarType.error:
      color = Colors.redAccent;
      break;
    case SnackBarType.warning:
      color = Colors.deepOrangeAccent;
      break;
  }

  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) =>
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(const Duration(seconds: 2), overlayEntry.remove);
}
