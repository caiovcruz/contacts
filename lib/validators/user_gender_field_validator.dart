import 'package:form_field_validator/form_field_validator.dart';

import '../models/user_gender.dart';

class UserGenderFieldValidator extends FieldValidator<UserGender?> {
  UserGenderFieldValidator({required String errorText}) : super(errorText);

  @override
  bool isValid(UserGender? value) {
    return UserGender.values.contains(value);
  }
}
