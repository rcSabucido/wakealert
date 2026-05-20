import 'package:flutter/material.dart';
import 'outbox_repository.dart';

/// Simple inherited widget that gives every descendant
/// access to the same OutboxRepository instance.
class OutboxProvider extends InheritedWidget {
  const OutboxProvider({
    super.key,
    required this.repository,
    required super.child,
  });

  final OutboxRepository repository;

  static OutboxRepository of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<OutboxProvider>();
    assert(provider != null, 'No OutboxProvider above this widget');
    return provider!.repository;
  }

  @override
  bool updateShouldNotify(OutboxProvider old) => repository != old.repository;
}
