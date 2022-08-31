import 'package:contacts/extensions/string_extension.dart';
import 'package:flutter/material.dart';

import '../models/user_gender.dart';

class UserGenderHelper {
  static Icon getIconByUserGender(UserGender gender) {
    switch (gender) {
      case UserGender.male:
        return const Icon(Icons.male, color: Colors.blue);
      case UserGender.female:
        return Icon(Icons.female, color: Colors.pink[100]);
      case UserGender.undefined:
        return const Icon(Icons.circle_outlined, color: Colors.black);
    }
  }

  static Row getUserGenderRow(UserGender gender) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [getUserGenderAvatar(gender), getUserGenderText(gender)],
    );
  }

  static getUserGenderAvatar(UserGender gender) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: SizedBox(
        key: const Key("UserGenderAvatar"),
        height: 40,
        width: 40,
        child: CircleAvatar(
          backgroundColor: Colors.grey[50],
          child: UserGenderHelper.getIconByUserGender(gender),
        ),
      ),
    );
  }

  static getUserGenderText(UserGender gender) {
    return Text(
      gender.name.capitalize(),
      key: const Key("UserGenderText"),
    );
  }
}
