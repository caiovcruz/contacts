import 'dart:convert';
import 'dart:io';

import 'package:contacts/helpers/image_picker_helper.dart';
import 'package:contacts/pages/account_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';

import '../helpers/dark_theme_preference_helper.dart';
import '../helpers/navigator_helper.dart';
import '../helpers/secure_storage_helper.dart';
import '../models/user.dart';
import '../models/user_gender.dart';
import '../models/user_model.dart';
import '../pages/contact_page.dart';
import '../pages/login_page.dart';
import '../pages/terms_of_service_page.dart';

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
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple,
                      Colors.deepPurple,
                    ],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.5),
                      blurRadius: 1.5,
                    ),
                  ],
                ),
                accountEmail: Text("${userSnapshot.data?.email}"),
                accountName: Text("${userSnapshot.data?.name}"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: FutureBuilder<File?>(
                      future: getProfileImageFile(
                          userSnapshot.data?.profileImagePath),
                      builder: (context, AsyncSnapshot<File?> fileSnapshot) {
                        return CircleAvatar(
                          radius: 50.0,
                          foregroundImage: loadProfileImage(
                              userSnapshot.data?.gender, fileSnapshot.data),
                        );
                      }),
                ),
                otherAccountsPictures: [
                  ValueListenableBuilder(
                    valueListenable: isDarkTheme,
                    builder: (context, value, _) => FlutterSwitch(
                      width: 100.0,
                      height: 55.0,
                      toggleSize: 45.0,
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

                        Provider.of<DarkThemeProvider>(context, listen: false)
                            .darkTheme = isDarkModeEnabled;
                      },
                    ),
                  ),
                  IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                      onPressed: () => NavigatorHelper()
                          .popRoute(context)
                          .navigateToWidget(
                              context,
                              AccountPage.edit(
                                  user: BaseUserModel.fromUser(
                                      userSnapshot.data!)))),
                ],
              ),
              ListTile(
                title: const Text("New Contact"),
                onTap: () => NavigatorHelper()
                    .popRoute(context)
                    .navigateToWidget(context, ContactPage()),
              ),
              ListTile(
                title: const Text("Terms of Service"),
                onTap: () => NavigatorHelper()
                    .popRoute(context)
                    .navigateToWidget(context, const TermsOfServicePage()),
              ),
              ListTile(
                title: const Text("Sign Out"),
                onTap: () => signOut(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<User> loadUserSignedIn() async {
    return User.fromJson(
        jsonDecode((await SecureStorageHelper().read("USER"))!));
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
