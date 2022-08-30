import 'dart:convert';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../helpers/navigator_helper.dart';
import '../helpers/size_config.dart';
import '../widgets/app_bar.dart';
import '../helpers/contact_type_helper.dart';
import '../helpers/loading_helper.dart';
import '../helpers/message_helper.dart';
import '../helpers/secure_storage_helper.dart';
import '../models/contact_model.dart';
import '../models/contact_type.dart';
import '../models/user.dart';
import '../pages/list_contact_page.dart';
import '../repositories/contact_dao.dart';
import '../validators/contact_type_field_validator.dart';

class ContactPage extends StatefulWidget {
  final ContactModel contact;

  const ContactPage.edit({Key? key, required this.contact}) : super(key: key);

  ContactPage({Key? key})
      : contact = ContactModel(),
        super(key: key);

  @override
  State<ContactPage> createState() => _ContactPagePageState();
}

class _ContactPagePageState extends State<ContactPage> {
  late ContactModel _contact;
  late ContactDao _contactDao;
  late GlobalKey<FormState> _formKey;
  late ValueNotifier<bool> _saveLoading;
  late ValueNotifier<bool> _deleteLoading;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
    _contactDao = ContactDao();
    _formKey = GlobalKey<FormState>();
    _saveLoading = ValueNotifier<bool>(false);
    _deleteLoading = ValueNotifier<bool>(false);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return FutureBuilder<User?>(
        future: loadUserSignedIn(),
        builder: (context, AsyncSnapshot<User?> userSnapshot) {
          return Scaffold(
            appBar: getEditingAppBar(
              context,
              _contact.id != null ? "Edit Contact" : "New Contact",
              actions: getActionsAppBar(
                context,
                userSnapshot,
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.safeBlockVertical * 3,
                  horizontal: SizeConfig.safeBlockVertical * 3,
                ),
                child: Form(
                  key: _formKey,
                  child: Wrap(
                    spacing: 20.0,
                    runSpacing: 15.0,
                    children: <Widget>[
                      Observer(
                        builder: (_) => TextFormField(
                          validator: nameValidator(),
                          onChanged: updateName,
                          initialValue: _contact.name,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Name *",
                          ),
                        ),
                      ),
                      Observer(
                        builder: (_) => DropdownButtonFormField(
                          value: _contact.type,
                          validator: typeValidator(),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Contact Type *",
                          ),
                          items: bindTypes(),
                          onChanged: updateType,
                        ),
                      ),
                      TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TelefoneInputFormatter()
                        ],
                        keyboardType: TextInputType.number,
                        validator: requiredTextValidator(),
                        onChanged: updatePhone,
                        initialValue: _contact.phone,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Phone *",
                        ),
                      ),
                      Observer(
                        builder: (_) => TextFormField(
                          validator: emailValidator(),
                          onChanged: updateEmail,
                          initialValue: _contact.email,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "E-mail *",
                          ),
                        ),
                      ),
                      TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CpfInputFormatter()
                        ],
                        keyboardType: TextInputType.number,
                        onChanged: updateCpf,
                        initialValue: _contact.cpf,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "CPF",
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                      ),
                      getDeleteContactButton(context, userSnapshot.data)
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  List<Widget>? getActionsAppBar(
      BuildContext context, AsyncSnapshot<User?> userSnapshot) {
    return [getDoneButton(context, userSnapshot)];
  }

  Widget getDoneButton(
      BuildContext context, AsyncSnapshot<User?> userSnapshot) {
    return TextButton(
      child: AnimatedBuilder(
          animation: _saveLoading,
          builder: (context, _) {
            return _saveLoading.value
                ? LoadingHelper.showButtonLoading()
                : const Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
          }),
      onPressed: () => saveContact(userSnapshot.data, context),
    );
  }

  Future<User> loadUserSignedIn() async {
    return User.fromJson(
        jsonDecode((await SecureStorageHelper().read("USER"))!));
  }

  void saveContact(userSignedIn, BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _saveLoading.value = !_saveLoading.value;

      _contactDao
          .contactExists(userSignedIn.id, _contact.id, _contact.phone!)
          .then((exists) {
        if (!exists) {
          _contact.userId = userSignedIn.id;

          _contactDao.save(_contact.toContact()).then((_) {
            MessageHelper.showSuccessMessage(
              context,
              _contact.id != null ? "Contact updated!" : "Contact added!",
            );

            returnToListingContacts(context);
          });
        } else {
          _saveLoading.value = !_saveLoading.value;

          MessageHelper.showErrorMessage(
            context,
            "Contact phone ${_contact.phone!} already exists!",
          );
        }
      });
    }
  }

  Widget getDeleteContactButton(BuildContext context, userSignedIn) {
    return _contact.id != null
        ? SizedBox(
            height: SizeConfig.safeBlockVertical * 5,
            width: SizeConfig.screenWidth,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  width: 2.0,
                  color: Colors.red,
                ),
              ),
              child: AnimatedBuilder(
                  animation: _deleteLoading,
                  builder: (context, _) {
                    return _deleteLoading.value
                        ? LoadingHelper.showButtonLoading(
                            widgetColor: Colors.red)
                        : const Text("Delete Contact",
                            style: TextStyle(color: Colors.red));
                  }),
              onPressed: () {
                _deleteLoading.value = !_deleteLoading.value;

                _contactDao
                    .delete(userSignedIn.id!, _contact.id!)
                    .then((deleted) {
                  if (deleted) {
                    MessageHelper.showSuccessMessage(
                      context,
                      "Contact deleted!",
                    );

                    returnToListingContacts(context);
                  } else {
                    _deleteLoading.value = !_deleteLoading.value;

                    MessageHelper.showErrorMessage(
                      context,
                      "Something went wrong, try later!",
                    );
                  }
                });
              },
            ),
          )
        : Container();
  }

  void returnToListingContacts(BuildContext context) {
    NavigatorHelper().navigateToWidget(
      context,
      const ListContactPage(),
      removeUntil: true,
    );
  }

  void updateName(name) {
    _contact.setName(name);
  }

  void updatePhone(phone) => _contact.phone = phone;

  void updateEmail(email) {
    _contact.setEmail(email);
  }

  void updateCpf(cpf) => _contact.cpf = cpf;

  void updateType(type) {
    _contact.setType(type);
  }

  TextFieldValidator requiredTextValidator() {
    return RequiredValidator(errorText: "required field");
  }

  FieldValidator emailValidator() {
    return MultiValidator([
      requiredTextValidator(),
      EmailValidator(errorText: "invalid e-mail"),
    ]);
  }

  FieldValidator nameValidator() {
    return MultiValidator([
      requiredTextValidator(),
      MaxLengthValidator(100,
          errorText: "name must have at most 100 characters!"),
    ]);
  }

  FieldValidator typeValidator() {
    return ContactTypeFieldValidator(errorText: "required field");
  }

  static List<DropdownMenuItem<ContactType?>> bindTypes() {
    return ContactType.values
        .map(
          (type) => DropdownMenuItem(
            value: type,
            child: ContactTypeHelper.getContactTypeRow(type),
          ),
        )
        .toList();
  }
}
