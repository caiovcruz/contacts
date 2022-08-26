import 'package:form_field_validator/form_field_validator.dart';

import '../models/user_type.dart';

class UserTypeFieldValidator extends FieldValidator<UserType?> {
  UserTypeFieldValidator({required String errorText}) : super(errorText);

  @override
  bool isValid(UserType? value) {
    return UserType.values.contains(value);
  }
}
