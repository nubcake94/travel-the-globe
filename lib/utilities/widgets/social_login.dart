import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SocialLogins extends StatelessWidget {
  final Function _googleLoginFunction;
  final Function _facebookLoginFunction;

  SocialLogins({@required Function google, @required Function facebook})
      : _googleLoginFunction = google,
        _facebookLoginFunction = facebook;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SignInButton(
            Buttons.Google,
            text: 'Google login',
            onPressed: () => _googleLoginFunction,
            elevation: 6.0,
          ),
        ),
        SizedBox(
          height: 0.0,
          width: 16.0,
        ),
        Expanded(
          child: SignInButton(
            Buttons.Facebook,
            text: 'Facebook login',
            onPressed: () => _facebookLoginFunction,
            elevation: 6.0,
          ),
        ),
      ],
    );
  }
}
