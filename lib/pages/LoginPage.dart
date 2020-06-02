import 'dart:io';
import 'dart:convert';

import 'package:dribbble/cache/UserCache.dart';
import 'package:dribbble/helpers/DataProvider.dart';
import 'package:dribbble/helpers/Logout.dart';
import 'package:dribbble/pages/HomePage.dart';
import 'package:dribbble/pages/RegistrationPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class LoginPage extends StatefulWidget {
  @override
  createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final emailValue = TextEditingController();
  final passwordValue = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final userCache = UserCache();

  bool loginPressed;

  LoginPageState() {
    try {
      loginPressed = false;
      Logout().logout();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final emailTextField = Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 10.0),
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
    final signInButton = Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        height: 50.0,
        child: RaisedButton(
          onPressed: loginAuth,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
          color: Color(0xffea4c89),
          child: (!loginPressed)
              ? (Text(
                  "Sign In",
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
                        "Signing in...",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                )),
        ),
      ),
    );
    final registerButton = ButtonTheme(
        minWidth: 30.0,
        child: FlatButton(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => RegistrationPage())),
            child: Text("Not a member? Sign up now")));

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
                      emailTextField,
                      passwordTextField,
                      signInButton,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: registerButton,
                      )
                    ],
                  ))),
        ));
  }

  void showSnackBar(String error) {
    setState(() {
      loginPressed = false;
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(error),
        duration: Duration(seconds: 2),
      ));
    });
  }

  void loginAuth() async {
    Map resp;
    bool hasError = false;
    String errMsg = "Unexpected error";
    try {
      final form = _formKey.currentState;
      if (form.validate()) {
        setState(() {
          loginPressed = true;
        });
        var dio = Dio();
        Directory appDocDir = await getApplicationDocumentsDirectory();
        var cj = PersistCookieJar(dir: appDocDir.path, ignoreExpires: false);
        dio.interceptors.add(CookieManager(cj));

        Response response = await dio.post(DataProvider.login, data: {
          'email': emailValue.text.trim(),
          'password': passwordValue.text.trim(),
        });
        resp = json.decode(response.toString());
        if (resp.containsKey('success') && resp['success'] && resp.containsKey('data')) {
          await userCache.write(response.data);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          hasError = true;
          errMsg = "Username/password combination incorrect";
        }
      } else {
        hasError = true;
        errMsg = "Invalid Information";
      }
    } catch (e) {
        try {
          if(e.response.data.containsKey('success') && !e.response.data['success'] && e.response.data.containsKey('msg')){
          if(e.response.data['msg'] == "Incorrect Password")
          {
            hasError = true;
          errMsg = "Incorrect Password";
          }
          else if(e.response.data['msg'] == "Incorrect Email")
          {
            hasError = true;
          errMsg = "Incorrect Email";
          }
        }
        } catch (e) {
          hasError = true;
        errMsg = "Unexpected error";
        }
    }
    if (hasError) {
      showSnackBar(errMsg);
    }
  }
}
