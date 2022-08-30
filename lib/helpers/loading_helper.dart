import 'package:flutter/material.dart';

class LoadingHelper {
  static Widget showButtonLoading({Color? widgetColor}) {
    return SizedBox(
      width: 20,
      height: 20,
      child: showLoading(widgetColor: widgetColor ?? Colors.white),
    );
  }

  static Widget showLoading({Color? widgetColor}) {
    return Center(
      child: CircularProgressIndicator(
        color: widgetColor,
      ),
    );
  }
}
