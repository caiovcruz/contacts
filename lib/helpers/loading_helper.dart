import 'package:flutter/material.dart';

class LoadingHelper {
  static Widget showButtonLoading({Color? widgetColor}) {
    return showCenteredLoading(widgetColor: widgetColor);
  }

  static Widget showCenteredLoading({Color? widgetColor}) {
    return Center(
      child: showLoading(widgetColor: widgetColor),
    );
  }

  static Widget showLoading({Color? widgetColor}) {
    return SizedBox(
      width: 20.5,
      height: 20.5,
      child: CircularProgressIndicator(
        color: widgetColor ?? Colors.grey[50],
      ),
    );
  }
}
