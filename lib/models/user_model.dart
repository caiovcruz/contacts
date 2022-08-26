import 'package:contacts/models/copyable.dart';
import 'package:mobx/mobx.dart';

import 'user.dart';
import 'user_gender.dart';
import 'user_type.dart';

part "user_model.g.dart";

class UserModel = BaseUserModel with _$UserModel;

abstract class BaseUserModel with Store implements Copyable<BaseUserModel> {
  int? id;

  @observable
  String? name;

  @observable
  String? email;

  @observable
  String? password;

  @observable
  DateTime? dateOfBirth;

  @observable
  UserGender? gender;

  @observable
  String? phone;

  @observable
  UserType? type;

  @observable
  String? profileImagePath;

  @action
  setName(String name) {
    this.name = name;
  }

  @action
  setEmail(String email) {
    this.email = email;
  }

  @action
  setPassword(String password) {
    this.password = password;
  }

  @action
  setDateOfBirth(DateTime dateOfBirth) {
    this.dateOfBirth = dateOfBirth;
  }

  @action
  setGender(UserGender gender) {
    this.gender = gender;
  }

  @action
  setPhone(String phone) {
    this.phone = phone;
  }

  @action
  setType(UserType type) {
    this.type = type;
  }

  @action
  setProfileImagePath(String profileImagePath) {
    this.profileImagePath = profileImagePath;
  }

  BaseUserModel(
      {this.id,
      this.name,
      this.email,
      this.password,
      this.dateOfBirth,
      this.gender,
      this.phone,
      this.type,
      this.profileImagePath});

  BaseUserModel.fromJson(Map<String, dynamic> json) {
    print(json);
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

  User toUser() {
    return User(
      id: id,
      name: name,
      email: email,
      password: password,
      dateOfBirth: dateOfBirth,
      gender: gender,
      phone: phone,
      type: type,
      profileImagePath: profileImagePath,
    );
  }

  static UserModel fromUser(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      password: user.password,
      dateOfBirth: user.dateOfBirth,
      gender: user.gender,
      phone: user.phone,
      type: user.type,
      profileImagePath: user.profileImagePath,
    );
  }

  @override
  UserModel copy() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      password: password,
      dateOfBirth: dateOfBirth,
      gender: gender,
      phone: phone,
      type: type,
      profileImagePath: profileImagePath,
    );
  }

  @override
  UserModel copyWith(
      {int? id,
      String? name,
      String? email,
      String? password,
      DateTime? dateOfBirth,
      UserGender? gender,
      String? phone,
      UserType? type,
      String? profileImagePath}) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      password: password,
      dateOfBirth: dateOfBirth,
      gender: gender,
      phone: phone,
      type: type,
      profileImagePath: profileImagePath,
    );
  }
}
