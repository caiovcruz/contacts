
import 'package:contacts/extensions/string_extension.dart';
import 'package:flutter/material.dart';

import '../models/user_type.dart';

class UserTypeHelper {
  static Icon getIconByUserType(UserType type) {
    switch (type) {
      case UserType.user:
        return Icon(Icons.account_box_outlined, color: Colors.purple[600]);
      case UserType.admin:
        return const Icon(Icons.verified_user_outlined, color: Colors.black);
      case UserType.company:
        return Icon(Icons.groups_outlined, color: Colors.yellow[600]);
    }
  }

  static Row getUserTypeRow(UserType type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [getUserTypeAvatar(type), getUserTypeText(type)],
    );
  }

  static getUserTypeAvatar(UserType type) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: SizedBox(
        key: const Key("UserTypeAvatar"),
        height: 40,
        width: 40,
        child: CircleAvatar(
          backgroundColor: Colors.grey[50],
          child: UserTypeHelper.getIconByUserType(type),
        ),
      ),
    );
  }

  static getUserTypeText(UserType type) {
    return Text(
      type.name.capitalize(),
      key: const Key("UserTypeText"),
    );
  }
}
