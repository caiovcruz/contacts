import 'dart:convert';
import 'dart:io';

import 'package:contacts/helpers/image_picker_helper.dart';
import 'package:contacts/pages/account_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';

import '../helpers/dark_theme_preference_helper.dart';
import '../helpers/navigator_helper.dart';
import '../helpers/secure_storage_helper.dart';
import '../helpers/size_config.dart';
import '../models/user.dart';
import '../models/user_gender.dart';
import '../models/user_model.dart';
import '../pages/contact_page.dart';
import '../pages/login_page.dart';
import '../pages/terms_of_service_page.dart';
import 'colored_safearea.dart';

class ContactDrawer extends StatelessWidget {
  const ContactDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isDarkTheme = ValueNotifier<bool>(
        Provider.of<DarkThemeProvider>(context, listen: false).darkTheme);

    return FutureBuilder<User?>(
      future: loadUserSignedIn(),
      builder: (context, AsyncSnapshot<User?> userSnapshot) {
        return Drawer(
          child: ColoredSafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      FutureBuilder<File?>(
                        future: getBackgroundProfileImageFile(
                            userSnapshot.data?.backgroundProfileImagePath),
                        builder: (context,
                            AsyncSnapshot<File?> backgroundFileSnapshot) {
                          return UserAccountsDrawerHeader(
                            decoration: BoxDecoration(
                              image: backgroundFileSnapshot.data != null
                                  ? DecorationImage(
                                      image: Image.file(
                                              backgroundFileSnapshot.data!)
                                          .image,
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
                            ),
                            accountEmail: userSnapshot.data?.email != null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Text(
                                      "${userSnapshot.data?.email}",
                                      style: TextStyle(
                                        color: Colors.grey[850],
                                      ),
                                    ),
                                  )
                                : Container(),
                            accountName: userSnapshot.data?.email != null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Text(
                                      "${userSnapshot.data?.name}",
                                      style: TextStyle(
                                        color: Colors.grey[850],
                                      ),
                                    ),
                                  )
                                : Container(),
                            currentAccountPicture: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: FutureBuilder<File?>(
                                future: getProfileImageFile(
                                    userSnapshot.data?.profileImagePath),
                                builder: (context,
                                    AsyncSnapshot<File?> fileSnapshot) {
                                  return CircleAvatar(
                                    radius: 50.0,
                                    foregroundImage: loadProfileImage(
                                        userSnapshot.data?.gender,
                                        fileSnapshot.data),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("New Contact"),
                        onTap: () =>
                            NavigatorHelper().popRoute(context).showPageModal(
                                  context,
                                  ContactPage(),
                                ),
                      ),
                      ListTile(
                        title: const Text("Terms of Service"),
                        onTap: () => NavigatorHelper()
                            .popRoute(context)
                            .navigateToWidget(
                                context, const TermsOfServicePage()),
                      ),
                      ListTile(
                        title: const Text("Sign Out"),
                        onTap: () => signOut(context),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
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
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: Icon(
                              Icons.settings,
                              color: Colors.grey[50],
                            ),
                            title: Text(
                              "Settings",
                              style: TextStyle(
                                color: Colors.grey[50],
                              ),
                            ),
                            onTap: () => NavigatorHelper()
                                .popRoute(context)
                                .navigateToWidget(
                                  context,
                                  AccountPage.edit(
                                    user: BaseUserModel.fromUser(
                                        userSnapshot.data!),
                                  ),
                                ),
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: isDarkTheme,
                          builder: (context, value, _) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: FlutterSwitch(
                              width: 40.0,
                              height: 40.0,
                              toggleSize: 40.0,
                              value: isDarkTheme.value,
                              borderRadius: 30.0,
                              padding: 2.0,
                              activeToggleColor: const Color(0xFF2F363D),
                              activeSwitchBorder: Border.all(
                                color: Colors.white,
                                width: 6.0,
                              ),
                              activeColor: const Color(0xFFD1D5DA),
                              activeIcon: const Icon(
                                Icons.wb_sunny,
                                color: Color(0xFFFFDF5D),
                              ),
                              inactiveToggleColor: Colors.black,
                              inactiveSwitchBorder: Border.all(
                                color: Colors.white,
                                width: 6.0,
                              ),
                              inactiveColor: const Color(0xFF271052),
                              inactiveIcon: const Icon(
                                Icons.nightlight_round,
                                color: Color(0xFFF8E3A1),
                              ),
                              onToggle: (isDarkModeEnabled) {
                                isDarkTheme.value = !isDarkTheme.value;

                                Provider.of<DarkThemeProvider>(context,
                                        listen: false)
                                    .darkTheme = isDarkModeEnabled;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<User> loadUserSignedIn() async {
    return User.fromJson(
        jsonDecode((await SecureStorageHelper().read("USER"))!));
  }

  Future<File?> getBackgroundProfileImageFile(
      String? userBackgroundProfileImageFilePath) async {
    if (userBackgroundProfileImageFilePath != null) {
      return await ImagePickerHelper.getFileFromExStorage(
          userBackgroundProfileImageFilePath,
          ImagePickerHelper.getBackgroundProfileImageFilesPath());
    }

    return null;
  }

  Future<File?> getProfileImageFile(String? userProfileImageFilePath) async {
    if (userProfileImageFilePath != null) {
      return await ImagePickerHelper.getFileFromExStorage(
          userProfileImageFilePath,
          ImagePickerHelper.getProfileImageFilesPath());
    }

    return null;
  }

  ImageProvider<Object>? loadProfileImage(
      UserGender? gender, File? userProfileImageFile) {
    return userProfileImageFile != null
        ? Image.file(userProfileImageFile).image
        : AssetImage(
            "assets/images/${gender != null ? '${UserGender.values[gender.index].name}-user' : 'male-user'}.png");
  }

  signOut(BuildContext context) async {
    SecureStorageHelper().delete("USER").then((_) => NavigatorHelper()
        .navigateToWidget(context, const LoginPage(), removeUntil: true));
  }
}
