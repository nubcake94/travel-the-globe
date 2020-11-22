import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:travel_the_globe/screens/globescreen.dart';
import 'package:travel_the_globe/utilities/constants/decorations.dart' as decorations;

class SignUpForm extends StatefulWidget {
  SignUpForm({Key key}) : super(key: key);

  @override
  SignUpFormState createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<SignUpFormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseReference db = FirebaseDatabase.instance.reference().child("Users");
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    ageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.black),
                decoration: decorations.inputDecoration(hintText: 'Enter email'),
                validator: (value) {
                  if (value.isEmpty) return 'Enter email';
                  return EmailValidator.validate(value) ? null : 'Wrong format';
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: passwordController,
                  style: TextStyle(color: Colors.black),
                  obscureText: true,
                  decoration: decorations.inputDecoration(hintText: 'Enter password'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter password';
                    }
                    return null;
                  }),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: ageController,
                  style: TextStyle(color: Colors.black),
                  decoration: decorations.inputDecoration(hintText: 'Enter age'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter age';
                    }
                    return null;
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void addToFirebase() {
    // make this nice
    firebaseAuth.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text).then((result) {
      db.child(result.user.uid).set({"email": emailController.text, "age": ageController.text}).then((res) => {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GlobeScreen(/*uid*/)),
            )
          });
    }).catchError((err) => {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Error"),
                  content: Text(err.message),
                  actions: [
                    FlatButton(
                      child: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              })
        });
  }
}
