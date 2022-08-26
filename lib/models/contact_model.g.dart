// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ContactModel on BaseContactModel, Store {
  late final _$nameAtom = Atom(name: 'BaseContactModel.name', context: context);

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

  late final _$emailAtom =
      Atom(name: 'BaseContactModel.email', context: context);

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

  late final _$typeAtom = Atom(name: 'BaseContactModel.type', context: context);

  @override
  ContactType? get type {
    _$typeAtom.reportRead();
    return super.type;
  }

  @override
  set type(ContactType? value) {
    _$typeAtom.reportWrite(value, super.type, () {
      super.type = value;
    });
  }

  late final _$BaseContactModelActionController =
      ActionController(name: 'BaseContactModel', context: context);

  @override
  dynamic setName(String name) {
    final _$actionInfo = _$BaseContactModelActionController.startAction(
        name: 'BaseContactModel.setName');
    try {
      return super.setName(name);
    } finally {
      _$BaseContactModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setEmail(String email) {
    final _$actionInfo = _$BaseContactModelActionController.startAction(
        name: 'BaseContactModel.setEmail');
    try {
      return super.setEmail(email);
    } finally {
      _$BaseContactModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setType(ContactType type) {
    final _$actionInfo = _$BaseContactModelActionController.startAction(
        name: 'BaseContactModel.setType');
    try {
      return super.setType(type);
    } finally {
      _$BaseContactModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
name: ${name},
email: ${email},
type: ${type}
    ''';
  }
}
