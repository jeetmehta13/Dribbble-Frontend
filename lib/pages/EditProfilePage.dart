import 'dart:io';
import 'dart:convert';

import 'package:dribbble/helpers/DataProvider.dart';
import 'package:dribbble/helpers/FetchDataException.dart';
import 'package:dribbble/pages/UserPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dribbble/widgets/PlaceHolder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class EditProfilePage extends StatefulWidget {
  final Map userData;
  EditProfilePage(this.userData);
  @override
  createState() => EditProfilePageState(this.userData);
}

class EditProfilePageState extends State<EditProfilePage> {
  final nameValue = TextEditingController();
  final bioValue = TextEditingController();
  final userData;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  EditProfilePageState(this.userData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_backspace,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: <Widget>[
            Text(
              "Edit Profile",
              style: TextStyle(color: Colors.black),
            ),
            Expanded(child: Container()),
            IconButton(
              icon: Icon(
                Icons.check,
                color: Color(0xffea4c89),
              ),
              onPressed: null,
            )
          ],
        ),
      ),
      body: Container(
        child: Center(
          child: Form(
            child: ListView(
              children: <Widget>[
                Hero(
                  tag: 'prof',
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                    child: CircleAvatar(
                      radius: 50.0,
                      child: Image.asset('lib/assets/profile_placeholder.png'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Change Profile Picture",
                        style:
                            TextStyle(fontSize: 20.0, color: Color(0xffea4c89)),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  child: TextFormField(
                    // autocorrect: false,
                    autofocus: false,
                    controller: nameValue..text = userData['name'].toString(),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      // hintText: 'Name',
                      contentPadding:
                          const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'You need a name!';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                  child: TextFormField(
                    // autocorrect: false,
                    autofocus: false,
                    controller: bioValue
                      ..text = (userData['personalbio'] != null)
                          ? userData['personalbio'].toString()
                          : "",
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      // hintText: 'Name',
                      contentPadding:
                          const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    ),
                  ),
                ),
              ],
            ),
            key: _formKey,
          ),
        ),
      ),
    );
  }

  void editProfile() async {
    
  }

}
