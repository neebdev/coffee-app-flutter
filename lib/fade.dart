import 'package:flutter/material.dart';

class FadeTransitionWidget extends StatefulWidget {
  final bool visible;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Widget child;

  const FadeTransitionWidget({
    super.key,
    required this.visible,
    required this.fadeInDuration,
    required this.fadeOutDuration,
    required this.child,
  });

  @override
  _FadeTransitionWidgetState createState() => _FadeTransitionWidgetState();
}

class _FadeTransitionWidgetState extends State<FadeTransitionWidget> {
  bool isVisible = true;

  @override
  void didUpdateWidget(covariant FadeTransitionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.visible) {
      Future.delayed(widget.fadeOutDuration, () {
        if (!widget.visible) {
          setState(() {
            isVisible = false;
          });
        }
      });
    } else {
      setState(() {
        isVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.visible ? 1.0 : 0.0,
      duration: widget.visible ? widget.fadeInDuration : widget.fadeOutDuration,
      curve: Curves.easeIn,
      child: isVisible ? widget.child : const SizedBox.shrink(),
    );
  }
}
