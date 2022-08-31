import 'package:flutter/material.dart';

class ColoredSafeArea extends StatelessWidget {
  final Widget child;

  const ColoredSafeArea({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple,
            Colors.deepPurple,
          ],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      child: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        ),
      ),
    );
  }
}
