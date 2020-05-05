import 'package:dribbble/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:dribbble/cache/UserCache.dart';
import 'package:dribbble/pages/LoginPage.dart';
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  int isLoggedin;
  final userCache = UserCache();

  MyAppState(){
    isLoggedin = 0; // 0-> checking, 1 -> loggedout, 2-> loggedin 
  }

  void checkLoginStatus() async {
    try {
      if(await userCache.exists())
      {
        Map userData = json.decode(await userCache.read());
        if(userData.containsKey('success') && userData['success'] && userData.containsKey('data'))
        {
          setState(() {
            isLoggedin = 2;
          });
        }
        else {
          setState(() {
            isLoggedin = 1;
          });
        }
      }
      else
      {
        setState(() {
          isLoggedin = 1;
        });
      }
    } catch (e) {
      setState(() {
          isLoggedin = 1;
        });
    }
  }

  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if(isLoggedin == 0) checkLoginStatus();

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: SafeArea(
        top: true,
        bottom: false,
        left: false,
        right: false,
        child: (isLoggedin == 1)?(LoginPage()):(isLoggedin == 2)?(HomePage()):(CircularProgressIndicator()),
      ),
    );
  }
}
