import 'package:mobx/mobx.dart';

import 'user_login.dart';
import 'user_type.dart';

part "user_login_model.g.dart";

class UserLoginModel = BaseUserLoginModel with _$UserLoginModel;

abstract class BaseUserLoginModel with Store {
  int? id;

  @observable
  String? email;

  @observable
  String? password;

  @observable
  UserType? type;

  @action
  setEmail(String email) {
    this.email = email;
  }

  @action
  setPassword(String password) {
    this.password = password;
  }

  @action
  setType(UserType type) {
    this.type = type;
  }

  BaseUserLoginModel(
      {this.id,
      this.email,
      this.password,
      this.type});

  BaseUserLoginModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['password'] = password;
    data['type'] = type;
    return data;
  }

  UserLogin toUserLogin() {
    return UserLogin(
      id: id,
      email: email,
      password: password,
      type: type,
    );
  }

  static UserLoginModel fromUserLogin(UserLogin userLogin) {
    return UserLoginModel(
      id: userLogin.id,
      email: userLogin.email,
      password: userLogin.password,
      type: userLogin.type,
    );
  }
}
