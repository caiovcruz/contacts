import 'dart:convert';
import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../helpers/dark_theme_preference_helper.dart';
import '../helpers/encrypter_helper.dart';
import '../helpers/image_picker_helper.dart';
import '../helpers/navigator_helper.dart';
import '../helpers/secure_storage_helper.dart';
import '../helpers/user_gender_helper.dart';
import '../models/user_gender.dart';
import '../validators/user_gender_field_validator.dart';
import '../widgets/app_bar.dart';
import '../helpers/loading_helper.dart';
import '../helpers/message_helper.dart';
import '../models/user_model.dart';
import '../models/user_type.dart';
import '../repositories/user_dao.dart';
import '../widgets/raised_gradient_button.dart';

class AccountPage extends StatefulWidget {
  final UserModel user;

  const AccountPage.edit({Key? key, required this.user}) : super(key: key);

  AccountPage({Key? key})
      : user = UserModel(),
        super(key: key);

  @override
  State<AccountPage> createState() => _AccountPagePageState();
}

class _AccountPagePageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  late UserModel _userDetails;
  late UserModel _userAccount;
  late UserDao _userDao;
  late GlobalKey<FormState> _detailsFormKey;
  late GlobalKey<FormState> _accountFormKey;
  late SecureStorageHelper _secureStorageHelper;
  late ValueNotifier<String?> _oldPassword;
  late ValueNotifier<bool> _oldPasswordVisible;
  late ValueNotifier<bool> _passwordVisible;
  late ValueNotifier<bool> _confirmPasswordVisible;
  late ValueNotifier<bool> _createLoading;
  late ValueNotifier<bool> _camLoading;
  late ValueNotifier<File?> _imageFile;
  late TextEditingController _dateOfBirthTextController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _userDetails = widget.user.copy();
    _userAccount = widget.user.copy();
    _userDao = UserDao();
    _detailsFormKey = GlobalKey<FormState>();
    _accountFormKey = GlobalKey<FormState>();
    _secureStorageHelper = SecureStorageHelper();
    _oldPassword = ValueNotifier<String?>(null);
    _oldPasswordVisible = ValueNotifier<bool>(false);
    _passwordVisible = ValueNotifier<bool>(false);
    _confirmPasswordVisible = ValueNotifier<bool>(false);
    _createLoading = ValueNotifier<bool>(false);
    _camLoading = ValueNotifier<bool>(false);
    _imageFile = ValueNotifier<File?>(null);
    _dateOfBirthTextController = TextEditingController(
        text:
            "${_userDetails.dateOfBirth?.month ?? '00'}/${_userDetails.dateOfBirth?.day ?? '00'}/${_userDetails.dateOfBirth?.year ?? '0000'}");
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isDarkTheme = ValueNotifier<bool>(
        Provider.of<DarkThemeProvider>(context, listen: false).darkTheme);

    return Scaffold(
      appBar: getEditingAppBar(
        context,
        "Edit Account",
        leadingText: "Back",
        actions: getActionsAppBar(
          context,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: getAccountTabs(isDarkTheme),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple,
              Colors.deepPurple,
            ],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorPadding: const EdgeInsets.all(5.0),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              text: "Details",
              icon: Icon(Icons.assignment),
            ),
            Tab(
              text: "Account",
              icon: Icon(Icons.account_box),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getAccountTabs(ValueNotifier<bool> isDarkTheme) {
    return [
      getDetailsForm(isDarkTheme),
      getAccountForm(),
    ];
  }

  Widget getAccountForm() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _accountFormKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 20,
              runSpacing: 10,
              children: <Widget>[
                Observer(
                  builder: (_) => TextFormField(
                    validator: emailValidator(),
                    onChanged: updateEmail,
                    initialValue: _userAccount.email,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "E-mail *",
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _oldPasswordVisible,
                  builder: (context, oldPasswordVisible, _) => TextFormField(
                    obscureText: !_oldPasswordVisible.value,
                    validator: passwordValidator(),
                    onChanged: (oldPassword) =>
                        _oldPassword.value = oldPassword,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText:
                          "Old Password ${_userAccount.id != null ? '' : '*'}",
                      hintText: 'Enter secure old password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _oldPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          _oldPasswordVisible.value =
                              !_oldPasswordVisible.value;
                        },
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _passwordVisible,
                  builder: (context, passwordVisible, _) => Observer(
                    builder: (_) => TextFormField(
                      obscureText: !_passwordVisible.value,
                      validator: passwordValidator(),
                      onChanged: updatePassword,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: "Password",
                        hintText: 'Enter secure password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            _passwordVisible.value = !_passwordVisible.value;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _confirmPasswordVisible,
                  builder: (context, confirmPasswordVisible, _) =>
                      TextFormField(
                    obscureText: !_confirmPasswordVisible.value,
                    validator: (confirmPassword) =>
                        confirmPasswordValidator(confirmPassword),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Confirm Password",
                      hintText: 'Re-enter secure password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          _confirmPasswordVisible.value =
                              !_confirmPasswordVisible.value;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getDetailsForm(ValueNotifier<bool> isDarkTheme) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _detailsFormKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 20,
              runSpacing: 10,
              children: <Widget>[
                Row(
                  children: [
                    FutureBuilder<void>(
                        future:
                            getProfileImageFile(_userDetails.profileImagePath),
                        builder: (context, _) {
                          return ValueListenableBuilder(
                              valueListenable: _imageFile,
                              builder: (context, imageFile, _) {
                                return getProfileImage(isDarkTheme.value);
                              });
                        }),
                    Expanded(
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 10,
                        children: [
                          Observer(
                            builder: (_) => TextFormField(
                              validator: nameValidator(),
                              onChanged: updateName,
                              initialValue: _userDetails.name,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Name *",
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _dateOfBirthTextController,
                            readOnly: true,
                            validator: requiredTextValidator(),
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: "Date of birth *",
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            onTap: () => showDateTimePicker(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Observer(
                  builder: (_) => DropdownButtonFormField(
                    value: _userDetails.gender,
                    validator: genderValidator(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Gender *",
                    ),
                    items: bindTypes(),
                    onChanged: updateGender,
                  ),
                ),
                Observer(
                  builder: (_) => TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter()
                    ],
                    keyboardType: TextInputType.number,
                    validator: requiredTextValidator(),
                    onChanged: updatePhone,
                    initialValue: _userDetails.phone,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Phone *",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showDateTimePicker() {
    BuildContext dialogContext = context;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    NavigatorHelper().popRoute(dialogContext);
                  },
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () {
                    updateDateOfBirth(null);
                    NavigatorHelper().popRoute(dialogContext);
                  },
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _userDetails.dateOfBirth ?? DateTime.now(),
                onDateTimeChanged: updateDateOfBirth,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget>? getActionsAppBar(BuildContext context) {
    return [
      getDoneButton(context),
    ];
  }

  Widget getDoneButton(BuildContext context) {
    return TextButton(
      child: AnimatedBuilder(
          animation: _createLoading,
          builder: (context, _) {
            return _createLoading.value
                ? LoadingHelper.showButtonLoading()
                : const Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
          }),
      onPressed: () => manageUser(context),
    );
  }

  void manageUser(BuildContext context) {
    _createLoading.value = !_createLoading.value;

    if (_tabController.index == 0) {
      if (_detailsFormKey.currentState!.validate()) {
        if (_imageFile.value != null) {
          _userDetails.profileImagePath = "${const Uuid().v1()}${path.extension(_imageFile.value!.path)}";

          ImagePickerHelper.saveFileToExStorage(_userDetails.profileImagePath!,
              _imageFile.value!, ImagePickerHelper.getProfileImageFilesPath());
        }

        _userDao
            .save(_userDetails.toUser())
            .then((userId) => MessageHelper.showSuccessMessage(
                  context,
                  "User updated!",
                ));

        _secureStorageHelper.write("USER", jsonEncode(_userDetails.toJson()));
      }
    } else {
      if (_accountFormKey.currentState!.validate()) {
        _userDao
            .userExists(_userAccount.id, _userAccount.email!)
            .then((exists) {
          if (!exists) {
            _userAccount.password =
                EncrypterHelper.encrypt(_userAccount.password!);

            _userDao
                .save(_userAccount.toUser())
                .then((userId) => MessageHelper.showSuccessMessage(
                      context,
                      "User updated!",
                    ));

            _secureStorageHelper.write(
                "USER", jsonEncode(_userAccount.toJson()));
          } else {
            MessageHelper.showErrorMessage(
              context,
              "User email ${_userAccount.email!} already exists!",
            );
          }
        });
      }
    }

    _createLoading.value = !_createLoading.value;
  }

  void updateName(name) {
    _userDetails.setName(name);
  }

  void updateEmail(email) {
    _userAccount.setEmail(email.toString().toLowerCase());
  }

  void updatePassword(password) {
    _userAccount.setPassword(password);
  }

  void updateDateOfBirth(dateOfBirth) {
    _userDetails.setDateOfBirth(dateOfBirth);
  }

  void updateGender(gender) {
    _userDetails.setGender(gender);
  }

  void updatePhone(phone) {
    _userDetails.phone = phone;
  }

  TextFieldValidator requiredTextValidator() {
    return RequiredValidator(errorText: "required field");
  }

  FieldValidator nameValidator() {
    return MultiValidator([
      requiredTextValidator(),
      MaxLengthValidator(100,
          errorText: "name must have at most 100 characters!"),
    ]);
  }

  FieldValidator emailValidator() {
    return MultiValidator([
      requiredTextValidator(),
      EmailValidator(errorText: "invalid e-mail"),
    ]);
  }

  FieldValidator passwordValidator() {
    return MultiValidator([
      MinLengthValidator(8,
          errorText: "password must have at least 8 characters"),
    ]);
  }

  String? confirmPasswordValidator(confirmPassword) {
    return MatchValidator(errorText: "confirm password not matching!")
        .validateMatch(_userAccount.password ?? "", confirmPassword);
  }

  FieldValidator genderValidator() {
    return UserGenderFieldValidator(errorText: "required field");
  }

  static List<DropdownMenuItem<UserGender?>> bindTypes() {
    return UserGender.values
        .map(
          (type) => DropdownMenuItem(
            value: type,
            child: UserGenderHelper.getUserGenderRow(type),
          ),
        )
        .toList();
  }

  Future<void> getProfileImageFile(String? userProfileImageFilePath) async {
    if (userProfileImageFilePath != null) {
      _imageFile.value = await ImagePickerHelper.getFileFromExStorage(
          userProfileImageFilePath,
          ImagePickerHelper.getProfileImageFilesPath());
    }
  }

  Widget getProfileImage(isDarkTheme) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3.0), //or 15.0
              child: Container(
                height: 130.0,
                width: 130.0,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple,
                      Colors.deepPurple,
                    ],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                  ),
                ),
                child: SizedBox(
                  height: 100.0,
                  width: 100.0,
                  child: Observer(
                    builder: (_) => Image(
                      fit: BoxFit.cover,
                      image: _imageFile.value != null
                          ? Image.file(
                              _imageFile.value!,
                            ).image
                          : AssetImage(
                              "assets/images/${_userDetails.gender != null ? '${UserGender.values[_userDetails.gender!.index].name}-user' : 'male-user'}.png"),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 105, left: 55),
          child: Center(
            child: CircleAvatar(
              radius: 15,
              backgroundColor: isDarkTheme ? Colors.grey[850] : Colors.grey[50],
              child: IconButton(
                iconSize: 15,
                icon: Icon(
                  Icons.photo_camera,
                  color: isDarkTheme ? Colors.grey[50] : Colors.grey[850],
                ),
                onPressed: () {
                  BuildContext dialogContext;
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        dialogContext = context;
                        return AlertDialog(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                10.0,
                              ),
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(8.0),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              RaisedGradientButton(
                                height:
                                    MediaQuery.of(context).size.height * 0.050,
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.purple,
                                    Colors.deepPurple,
                                  ],
                                  begin: Alignment.bottomRight,
                                  end: Alignment.topLeft,
                                ),
                                child: AnimatedBuilder(
                                    animation: _camLoading,
                                    builder: (context, _) {
                                      return _camLoading.value
                                          ? LoadingHelper.showButtonLoading()
                                          : const Text(
                                              "Choose gallery image",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            );
                                    }),
                                onPressed: () {
                                  _camLoading.value = !_camLoading.value;

                                  ImagePickerHelper.getFromGallery()
                                      .then((value) {
                                    if (value != null) {
                                      _imageFile.value = value;
                                    }
                                  });

                                  _camLoading.value = !_camLoading.value;

                                  NavigatorHelper().popRoute(dialogContext);
                                },
                              ),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        width: 1,
                                        color: Colors.red,
                                        style: BorderStyle.solid)),
                                child: AnimatedBuilder(
                                    animation: _camLoading,
                                    builder: (context, _) {
                                      return _camLoading.value
                                          ? LoadingHelper.showButtonLoading()
                                          : const Text(
                                              "Remove profile image",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            );
                                    }),
                                onPressed: () {
                                  _camLoading.value = !_camLoading.value;

                                  _imageFile.value = null;

                                  _camLoading.value = !_camLoading.value;

                                  NavigatorHelper().popRoute(dialogContext);
                                },
                              ),
                            ],
                          ),
                        );
                      });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
