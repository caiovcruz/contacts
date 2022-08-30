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
import '../widgets/raised_gradient_button.dart';

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
          }),
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
          child: RaisedGradientButton(
            height: SizeConfig.safeBlockVertical * 5,
            gradient: const LinearGradient(
              colors: [
                Colors.purple,
                Colors.deepPurple,
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
            child: AnimatedBuilder(
                animation: Listenable.merge([_createLoading, _currentStep]),
                builder: (context, _) {
                  return _createLoading.value
                      ? LoadingHelper.showButtonLoading()
                      : Text(
                          _currentStep.value == getSteps(isDarkTheme).length - 1
                              ? 'CREATE'
                              : 'NEXT',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        );
                }),
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
              Row(
                children: [
                  ValueListenableBuilder(
                      valueListenable: _imageFile,
                      builder: (context, imageFile, _) {
                        return getProfileImage(isDarkTheme.value);
                      }),
                  Expanded(
                    child: Wrap(
                      spacing: 20.0,
                      runSpacing: 15.0,
                      children: [
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
                      ],
                    ),
                  ),
                ],
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

      _userDao.userExists(_user.id, _user.email!).then((exists) {
        if (!exists) {
          if (_imageFile.value != null) {
            _user.profileImagePath = _user.profileImagePath ??
                "${const Uuid().v1()}${path.extension(_imageFile.value!.path)}";

            ImagePickerHelper.saveFileToExStorage(
                _user.profileImagePath!,
                _imageFile.value!,
                ImagePickerHelper.getProfileImageFilesPath());
          }

          _user.type = UserType.user;
          _user.password = EncrypterHelper.encrypt(_user.password!);

          _userDao.save(_user.toUser()).then((userId) {
            MessageHelper.showSuccessMessage(
              context,
              "User created!",
            );

            NavigatorHelper().navigateToRoute(
              context,
              "/",
              removeUntil: true,
            );
          });
        } else {
          _createLoading.value = !_createLoading.value;

          MessageHelper.showErrorMessage(
            context,
            "User email ${_user.email!} already exists!",
          );
        }
      });
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

  void updatePhone(phone) {
    _user.phone = phone;
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
        Center(
          child: Padding(
            padding: EdgeInsets.only(
              right: SizeConfig.safeBlockVertical * 2,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3.0), //or 15.0
              child: Container(
                height: SizeConfig.safeBlockVertical * 20,
                width: SizeConfig.safeBlockHorizontal * 30,
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
                  height: SizeConfig.safeBlockVertical * 10,
                  width: SizeConfig.safeBlockHorizontal * 10,
                  child: Observer(
                    builder: (_) => Image(
                      fit: BoxFit.cover,
                      image: _imageFile.value != null
                          ? Image.file(
                              _imageFile.value!,
                            ).image
                          : AssetImage(
                              "assets/images/${_user.gender != null ? '${UserGender.values[_user.gender!.index].name}-user' : 'male-user'}.png"),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: SizeConfig.safeBlockVertical * 16,
            left: SizeConfig.safeBlockHorizontal * 13,
          ),
          child: Center(
            child: CircleAvatar(
              radius: 15.0,
              backgroundColor: isDarkTheme ? Colors.grey[850] : Colors.grey[50],
              child: IconButton(
                iconSize: 15.0,
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
                          contentPadding: EdgeInsets.symmetric(
                            vertical: SizeConfig.safeBlockVertical * 2,
                            horizontal: SizeConfig.safeBlockHorizontal * 2,
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              RaisedGradientButton(
                                height: SizeConfig.safeBlockVertical * 5,
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
                                  }).whenComplete(() {
                                    _camLoading.value = !_camLoading.value;
                                    NavigatorHelper().popRoute(dialogContext);
                                  });
                                },
                              ),
                              SizedBox(
                                height: SizeConfig.safeBlockVertical * 2,
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
                                  _imageFile.value = null;
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
