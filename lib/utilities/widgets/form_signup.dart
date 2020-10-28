import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:travel_the_globe/screens/globescreen.dart';
import 'package:travel_the_globe/utilities/constants/decorations.dart' as decorations;

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<_SignUpFormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseReference db = FirebaseDatabase.instance.reference().child("Users");
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
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
                  controller: nameController,
                  decoration: decorations.inputDecoration('Enter username'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter username';
                    }
                    return null;
                  }),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: emailController,
                  decoration: decorations.inputDecoration('Enter email'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter email';
                    }
                    return null;
                  }),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: passwordController,
                  obscureText: true,
                  decoration: decorations.inputDecoration('Enter password'),
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
                  decoration: decorations.inputDecoration('Enter age'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter age';
                    }
                    return null;
                  }),
            ),
            RaisedButton(
              onPressed: () => _addToFirebase(),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _addToFirebase() {
    // make this nice
    firebaseAuth.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text).then((result) {
      db.child(result.user.uid).set({"email": emailController.text, "age": ageController.text, "name": nameController.text}).then((res) => {
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
