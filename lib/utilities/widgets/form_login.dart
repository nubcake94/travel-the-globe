import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_the_globe/screens/globescreen.dart';
import 'package:travel_the_globe/utilities/constants/decorations.dart' as decorations;

class LoginForm extends StatefulWidget {
  LoginForm({Key key}) : super(key: key);

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<LoginFormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: emailController,
                style: TextStyle(color: Colors.black),
                decoration: decorations.inputDecoration(hintText: 'Enter email'),
                validator: (value) {
                  if (value.isEmpty) return 'Enter email';
                  return EmailValidator.validate(value) ? null : 'Wrong format';
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.black),
                decoration: decorations.inputDecoration(hintText: 'Enter password'),
                validator: (value) => value.isEmpty ? 'Enter password' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void login() {
    firebaseAuth
        .signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
        .then((result) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GlobeScreen(userId: result.user.uid)),
      );
    }).catchError((error) {
      print(error.message);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(error.message),
              actions: [FlatButton(onPressed: () => Navigator.of(context).pop(), child: Text('Ok'))],
            );
          });
    });
  }
}
