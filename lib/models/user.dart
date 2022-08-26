import 'user_gender.dart';
import 'user_type.dart';

class User {
  int? id;
  String? name;
  String? email;
  String? password;
  DateTime? dateOfBirth;
  UserGender? gender;
  String? phone;
  UserType? type;
  String? profileImagePath;

  User(
      {this.id,
      this.name,
      this.email,
      this.password,
      this.dateOfBirth,
      this.gender,
      this.phone,
      this.type,
      this.profileImagePath});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    dateOfBirth = DateTime.tryParse(json['dateOfBirth']);
    gender = UserGender.values[json['gender']];
    phone = json['phone'];
    type = UserType.values[json['type']];
    profileImagePath = json['profileImagePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['dateOfBirth'] = dateOfBirth.toString();
    data['gender'] = gender?.index;
    data['phone'] = phone;
    data['type'] = type?.index;
    data['profileImagePath'] = profileImagePath;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id != other.id &&
          email == other.email;

  @override
  int get hashCode => email.hashCode;
}
