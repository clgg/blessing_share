import 'package:flutter/material.dart';

/// Like [IndexedStack], but only builds each child the first time it is shown.
///
/// Keeps already-built children alive so tab switches stay instant, without
/// paying for Favorites / Profile work on cold start.
class LazyIndexedStack extends StatefulWidget {
  const LazyIndexedStack({
    required this.index,
    required this.itemCount,
    required this.itemBuilder,
    super.key,
  });

  final int index;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late final List<Widget?> _children =
      List<Widget?>.filled(widget.itemCount, null);

  @override
  void didUpdateWidget(covariant LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      final next = List<Widget?>.filled(widget.itemCount, null);
      for (var i = 0; i < next.length && i < _children.length; i++) {
        next[i] = _children[i];
      }
      _children
        ..clear()
        ..addAll(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    _children[widget.index] ??= widget.itemBuilder(context, widget.index);
    return IndexedStack(
      index: widget.index,
      sizing: StackFit.expand,
      children: [
        for (var i = 0; i < widget.itemCount; i++)
          _children[i] ?? const SizedBox.shrink(),
      ],
    );
  }
}
