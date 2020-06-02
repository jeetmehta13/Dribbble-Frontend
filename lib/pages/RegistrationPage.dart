import 'dart:io';
import 'dart:convert';

import 'package:dribbble/helpers/DataProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class RegistrationPage extends StatefulWidget {
  @override
  createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final emailValue = TextEditingController();
  final passwordValue = TextEditingController();
  final confirmPassword = TextEditingController();
  final userIdValue = TextEditingController();
  final nameValue = TextEditingController();

  bool registrationPressed;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  RegistrationPageState() {
    registrationPressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final emailTextField = Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
        child: TextFormField(
          cursorColor: Color(0xffea4c89),
          decoration: InputDecoration(
            hintText: 'Enter Your Email',
            hintStyle: TextStyle(color: Color(0xff9FA0B5)),
            fillColor: Color(0xfff7f8fa),
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          ),
          controller: emailValue,
          style: TextStyle(color: Colors.black),
          validator: (value) {
            Pattern pattern =
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            RegExp regex = RegExp(pattern);
            if (value.isEmpty || !regex.hasMatch(value.trim())) {
              return 'Clank! Please enter valid email';
            } else {
              return null;
            }
          },
        ),
      ),
    );

    final passwordTextField = Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
        child: TextFormField(
          cursorColor: Color(0xffea4c89),
          decoration: InputDecoration(
            hintText: 'Enter Your Password',
            hintStyle: TextStyle(color: Color(0xff9FA0B5)),
            fillColor: Color(0xfff7f8fa),
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          ),
          obscureText: true,
          controller: passwordValue,
          style: TextStyle(color: Colors.black),
          validator: (value) {
            if (value.isEmpty) {
              return 'Woah there, chief. Password can\'t be empty';
            } else {
              return null;
            }
          },
        ),
      ),
    );

    final confirmPasswordTextField = Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
        child: TextFormField(
          cursorColor: Color(0xffea4c89),
          decoration: InputDecoration(
            hintText: 'Confirm Your Password',
            hintStyle: TextStyle(color: Color(0xff9FA0B5)),
            fillColor: Color(0xfff7f8fa),
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          ),
          obscureText: true,
          controller: confirmPassword,
          style: TextStyle(color: Colors.black),
          validator: (value) {
            if (value.isEmpty) {
              return 'Woah there, chief. Password can\'t be empty';
            } else if (value != passwordValue.text.trim()) {
              return 'Passwords have to match!';
            } else {
              return null;
            }
          },
        ),
      ),
    );

    final usernameTextField = Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
        child: TextFormField(
          cursorColor: Color(0xffea4c89),
          decoration: InputDecoration(
            hintText: 'Enter Your Username',
            hintStyle: TextStyle(color: Color(0xff9FA0B5)),
            fillColor: Color(0xfff7f8fa),
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          ),
          controller: userIdValue,
          style: TextStyle(color: Colors.black),
          validator: (value) {
            if (value.isEmpty) {
              return 'Enter a username';
            } else {
              return null;
            }
          },
        ),
      ),
    );

    final nameTextField = Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
        child: TextFormField(
          cursorColor: Color(0xffea4c89),
          decoration: InputDecoration(
            hintText: 'Enter Your Name',
            hintStyle: TextStyle(color: Color(0xff9FA0B5)),
            fillColor: Color(0xfff7f8fa),
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          ),
          controller: nameValue,
          style: TextStyle(color: Colors.black),
          validator: (value) {
            if (value.isEmpty) {
              return 'Enter your name';
            } else {
              return null;
            }
          },
        ),
      ),
    );

    final registerButton = Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        height: 50.0,
        child: RaisedButton(
          onPressed: regAuth,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
          color: Color(0xffea4c89),
          child: (!registrationPressed)
              ? (Text(
                  "Register",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ))
              : (Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Registering...",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                )),
        ),
      ),
    );

    final signinButton = ButtonTheme(
        minWidth: 30.0,
        child: FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Already a member? Sign in")));

    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          color: Colors.white,
          child: Center(
              child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Hero(
                          tag: 'logo',
                          child: SvgPicture.asset(
                            'lib/assets/dribbble-4.svg',
                            height: 50,
                            semanticsLabel: 'Dribbble logo',
                            color: Color(0xffea4c89),
                          ),
                        ),
                      ),
                      nameTextField,
                      emailTextField,
                      usernameTextField,
                      passwordTextField,
                      confirmPasswordTextField,
                      registerButton,
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: signinButton)
                    ],
                  ))),
        ));
  }

  void showSnackBar(String error) {
    setState(() {
      registrationPressed = false;
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(error),
        duration: Duration(seconds: 2),
      ));
    });
  }

  void regAuth() async {
    try {
      final form = _formKey.currentState;
      if (form.validate()) {
        setState(() {
          registrationPressed = true;
        });
        var dio = Dio();
        Directory appDocDir = await getApplicationDocumentsDirectory();
        var cj = PersistCookieJar(dir: appDocDir.path, ignoreExpires: false);
        dio.interceptors.add(CookieManager(cj));

        Response response = await dio.post(DataProvider.register, data: {
          'email': emailValue.text.trim(),
          'password': passwordValue.text.trim(),
          'name': nameValue.text.trim(),
          'userId': userIdValue.text.trim()
        });
        Map resp = json.decode(response.toString());
        if (resp.containsKey('success') && response.data['success']) {
          //await userCache.write(response.data);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Successfully Registered'),
            duration: Duration(seconds: 2),
          ));
          Navigator.of(context).pop();
        } else {
          showSnackBar("Some error occured");
        }
      } else
        showSnackBar("Some error occured");
    } catch (e) {
      showSnackBar("Some error occured");
    }
  }
}
