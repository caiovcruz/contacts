// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserModel on BaseUserModel, Store {
  late final _$nameAtom = Atom(name: 'BaseUserModel.name', context: context);

  @override
  String? get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String? value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  late final _$emailAtom = Atom(name: 'BaseUserModel.email', context: context);

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
      Atom(name: 'BaseUserModel.password', context: context);

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

  late final _$dateOfBirthAtom =
      Atom(name: 'BaseUserModel.dateOfBirth', context: context);

  @override
  DateTime? get dateOfBirth {
    _$dateOfBirthAtom.reportRead();
    return super.dateOfBirth;
  }

  @override
  set dateOfBirth(DateTime? value) {
    _$dateOfBirthAtom.reportWrite(value, super.dateOfBirth, () {
      super.dateOfBirth = value;
    });
  }

  late final _$genderAtom =
      Atom(name: 'BaseUserModel.gender', context: context);

  @override
  UserGender? get gender {
    _$genderAtom.reportRead();
    return super.gender;
  }

  @override
  set gender(UserGender? value) {
    _$genderAtom.reportWrite(value, super.gender, () {
      super.gender = value;
    });
  }

  late final _$phoneAtom = Atom(name: 'BaseUserModel.phone', context: context);

  @override
  String? get phone {
    _$phoneAtom.reportRead();
    return super.phone;
  }

  @override
  set phone(String? value) {
    _$phoneAtom.reportWrite(value, super.phone, () {
      super.phone = value;
    });
  }

  late final _$typeAtom = Atom(name: 'BaseUserModel.type', context: context);

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

  late final _$profileImagePathAtom =
      Atom(name: 'BaseUserModel.profileImagePath', context: context);

  @override
  String? get profileImagePath {
    _$profileImagePathAtom.reportRead();
    return super.profileImagePath;
  }

  @override
  set profileImagePath(String? value) {
    _$profileImagePathAtom.reportWrite(value, super.profileImagePath, () {
      super.profileImagePath = value;
    });
  }

  late final _$backgroundProfileImagePathAtom =
      Atom(name: 'BaseUserModel.backgroundProfileImagePath', context: context);

  @override
  String? get backgroundProfileImagePath {
    _$backgroundProfileImagePathAtom.reportRead();
    return super.backgroundProfileImagePath;
  }

  @override
  set backgroundProfileImagePath(String? value) {
    _$backgroundProfileImagePathAtom
        .reportWrite(value, super.backgroundProfileImagePath, () {
      super.backgroundProfileImagePath = value;
    });
  }

  late final _$BaseUserModelActionController =
      ActionController(name: 'BaseUserModel', context: context);

  @override
  dynamic setName(String name) {
    final _$actionInfo = _$BaseUserModelActionController.startAction(
        name: 'BaseUserModel.setName');
    try {
      return super.setName(name);
    } finally {
      _$BaseUserModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setEmail(String email) {
    final _$actionInfo = _$BaseUserModelActionController.startAction(
        name: 'BaseUserModel.setEmail');
    try {
      return super.setEmail(email);
    } finally {
      _$BaseUserModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setPassword(String password) {
    final _$actionInfo = _$BaseUserModelActionController.startAction(
        name: 'BaseUserModel.setPassword');
    try {
      return super.setPassword(password);
    } finally {
      _$BaseUserModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setDateOfBirth(DateTime dateOfBirth) {
    final _$actionInfo = _$BaseUserModelActionController.startAction(
        name: 'BaseUserModel.setDateOfBirth');
    try {
      return super.setDateOfBirth(dateOfBirth);
    } finally {
      _$BaseUserModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setGender(UserGender gender) {
    final _$actionInfo = _$BaseUserModelActionController.startAction(
        name: 'BaseUserModel.setGender');
    try {
      return super.setGender(gender);
    } finally {
      _$BaseUserModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setPhone(String phone) {
    final _$actionInfo = _$BaseUserModelActionController.startAction(
        name: 'BaseUserModel.setPhone');
    try {
      return super.setPhone(phone);
    } finally {
      _$BaseUserModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setType(UserType type) {
    final _$actionInfo = _$BaseUserModelActionController.startAction(
        name: 'BaseUserModel.setType');
    try {
      return super.setType(type);
    } finally {
      _$BaseUserModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setProfileImagePath(String profileImagePath) {
    final _$actionInfo = _$BaseUserModelActionController.startAction(
        name: 'BaseUserModel.setProfileImagePath');
    try {
      return super.setProfileImagePath(profileImagePath);
    } finally {
      _$BaseUserModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setBackgroundProfileImagePath(String backgroundProfileImagePath) {
    final _$actionInfo = _$BaseUserModelActionController.startAction(
        name: 'BaseUserModel.setBackgroundProfileImagePath');
    try {
      return super.setBackgroundProfileImagePath(backgroundProfileImagePath);
    } finally {
      _$BaseUserModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
name: ${name},
email: ${email},
password: ${password},
dateOfBirth: ${dateOfBirth},
gender: ${gender},
phone: ${phone},
type: ${type},
profileImagePath: ${profileImagePath},
backgroundProfileImagePath: ${backgroundProfileImagePath}
    ''';
  }
}
