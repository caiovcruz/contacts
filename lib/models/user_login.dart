import 'user_type.dart';

class UserLogin {
  int? id;
  String? email;
  String? password;
  UserType? type;

  UserLogin({this.id, this.email, this.password, this.type});

  UserLogin.fromJson(Map<String, dynamic> json) {
    id = json['id'];
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLogin &&
          runtimeType == other.runtimeType &&
          id != other.id &&
          email == other.email;

  @override
  int get hashCode => email.hashCode;
}
