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
        style: TextStyle(
          color: Colors.grey[50],
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

PreferredSize getModalEditingAppBar(BuildContext context, String pageName,
    {String? leadingText, Function? leadingFunction, List<Widget>? actions}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(25.0),
    child: Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        gradient: LinearGradient(
          colors: [
            Colors.purple,
            Colors.deepPurple,
          ],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: leadingFunction != null
                  ? leadingFunction.call()
                  : () => NavigatorHelper().popRoute(context),
              child: Text(
                leadingText ?? "Cancel",
                style: TextStyle(
                  color: Colors.grey[50],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              pageName,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.grey[50],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: actions ?? [],
            ),
          )
        ],
      ),
    ),
  );
}
