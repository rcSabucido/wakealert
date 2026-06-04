import 'package:flutter/material.dart';

class ScreenLoader {
  static OverlayEntry? _entry;

  /// Show the loader on the *root* overlay (the one that covers the whole app).
  static void show(BuildContext context) {
    if (_entry != null) return;                 // already visible

    _entry = OverlayEntry(
      builder: (_) => const _LoaderOverlay(),
    );

    // Always insert into the root overlay attached to the given context
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  /// Hide the loader.
  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

/// The actual overlay UI
class _LoaderOverlay extends StatelessWidget {
  const _LoaderOverlay();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54, // semi-transparent grey
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      ),
    );
  }
}