import 'package:flutter/material.dart';
import 'package:intro_screen_onboarding_flutter/intro_app.dart';
import '../../Utility/Colors.dart';
import '../../Utility/Strings.dart';
import '../UserSignUp/user_sign_up.dart';

class OnBoarding extends StatelessWidget {
  OnBoarding({Key? key}) : super(key: key);

  final List<Introduction> list = [
    Introduction(
      title: "Easy To Use",
      subTitle:
          "Manage all expenses information in one place with the fastest performance and accuracy",
      imageUrl: imgIntroOne,
      titleTextStyle: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
      subTitleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      imageHeight: 250,
      imageWidth: 250,
    ),
    Introduction(
      title: 'Analytics',
      subTitle:
          "Get Your financial analysis and statistical information in an easy-to-understand format",
      imageUrl: imgIntroTwo,
      titleTextStyle: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
      subTitleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      imageHeight: 250,
      imageWidth: 250,
    ),
    Introduction(
      title: "Security & Privacy",
      subTitle:
          "Don't Worry! Your crucial data is end-to-end encrypted and it will be securely stored in cloud storage.",
      imageUrl: imgIntroThree,
      titleTextStyle: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
      subTitleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      imageHeight: 250,
      imageWidth: 250,
    ),
    Introduction(
      title: "Chat With Family",
      subTitle:
          "Talk with your family and feel free to share financial information with your family members.",
      imageUrl: imgIntroFour,
      titleTextStyle: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
      subTitleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      imageHeight: 250,
      imageWidth: 250,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IntroScreenOnboarding(
      backgroudColor: snowWhite,
      foregroundColor: primary,
      introductionList: list,
      onTapSkipButton: () => {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserSignUp(),
            ))
      },
      skipTextStyle: TextStyle(fontSize: 20, color: primary),
      // foregroundColor: Colors.red,
    );
  }
}
