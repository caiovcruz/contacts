import 'package:flutter/material.dart';

class GradientElevatedButton extends StatelessWidget {
  const GradientElevatedButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.gradient,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onPressed;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // ElevatedButton has default 5 padding on top and bottom
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      // DecoratedBox contains our linear gradient
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient ??
              const LinearGradient(
                colors: [
                  Colors.purple,
                  Colors.deepPurple,
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
          // Round the DecoratedBox to match ElevatedButton
          borderRadius: BorderRadius.circular(5),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          // Duplicate the default styling of an ElevatedButton
          style: ElevatedButton.styleFrom(
            // Enables us to see the BoxDecoration behind the ElevatedButton
            primary: Colors.transparent,
            // Fits the Ink in the BoxDecoration
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ).merge(
            ButtonStyle(
              // Elevation declared here so we can cover onPress elevation
              // Declaring in styleFrom does not allow for MaterialStateProperty
              elevation: MaterialStateProperty.all(0),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
