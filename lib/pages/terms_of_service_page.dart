import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/dark_theme_preference_helper.dart';
import '../helpers/size_config.dart';
import '../widgets/app_bar.dart';

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    ValueNotifier<bool> isDarkTheme = ValueNotifier<bool>(
        Provider.of<DarkThemeProvider>(context, listen: false).darkTheme);

    return Scaffold(
      appBar:
          getEditingAppBar(context, "Terms of Service", leadingText: "Back"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: SizeConfig.safeBlockVertical * 3,
            horizontal: SizeConfig.safeBlockVertical * 3,
          ),
          child: Column(
            children: [
              Image.network(
                  "https://www.gstatic.com/android/market_images/web/play_prism_hlock_2x.png"),
              ValueListenableBuilder(
                  valueListenable: isDarkTheme,
                  builder: (context, value, _) {
                    return RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: isDarkTheme.value
                                ? Colors.grey[50]
                                : Colors.grey[850],
                            fontSize: 16.0),
                        children: const <TextSpan>[
                          TextSpan(
                            text: "1. Introduction\n",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 28.0),
                          ),
                          TextSpan(
                            text:
                                "Applicable Terms. Thanks for using Google Play. Google Play is a service provided by Google LLC (\"Google\", \"we\" or \"us\"), located at 1600 Amphitheatre Parkway, Mountain View, California 94043, USA. Your use of Google Play and the apps (including Android Instant Apps), games, music, movies, books, magazines, or other digital content or services (referred to as \"Content\") available through it is subject to these Google Play Terms of Service and the Google Terms of Service (\"Google ToS\") ( together referred to as the \"Terms\"). Google Play is a \"Service\" as described in the Google ToS. If there is any conflict between the Google Play Terms of Service and the Google ToS, the Google Play Terms of Service shall prevail.\n",
                          ),
                          TextSpan(
                            text: "2. Your Use of Google Play\n",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 28.0),
                          ),
                          TextSpan(
                            text:
                                "Access to and Use of Content. You may use Google Play to browse, locate, view, stream, or download Content for your mobile, computer, tv, watch, or other supported device (\"Device\"). To use Google Play, you will need a Device that meets the system and compatibility requirements for the relevant Content, working Internet access, and compatible software. The availability of Content and features will vary between countries and not all Content or features may be available in your country. Some Content may be available to share with family members. Content may be offered by Google or made available by third-parties not affiliated with Google. Google is not responsible for and does not endorse any Content made available through Google Play that originates from a source other than Google.\n",
                          ),
                          TextSpan(
                            text:
                                "Age Restrictions. In order to use Google Play, you must have a valid Google account (\"Google Account\"), subject to the following age restrictions. If you are considered a minor in your country, you must have your parent or legal guardian's permission to use Google Play and to accept the Terms. You must comply with any additional age restrictions that might apply for the use of specific Content or features on Google Play. Family managers and family members must meet these additional requirements as well.\n",
                          ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
