import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../helpers/navigator_helper.dart';
import '../helpers/size_config.dart';
import '../widgets/app_bar.dart';
import '../helpers/loading_helper.dart';
import '../helpers/message_helper.dart';
import '../models/email.dart';
import '../repositories/user_dao.dart';

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({Key? key}) : super(key: key);

  @override
  State<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  late UserDao _userDao;
  late GlobalKey<FormState> _formKey;
  late ValueNotifier<String> _email;
  late ValueNotifier<bool> _recoverloading;

  @override
  void initState() {
    super.initState();
    _userDao = UserDao();
    _formKey = GlobalKey<FormState>();
    _email = ValueNotifier<String>("");
    _recoverloading = ValueNotifier<bool>(false);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: getEditingAppBar(
        context,
        "Recover Password",
        actions: getActionsAppBar(
          context,
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
                const Text("Please enter your account email."),
                ValueListenableBuilder(
                  valueListenable: _email,
                  builder: (context, email, _) => TextFormField(
                    validator: emailValidator(),
                    onChanged: updateEmail,
                    initialValue: _email.value,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "E-mail *",
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

  List<Widget>? getActionsAppBar(BuildContext context) {
    return [
      getRecoverPasswordButton(context),
    ];
  }

  ElevatedButton getRecoverPasswordButton(BuildContext context) {
    return ElevatedButton(
      child: AnimatedBuilder(
          animation: _recoverloading,
          builder: (context, _) {
            return _recoverloading.value
                ? LoadingHelper.showButtonLoading()
                : const Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
          }),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _recoverloading.value = !_recoverloading.value;

          _userDao.getByEmail(_email.value).then((user) {
            if (user != null) {
              Email.sendEmail(
                user.name!,
                user.email!,
                Email.recoverPasswordSuject,
                Email.recoverPasswordMessage(user.password!),
              ).whenComplete(() {
                MessageHelper.showSuccessMessage(
                    context, "Email sent successfully!");

                NavigatorHelper()
                    .navigateToRoute(context, "/", removeUntil: true);
              });
            } else {
              _recoverloading.value = !_recoverloading.value;

              MessageHelper.showErrorMessage(
                context,
                "User email ${_email.value} does not exists!",
              );
            }
          });
        }
      },
    );
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

  void updateEmail(email) {
    _email.value = email;
  }
}
