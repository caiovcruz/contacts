import 'contact_type.dart';

class Contact {
  int? id;
  int? userId;
  String? name;
  String? email;
  String? cpf;
  String? phone;
  ContactType? type;

  Contact({this.id, this.userId, this.name, this.email, this.cpf, this.phone, this.type});

  Contact.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    name = json['name'];
    email = json['email'];
    cpf = json['cpf'];
    phone = json['phone'];
    type = ContactType.values[json['type']];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['name'] = name;
    data['email'] = email;
    data['cpf'] = cpf;
    data['phone'] = phone;
    data['type'] = type?.index;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact &&
          runtimeType == other.runtimeType &&
          id != other.id &&
          phone == other.phone;

  @override
  int get hashCode => phone.hashCode;
}
