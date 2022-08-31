
import 'package:contacts/extensions/string_extension.dart';
import 'package:flutter/material.dart';

import '../models/contact_type.dart';

class ContactTypeHelper {
  static Icon getIconByContactType(ContactType type) {
    switch (type) {
      case ContactType.cellphone:
        return Icon(Icons.phone_android, color: Colors.green[700]);
      case ContactType.work:
        return Icon(Icons.work, color: Colors.brown[600]);
      case ContactType.favorite:
        return Icon(Icons.star, color: Colors.yellow[600]);
      case ContactType.home:
        return Icon(Icons.home, color: Colors.purple[600]);
    }
  }

  static Row getContactTypeRow(ContactType type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [getContactTypeAvatar(type), getContactTypeText(type)],
    );
  }

  static getContactTypeAvatar(ContactType type) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: SizedBox(
        key: const Key("ContactTypeAvatar"),
        height: 40,
        width: 40,
        child: CircleAvatar(
          backgroundColor: Colors.grey[50],
          child: ContactTypeHelper.getIconByContactType(type),
        ),
      ),
    );
  }

  static getContactTypeText(ContactType type) {
    return Text(
      type.name.capitalize(),
      key: const Key("ContactTypeText"),
    );
  }
}
