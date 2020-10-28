import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:travel_the_globe/screens/globescreen.dart';
import 'package:travel_the_globe/utilities/constants/colors.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<_LoginFormState>();
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
                decoration: InputDecoration(
                  hintText: 'Enter email',
                  hintStyle: TextStyle(color: Colors.white24),
                  fillColor: Colors.white10,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value.isEmpty ? 'Enter email' : null,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  hintStyle: TextStyle(color: Colors.white24),
                  fillColor: Colors.white10,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    borderSide: BorderSide.none, // for fill
                  ),
                ),
                validator: (value) => value.isEmpty ? 'Enter password' : null,
              ),
            ),
            RaisedButton(
              onPressed: () => _login(),
              child: Text('Log in'),
            )
          ],
        ),
      ),
    );
  }

  void _login() {
    firebaseAuth
        .signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
        .then((result) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GlobeScreen(/*uid: result.user.uid*/)),
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
