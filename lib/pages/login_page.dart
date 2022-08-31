import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../helpers/encrypter_helper.dart';
import '../helpers/navigator_helper.dart';
import '../helpers/size_config.dart';
import '../widgets/gradient_elevated_button.dart';
import '../helpers/loading_helper.dart';
import '../helpers/message_helper.dart';
import '../helpers/secure_storage_helper.dart';
import '../models/user.dart';
import '../models/user_login_model.dart';
import '../models/user_type.dart';
import '../pages/list_contact_page.dart';
import '../pages/recover_password_page.dart';
import '../repositories/user_dao.dart';
import 'create_account_steps_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late UserLoginModel _userLogin;
  late UserDao _userDao;
  late GlobalKey<FormState> _formKey;
  late SecureStorageHelper _secureStorageHelper;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late ValueNotifier<bool> _savePassword;
  late ValueNotifier<bool> _passwordVisible;
  late ValueNotifier<bool> _signInloading;

  @override
  void initState() {
    super.initState();
    _userLogin = UserLoginModel(type: UserType.user);
    _userDao = UserDao();
    _formKey = GlobalKey<FormState>();
    _secureStorageHelper = SecureStorageHelper();
    _emailController = TextEditingController(text: "");
    _passwordController = TextEditingController(text: "");
    _savePassword = ValueNotifier<bool>(false);
    _passwordVisible = ValueNotifier<bool>(false);
    _signInloading = ValueNotifier<bool>(false);

    readFromSecureStorage();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Form(
              key: _formKey,
              child: Container(
                width: SizeConfig.screenWidth,
                padding: EdgeInsets.only(
                  left: SizeConfig.safeBlockHorizontal * 12,
                  top: SizeConfig.safeBlockVertical * 10,
                  right: SizeConfig.safeBlockHorizontal * 12,
                  bottom: SizeConfig.safeBlockVertical * 2,
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.safeBlockHorizontal * 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.safeBlockVertical * 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: SizeConfig.safeBlockHorizontal * 15,
                              height: SizeConfig.safeBlockVertical * 15,
                              child: Image.asset(
                                  'assets/images/flutter-icon-rmbg.png'),
                            ),
                            const Text(
                              "Contacts\nWelcome back!",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 25.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 5,
                      ),
                      Observer(
                        builder: (_) => TextFormField(
                          validator: emailValidator(),
                          onChanged: updateEmail,
                          controller: _emailController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Email",
                              hintText: 'Enter valid email as abc@gmail.com'),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                      ),
                      ValueListenableBuilder(
                        valueListenable: _passwordVisible,
                        builder: (context, passwordVisible, _) => TextFormField(
                          obscureText: !_passwordVisible.value,
                          validator: requiredTextValidator(),
                          onChanged: updatePassword,
                          controller: _passwordController,
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
                                _passwordVisible.value =
                                    !_passwordVisible.value;
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.safeBlockVertical * 2),
                        child: AnimatedBuilder(
                          animation: _savePassword,
                          builder: (context, _) {
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              activeColor: Colors.purple,
                              value: _savePassword.value,
                              onChanged: (_) =>
                                  _savePassword.value = !_savePassword.value,
                              title: const Text("Remember me"),
                            );
                          },
                        ),
                      ),
                      GradientElevatedButton(
                        onPressed: () => signIn(),
                        child: AnimatedBuilder(
                          animation: _signInloading,
                          builder: (context, _) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _signInloading.value
                                  ? SizedBox(
                                      width: 30.0,
                                      height: 30.0,
                                      child: LoadingHelper.showButtonLoading(),
                                    )
                                  : Text(
                                      'Sign In',
                                      style: TextStyle(
                                        color: Colors.grey[50],
                                        fontSize: 25.0,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                      ),
                      TextButton(
                        onPressed: () {
                          NavigatorHelper().navigateToWidget(
                              context, const RecoverPasswordPage());
                        },
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                              alignment: Alignment.bottomCenter),
                          onPressed: () => NavigatorHelper().navigateToWidget(
                              context, CreateAccountStepsPage()),
                          child: const Text(
                            'New user? Create Account',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void signIn() {
    if (_formKey.currentState!.validate()) {
      _signInloading.value = !_signInloading.value;

      _userLogin.password = EncrypterHelper.encrypt(_userLogin.password!);

      _userDao.signIn(_userLogin).then(
        (userSignedIn) {
          if (userSignedIn != null) {
            saveToSecureStorage(userSignedIn).then((_) => NavigatorHelper()
                .navigateToWidget(context, const ListContactPage(),
                    removeUntil: true));
          } else {
            _signInloading.value = !_signInloading.value;

            MessageHelper.showErrorMessage(
              context,
              "User email or password incorrect!",
            );
          }
        },
      );
    }
  }

  Future<void> saveToSecureStorage(User userSignedIn) async {
    await _secureStorageHelper.write(
        "REMEMBER_ME", _savePassword.value.toString().toLowerCase());
    await _secureStorageHelper.write("USER", jsonEncode(userSignedIn.toJson()));

    if (_savePassword.value) {
      await _secureStorageHelper.write("EMAIL", userSignedIn.email);
      await _secureStorageHelper.write(
          "PASSWORD", EncrypterHelper.decrypt(userSignedIn.password!));
    }
  }

  Future<void> readFromSecureStorage() async {
    _savePassword.value =
        (await _secureStorageHelper.read("REMEMBER_ME") ?? "false") == "true";

    if (_savePassword.value) {
      _emailController.text = await _secureStorageHelper.read("EMAIL") ?? "";
      updateEmail(_emailController.text);

      _passwordController.text =
          await _secureStorageHelper.read("PASSWORD") ?? "";
      updatePassword(_passwordController.text);
    }
  }

  void updateEmail(email) {
    _userLogin.setEmail(email);
  }

  void updatePassword(password) {
    _userLogin.setPassword(password);
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
}
