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
import '../helpers/size_config.dart';
import '../helpers/user_gender_helper.dart';
import '../models/user.dart';
import '../models/user_gender.dart';
import '../validators/user_gender_field_validator.dart';
import '../widgets/app_bar.dart';
import '../helpers/loading_helper.dart';
import '../helpers/message_helper.dart';
import '../models/user_model.dart';
import '../models/user_type.dart';
import '../repositories/user_dao.dart';
import '../widgets/gradient_elevated_button.dart';

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
  late ValueNotifier<bool> _updateLoading;
  late ValueNotifier<bool> _camLoading;
  late ValueNotifier<File?> _imageFile;
  late ValueNotifier<File?> _backgroundImageFile;
  late TextEditingController _dateOfBirthTextController;
  late TextEditingController _phoneTextController;
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
    _updateLoading = ValueNotifier<bool>(false);
    _camLoading = ValueNotifier<bool>(false);
    _imageFile = ValueNotifier<File?>(null);
    _backgroundImageFile = ValueNotifier<File?>(null);
    _dateOfBirthTextController = TextEditingController(
        text:
            "${_userDetails.dateOfBirth?.month ?? '00'}/${_userDetails.dateOfBirth?.day ?? '00'}/${_userDetails.dateOfBirth?.year ?? '0000'}");

    print(_userDetails.phone);
    _phoneTextController = _userDetails.phone != null
        ? TextEditingController(
            text: UtilBrasilFields.obterTelefone(_userDetails.phone!))
        : TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

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
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.safeBlockVertical * 3,
          horizontal: SizeConfig.safeBlockVertical * 3,
        ),
        child: TabBarView(
          controller: _tabController,
          children: getAccountTabs(isDarkTheme),
        ),
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
          labelColor: Colors.grey[50],
          unselectedLabelColor: Colors.white70,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorPadding: EdgeInsets.symmetric(
            vertical: SizeConfig.safeBlockVertical * 1,
            horizontal: SizeConfig.safeBlockVertical * 1,
          ),
          indicatorColor: Colors.grey[50],
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
          child: Wrap(
            spacing: 20.0,
            runSpacing: 15.0,
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
                  onChanged: (oldPassword) => _oldPassword.value = oldPassword,
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
                      onPressed: () => _oldPasswordVisible.value =
                          !_oldPasswordVisible.value,
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
                        onPressed: () =>
                            _passwordVisible.value = !_passwordVisible.value,
                      ),
                    ),
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _confirmPasswordVisible,
                builder: (context, confirmPasswordVisible, _) => TextFormField(
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
                      onPressed: () => _confirmPasswordVisible.value =
                          !_confirmPasswordVisible.value,
                    ),
                  ),
                ),
              ),
            ],
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
          child: Wrap(
            spacing: 20.0,
            runSpacing: 15.0,
            children: <Widget>[
              getProfileImage(isDarkTheme.value),
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
                  controller: _phoneTextController,
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
    );
  }

  void showDateTimePicker() {
    BuildContext dialogContext = context;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: SizeConfig.safeBlockVertical * 32,
        color: Colors.grey[50],
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
              height: SizeConfig.safeBlockVertical * 22,
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
        animation: _updateLoading,
        builder: (context, _) {
          return _updateLoading.value
              ? LoadingHelper.showButtonLoading()
              : Text(
                  "Done",
                  style: TextStyle(
                    color: Colors.grey[50],
                    fontWeight: FontWeight.bold,
                  ),
                );
        },
      ),
      onPressed: () => manageUser(context),
    );
  }

  void manageUser(BuildContext context) {
    if (_tabController.index == 0) {
      updateDetails(context);
    } else {
      updateAccount(context);
    }
  }

  void updateAccount(BuildContext context) {
    if (_accountFormKey.currentState!.validate()) {
      _updateLoading.value = !_updateLoading.value;

      _userDao.userExists(_userAccount.id, _userAccount.email!).then(
        (exists) {
          if (!exists) {
            _userAccount.password =
                EncrypterHelper.encrypt(_userAccount.password!);

            _userDao.save(_userAccount.toUser()).then(
              (userId) {
                updateSecureStorage(_userAccount, _userDetails);
              },
            );
          } else {
            _updateLoading.value = !_updateLoading.value;

            MessageHelper.showErrorMessage(
              context,
              "User email ${_userAccount.email!} already exists!",
            );
          }
        },
      );
    }
  }

  void updateDetails(BuildContext context) {
    if (_detailsFormKey.currentState!.validate()) {
      _updateLoading.value = !_updateLoading.value;

      if (_imageFile.value != null) {
        _userDetails.profileImagePath =
            "${const Uuid().v1()}${path.extension(_imageFile.value!.path)}";

        ImagePickerHelper.saveFileToExStorage(_userDetails.profileImagePath!,
            _imageFile.value!, ImagePickerHelper.getProfileImageFilesPath());
      }

      if (_backgroundImageFile.value != null) {
        _userDetails.backgroundProfileImagePath =
            "${const Uuid().v1()}${path.extension(_backgroundImageFile.value!.path)}";

        ImagePickerHelper.saveFileToExStorage(
            _userDetails.backgroundProfileImagePath!,
            _backgroundImageFile.value!,
            ImagePickerHelper.getBackgroundProfileImageFilesPath());
      }

      _userDao.save(_userDetails.toUser()).then(
        (userId) {
          updateSecureStorage(_userDetails, _userAccount);
        },
      );
    }
  }

  void updateSecureStorage(userToWrite, userToRead) {
    _secureStorageHelper
        .write("USER", jsonEncode(userToWrite.toJson()))
        .then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _updateLoading.value = !_updateLoading.value;
        MessageHelper.showSuccessMessage(
          context,
          "User updated!",
        );
      });
    });

    _secureStorageHelper.read("USER").then((userJson) => userToRead =
        BaseUserModel.fromUser(User.fromJson(jsonDecode(userJson!))));
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

  void updatePhone(phone) =>
      _userDetails.phone = UtilBrasilFields.removeCaracteres(phone);

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

  Widget getProfileImage(isDarkTheme) {
    return Stack(
      children: [
        FutureBuilder<void>(
            future: getBackgroundProfileImageFile(
                _userDetails.backgroundProfileImagePath),
            builder: (context, _) {
              return ValueListenableBuilder(
                valueListenable: _backgroundImageFile,
                builder: (context, backgroungImageFile, _) {
                  return UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      image: _backgroundImageFile.value != null
                          ? DecorationImage(
                              image:
                                  Image.file(_backgroundImageFile.value!).image,
                            )
                          : null,
                      gradient: const LinearGradient(
                        colors: [
                          Colors.purple,
                          Colors.deepPurple,
                        ],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.5),
                          blurRadius: 1.5,
                        ),
                      ],
                    ),
                    accountEmail: Observer(
                      builder: (_) => _userAccount.email != null
                          ? Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                "${_userAccount.email}",
                                style: TextStyle(
                                  color: Colors.grey[850],
                                ),
                              ),
                            )
                          : Container(),
                    ),
                    accountName: Observer(
                      builder: (_) => _userDetails.name != null
                          ? Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                "${_userDetails.name}",
                                style: TextStyle(
                                  color: Colors.grey[850],
                                ),
                              ),
                            )
                          : Container(),
                    ),
                    currentAccountPicture: FutureBuilder<void>(
                        future:
                            getProfileImageFile(_userDetails.profileImagePath),
                        builder: (context, _) {
                          return ValueListenableBuilder(
                            valueListenable: _imageFile,
                            builder: (context, imageFile, _) {
                              return Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50.0,
                                    foregroundImage: loadProfileImage(
                                        _userDetails.gender, _imageFile.value),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: CircleAvatar(
                                      radius: 15.0,
                                      backgroundColor: Colors.grey[50],
                                      child: IconButton(
                                        iconSize: 15.0,
                                        icon: Icon(
                                          Icons.photo_camera,
                                          color: Colors.grey[850],
                                        ),
                                        onPressed: () =>
                                            manageFiles(context, _imageFile),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        }),
                    otherAccountsPictures: [
                      Center(
                        child: CircleAvatar(
                          radius: 15.0,
                          backgroundColor: Colors.grey[50],
                          child: IconButton(
                            iconSize: 15.0,
                            icon: Icon(
                              Icons.photo_camera,
                              color: Colors.grey[850],
                            ),
                            onPressed: () =>
                                manageFiles(context, _backgroundImageFile),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
      ],
    );
  }

  ImageProvider<Object>? loadProfileImage(
      UserGender? gender, File? userProfileImageFile) {
    return userProfileImageFile != null
        ? Image.file(userProfileImageFile).image
        : AssetImage(
            "assets/images/${gender != null ? '${UserGender.values[gender.index].name}-user' : 'male-user'}.png");
  }

  Future<void> getProfileImageFile(String? userProfileImageFilePath) async {
    if (userProfileImageFilePath != null) {
      _imageFile.value = await ImagePickerHelper.getFileFromExStorage(
          userProfileImageFilePath,
          ImagePickerHelper.getProfileImageFilesPath());
    }
  }

  Future<void> getBackgroundProfileImageFile(
      String? userBackgroundProfileImageFilePath) async {
    if (userBackgroundProfileImageFilePath != null) {
      _backgroundImageFile.value = await ImagePickerHelper.getFileFromExStorage(
          userBackgroundProfileImageFilePath,
          ImagePickerHelper.getBackgroundProfileImageFilesPath());
    }
  }

  manageFiles(BuildContext context, ValueNotifier<File?> fileToSet) {
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
          contentPadding: EdgeInsets.symmetric(
            vertical: SizeConfig.safeBlockVertical * 1,
            horizontal: SizeConfig.safeBlockHorizontal * 2,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GradientElevatedButton(
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
                          : Text(
                              "Choose gallery image",
                              style: TextStyle(
                                color: Colors.grey[50],
                              ),
                            );
                    }),
                onPressed: () {
                  _camLoading.value = !_camLoading.value;

                  ImagePickerHelper.getFromGallery().then((value) {
                    if (value != null) {
                      fileToSet.value = value;
                    }
                  }).whenComplete(() {
                    _camLoading.value = !_camLoading.value;
                    NavigatorHelper().popRoute(dialogContext);
                  });
                },
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        width: 1, color: Colors.red, style: BorderStyle.solid)),
                child: AnimatedBuilder(
                    animation: _camLoading,
                    builder: (context, _) {
                      return _camLoading.value
                          ? LoadingHelper.showButtonLoading()
                          : const Text(
                              "Remove image",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            );
                    }),
                onPressed: () {
                  fileToSet.value = null;
                  NavigatorHelper().popRoute(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
