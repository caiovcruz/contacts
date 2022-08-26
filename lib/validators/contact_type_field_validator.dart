import 'package:form_field_validator/form_field_validator.dart';

import '../models/contact_type.dart';

class ContactTypeFieldValidator extends FieldValidator<ContactType?> {
  ContactTypeFieldValidator({required String errorText}) : super(errorText);

  @override
  bool isValid(ContactType? value) {
    return ContactType.values.contains(value);
  }
}
