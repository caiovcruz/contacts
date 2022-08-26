import 'package:flutter/material.dart';

class NavigatorHelper {
  navigateToWidget(BuildContext context, Widget page,
      {bool removeUntil = false}) {
    if (removeUntil) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => page),
        (_) => false,
      );
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    }

    return this;
  }

  navigateToRoute(BuildContext context, String route,
      {bool removeUntil = false}) {
    if (removeUntil) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        route,
        (_) => false,
      );
    } else {
      Navigator.of(context).pushNamed(route);
    }

    return this;
  }

  popRoute(BuildContext context) {
    Navigator.of(context).pop();

    return this;
  }
}
