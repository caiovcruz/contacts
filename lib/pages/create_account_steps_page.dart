import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import '../helpers/dark_theme_preference_helper.dart';
import '../helpers/encrypter_helper.dart';
import '../helpers/image_picker_helper.dart';
import '../helpers/loading_helper.dart';
import '../helpers/message_helper.dart';
import '../helpers/navigator_helper.dart';
import '../helpers/size_config.dart';
import '../helpers/user_gender_helper.dart';
import '../models/user_gender.dart';
import '../models/user_model.dart';
import '../models/user_type.dart';
import '../repositories/user_dao.dart';
import '../validators/user_gender_field_validator.dart';
import '../widgets/app_bar.dart';
import '../widgets/gradient_elevated_button.dart';

class CreateAccountStepsPage extends StatefulWidget {
  final UserModel user;

  CreateAccountStepsPage({Key? key})
      : user = UserModel(),
        super(key: key);

  @override
  State<CreateAccountStepsPage> createState() => _CreateAccountStepsPageState();
}

class _CreateAccountStepsPageState extends State<CreateAccountStepsPage> {
  late UserModel _user;
  late UserDao _userDao;
  late ValueNotifier<bool> _passwordVisible;
  late ValueNotifier<bool> _confirmPasswordVisible;
  late ValueNotifier<int> _currentStep;
  late ValueNotifier<bool> _createLoading;
  late ValueNotifier<bool> _camLoading;
  late GlobalKey<FormState> _accountFormKey;
  late GlobalKey<FormState> _detailsFormKey;
  late ValueNotifier<File?> _imageFile;
  late ValueNotifier<File?> _backgroundImageFile;
  late TextEditingController _dateOfBirthTextController;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _userDao = UserDao();
    _passwordVisible = ValueNotifier<bool>(false);
    _confirmPasswordVisible = ValueNotifier<bool>(false);
    _currentStep = ValueNotifier<int>(0);
    _createLoading = ValueNotifier<bool>(false);
    _camLoading = ValueNotifier<bool>(false);
    _accountFormKey = GlobalKey<FormState>();
    _detailsFormKey = GlobalKey<FormState>();
    _imageFile = ValueNotifier<File?>(null);
    _backgroundImageFile = ValueNotifier<File?>(null);
    _dateOfBirthTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    ValueNotifier<bool> isDarkTheme = ValueNotifier<bool>(
        Provider.of<DarkThemeProvider>(context, listen: false).darkTheme);

    return Scaffold(
      appBar: getEditingAppBar(
        context,
        "Create Account",
      ),
      body: ValueListenableBuilder(
        valueListenable: _currentStep,
        builder: (context, currentStep, _) {
          return Stepper(
            type: StepperType.horizontal,
            steps: getSteps(isDarkTheme),
            currentStep: _currentStep.value,
            onStepTapped: (step) => _currentStep.value = step,
            onStepContinue: () {
              if (!(_currentStep.value == getSteps(isDarkTheme).length - 1)) {
                _currentStep.value += 1;
              }
            },
            onStepCancel: () {
              if (!(_currentStep.value == 0)) {
                _currentStep.value -= 1;
              }
            },
            controlsBuilder: (context, details) =>
                getStepperControls(context, details, isDarkTheme),
          );
        },
      ),
    );
  }

  Widget getStepperControls(BuildContext context, ControlsDetails details,
      ValueNotifier<bool> isDarkTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                side: BorderSide(
                    width: 1,
                    color: Colors.grey[500]!,
                    style: BorderStyle.solid)),
            child: Text(
              'BACK',
              style: TextStyle(
                color: Colors.grey[500]!,
              ),
            ),
            onPressed: () => details.onStepCancel?.call(),
          ),
        ),
        SizedBox(
          width: SizeConfig.safeBlockHorizontal * 2,
        ),
        Expanded(
          child: GradientElevatedButton(
            child: AnimatedBuilder(
              animation: Listenable.merge([_createLoading, _currentStep]),
              builder: (context, _) {
                return _createLoading.value
                    ? LoadingHelper.showButtonLoading()
                    : Text(
                        _currentStep.value == getSteps(isDarkTheme).length - 1
                            ? 'CREATE'
                            : 'NEXT',
                        style: TextStyle(
                          color: Colors.grey[50],
                        ),
                      );
              },
            ),
            onPressed: () {
              if (_currentStep.value == getSteps(isDarkTheme).length - 1) {
                createUser(context);
              } else {
                if ((_accountFormKey.currentState!.validate())) {
                  details.onStepContinue?.call();
                }
              }
            },
          ),
        ),
      ],
    );
  }

  List<Step> getSteps(ValueNotifier<bool> isDarkTheme) => [
        Step(
          isActive: _currentStep.value >= 0,
          title: const Text("Account"),
          content: getAccountForm(),
        ),
        Step(
          isActive: _currentStep.value >= 1,
          title: const Text("Details"),
          content: getDetailsForm(isDarkTheme),
        ),
      ];

  Widget getAccountForm() {
    return SingleChildScrollView(
      child: Form(
        key: _accountFormKey,
        child: Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.safeBlockVertical * 2),
          child: Wrap(
            spacing: 20.0,
            runSpacing: 15.0,
            children: <Widget>[
              Observer(
                builder: (_) => TextFormField(
                  validator: emailValidator(),
                  onChanged: updateEmail,
                  initialValue: _user.email,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "E-mail *",
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
                    initialValue: _user.password,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Password *",
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
                  initialValue: _user.password,
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
    return SingleChildScrollView(
      child: Form(
        key: _detailsFormKey,
        child: Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.safeBlockVertical * 2),
          child: Wrap(
            spacing: 20.0,
            runSpacing: 15.0,
            children: <Widget>[
              getProfileImage(isDarkTheme.value),
              Observer(
                builder: (_) => TextFormField(
                  validator: nameValidator(),
                  onChanged: updateName,
                  initialValue: _user.name,
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
                  value: _user.gender,
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
                  initialValue: _user.phone,
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
                initialDateTime: _user.dateOfBirth ?? DateTime.now(),
                onDateTimeChanged: updateDateOfBirth,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createUser(BuildContext context) {
    if (_accountFormKey.currentState!.validate() &&
        _detailsFormKey.currentState!.validate()) {
      _createLoading.value = !_createLoading.value;

      _userDao.userExists(_user.id, _user.email!).then(
        (exists) {
          if (!exists) {
            if (_imageFile.value != null) {
              _user.profileImagePath = _user.profileImagePath ??
                  "${const Uuid().v1()}${path.extension(_imageFile.value!.path)}";

              ImagePickerHelper.saveFileToExStorage(
                  _user.profileImagePath!,
                  _imageFile.value!,
                  ImagePickerHelper.getProfileImageFilesPath());
            }

            if (_backgroundImageFile.value != null) {
              _user.backgroundProfileImagePath = _user
                      .backgroundProfileImagePath ??
                  "${const Uuid().v1()}${path.extension(_backgroundImageFile.value!.path)}";

              ImagePickerHelper.saveFileToExStorage(
                  _user.backgroundProfileImagePath!,
                  _backgroundImageFile.value!,
                  ImagePickerHelper.getBackgroundProfileImageFilesPath());
            }

            _user.type = UserType.user;
            _user.password = EncrypterHelper.encrypt(_user.password!);

            _userDao.save(_user.toUser()).then(
              (userId) {
                MessageHelper.showSuccessMessage(
                  context,
                  "User created!",
                );

                NavigatorHelper().navigateToRoute(
                  context,
                  "/",
                  removeUntil: true,
                );
              },
            );
          } else {
            _createLoading.value = !_createLoading.value;

            MessageHelper.showErrorMessage(
              context,
              "User email ${_user.email!} already exists!",
            );
          }
        },
      );
    }
  }

  void updateName(name) {
    _user.setName(name);
  }

  void updateEmail(email) {
    _user.setEmail(email.toString().toLowerCase());
  }

  void updatePassword(password) {
    _user.setPassword(password);
  }

  void updateDateOfBirth(dateOfBirth) {
    _user.setDateOfBirth(dateOfBirth ?? (_user.dateOfBirth ?? DateTime.now()));

    _dateOfBirthTextController.text =
        "${_user.dateOfBirth?.month ?? '00'}/${_user.dateOfBirth?.day ?? '00'}/${_user.dateOfBirth?.year ?? '0000'}";
  }

  void updateGender(gender) {
    _user.setGender(gender);
  }

  void updatePhone(phone) =>
      _user.phone = UtilBrasilFields.removeCaracteres(phone);

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
      requiredTextValidator(),
      MinLengthValidator(8,
          errorText: "password must have at least 8 characters"),
    ]);
  }

  String? confirmPasswordValidator(confirmPassword) {
    return MatchValidator(errorText: "confirm password not matching!")
        .validateMatch(_user.password ?? "", confirmPassword);
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
        ValueListenableBuilder(
          valueListenable: _backgroundImageFile,
          builder: (context, backgroungImageFile, _) {
            return UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                image: _backgroundImageFile.value != null
                    ? DecorationImage(
                        image: Image.file(_backgroundImageFile.value!).image,
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
                builder: (_) => _user.email != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          "${_user.email}",
                          style: TextStyle(
                            color: Colors.grey[850],
                          ),
                        ),
                      )
                    : Container(),
              ),
              accountName: Observer(
                builder: (_) => _user.name != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          "${_user.name}",
                          style: TextStyle(
                            color: Colors.grey[850],
                          ),
                        ),
                      )
                    : Container(),
              ),
              currentAccountPicture: ValueListenableBuilder(
                valueListenable: _imageFile,
                builder: (context, imageFile, _) {
                  return Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.0,
                        foregroundImage: _imageFile.value != null
                            ? Image.file(
                                _imageFile.value!,
                              ).image
                            : AssetImage(
                                "assets/images/${_user.gender != null ? '${UserGender.values[_user.gender!.index].name}-user' : 'male-user'}.png"),
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
                            onPressed: () => manageFiles(context, _imageFile),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
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
        ),
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
