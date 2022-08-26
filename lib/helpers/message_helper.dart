import 'package:flutter/material.dart';

class MessageHelper {
  static Set<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>>
      showSuccessMessage(BuildContext context, String message) {
    return {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ))
    };
  }

  static Set<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>>
      showInfoMessage(BuildContext context, String message) {
    return {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.lightBlue,
      ))
    };
  }

  static Set<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>>
      showErrorMessage(BuildContext context, String message) {
    return {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ))
    };
  }
}
