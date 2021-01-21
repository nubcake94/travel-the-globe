import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_the_globe/utilities/constants/colors.dart';
import 'package:travel_the_globe/utilities/widgets/appbar_notched_bottom.dart';
import 'package:travel_the_globe/utilities/widgets/form_signup.dart';

class RegisterScreen extends StatelessWidget {
  // TODO lehessen profilképet hozzáadni
  GlobalKey<SignUpFormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Image(
                  width: 200.0,
                  height: 200.0,
                  image: AssetImage("assets/images/logo.png"),
                ),
              ),
              SignUpForm(key: formKey),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NotchedBottomAppBar(
        color: Colors.grey[800],
        height: 50.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => formKey.currentState.addToFirebase(),
        elevation: 8.0,
        backgroundColor: Colors.white,
        splashColor: AppColorPalette.BabyBlue,
        child: Icon(Icons.login),
      ),
    );
  }
}
