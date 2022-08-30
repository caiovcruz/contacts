import 'package:flutter/material.dart';

import '../helpers/navigator_helper.dart';

AppBar getMenuAppBar(BuildContext context, String pageName,
    {List<Widget>? actions}) {
  return AppBar(
    title: Text(pageName),
    centerTitle: true,
    actions: actions,
    flexibleSpace: Container(
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
    ),
  );
}

AppBar getEditingAppBar(BuildContext context, String pageName,
    {String? leadingText, Function? leadingFunction, List<Widget>? actions}) {
  return AppBar(
    automaticallyImplyLeading: false,
    leadingWidth: 70.0,
    leading: TextButton(
      onPressed: leadingFunction != null
          ? leadingFunction.call()
          : () => NavigatorHelper().popRoute(context),
      child: Text(
        leadingText ?? "Cancel",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    title: Text(pageName),
    centerTitle: true,
    actions: actions,
    flexibleSpace: Container(
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
    ),
  );
}
