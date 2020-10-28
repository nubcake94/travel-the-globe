import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:travel_the_globe/screens/registerscreen.dart';
import 'package:travel_the_globe/utilities/widgets/form_login.dart';
import 'package:travel_the_globe/utilities/widgets/social_login.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image(
                width: 100.0,
                height: 100.0, // TODO figure out this logo
                image: AssetImage("assets/images/logo.png"),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                      child: SocialLogins(
                        google: () {},
                        facebook: () {},
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 56.0),
                    child: LoginForm(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account yet?\t",
                        children: [
                          TextSpan(
                            text: "Register here!",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen())),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
