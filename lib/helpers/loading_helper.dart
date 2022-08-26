import 'package:flutter/material.dart';

class LoadingHelper {
  static SizedBox showButtonLoading({Color? widgetColor}) {
    return SizedBox(
      width: 20,
      height: 20,
      child: showLoading(widgetColor: widgetColor ?? Colors.white),
    );
  }

  static CircularProgressIndicator showLoading({Color? widgetColor}) {
    return CircularProgressIndicator(
      color: widgetColor,
    );
  }
}
