// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_login_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserLoginModel on BaseUserLoginModel, Store {
  late final _$emailAtom =
      Atom(name: 'BaseUserLoginModel.email', context: context);

  @override
  String? get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String? value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  late final _$passwordAtom =
      Atom(name: 'BaseUserLoginModel.password', context: context);

  @override
  String? get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String? value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  late final _$typeAtom =
      Atom(name: 'BaseUserLoginModel.type', context: context);

  @override
  UserType? get type {
    _$typeAtom.reportRead();
    return super.type;
  }

  @override
  set type(UserType? value) {
    _$typeAtom.reportWrite(value, super.type, () {
      super.type = value;
    });
  }

  late final _$BaseUserLoginModelActionController =
      ActionController(name: 'BaseUserLoginModel', context: context);

  @override
  dynamic setEmail(String email) {
    final _$actionInfo = _$BaseUserLoginModelActionController.startAction(
        name: 'BaseUserLoginModel.setEmail');
    try {
      return super.setEmail(email);
    } finally {
      _$BaseUserLoginModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setPassword(String password) {
    final _$actionInfo = _$BaseUserLoginModelActionController.startAction(
        name: 'BaseUserLoginModel.setPassword');
    try {
      return super.setPassword(password);
    } finally {
      _$BaseUserLoginModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setType(UserType type) {
    final _$actionInfo = _$BaseUserLoginModelActionController.startAction(
        name: 'BaseUserLoginModel.setType');
    try {
      return super.setType(type);
    } finally {
      _$BaseUserLoginModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
email: ${email},
password: ${password},
type: ${type}
    ''';
  }
}
