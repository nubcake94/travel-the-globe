import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:travel_the_globe/screens/registerscreen.dart';
import 'package:travel_the_globe/utilities/constants/colors.dart';
import 'package:travel_the_globe/utilities/widgets/appbar_notched_bottom.dart';
import 'package:travel_the_globe/utilities/widgets/form_login.dart';
import 'package:travel_the_globe/utilities/widgets/social_login.dart';

class LoginScreen extends StatelessWidget {
  GlobalKey<LoginFormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Image(
                  width: 200.0,
                  height: 200.0,
                  image: AssetImage("assets/images/logo.png"),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                      child: SocialLogins(
                        google: () {},
                        facebook: () {},
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    child: LoginForm(key: formKey),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account yet?\t",
                        children: [
                          TextSpan(
                            text: "Register here!",
                            style: TextStyle(color: AppColorPalette.BabyBlue, fontWeight: FontWeight.bold),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => formKey.currentState.login(),
        elevation: 8.0,
        backgroundColor: Colors.white,
        splashColor: AppColorPalette.BabyBlue,
        child: Icon(Icons.login),
      ),
      bottomNavigationBar: NotchedBottomAppBar(
        color: Colors.grey[800],
        height: 50.0,
      ),
    );
  }
}
