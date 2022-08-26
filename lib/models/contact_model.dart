import 'package:contacts/models/contact_type.dart';
import 'package:mobx/mobx.dart';

import 'contact.dart';

part "contact_model.g.dart";

class ContactModel = BaseContactModel with _$ContactModel;

abstract class BaseContactModel with Store {
  int? id;
  int? userId;

  @observable
  String? name;

  @observable
  String? email;

  String? cpf;
  String? phone;

  @observable
  ContactType? type;

  @action
  setName(String name) {
    this.name = name;
  }

  @action
  setEmail(String email) {
    this.email = email;
  }

  @action
  setType(ContactType type) {
    this.type = type;
  }

  BaseContactModel(
      {this.id, this.userId, this.name, this.email, this.cpf, this.phone, this.type});

  BaseContactModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    name = json['name'];
    email = json['email'];
    cpf = json['cpf'];
    phone = json['phone'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['name'] = name;
    data['email'] = email;
    data['cpf'] = cpf;
    data['phone'] = phone;
    data['type'] = type;
    return data;
  }

  Contact toContact() {
    return Contact(
      id: id,
      userId: userId,
      name: name,
      email: email,
      cpf: cpf,
      phone: phone,
      type: type,
    );
  }

  static ContactModel fromContact(Contact contact) {
    return ContactModel(
      id: contact.id,
      userId: contact.userId,
      name: contact.name,
      email: contact.email,
      cpf: contact.cpf,
      phone: contact.phone,
      type: contact.type,
    );
  }
}
