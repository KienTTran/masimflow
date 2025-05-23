import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// https://stackoverflow.com/a/73770670
class HoverBuilder extends StatefulWidget {
  const HoverBuilder({
    required this.builder,
    Key? key,
  }) : super(key: key);

  final Widget Function(bool isHovered) builder;

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) => _onHoverChanged(enabled: true),
      onExit: (PointerExitEvent event) => _onHoverChanged(enabled: false),
      child: widget.builder(_isHovered),
    );
  }

  void _onHoverChanged({required bool enabled}) {
    setState(() {
      _isHovered = enabled;
    });
  }
}