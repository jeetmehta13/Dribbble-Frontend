import 'dart:io';
import 'dart:convert';

import 'package:dribbble/helpers/DataProvider.dart';
import 'package:dribbble/helpers/FetchDataException.dart';
import 'package:dribbble/pages/PostDetails.dart';

import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class AddPost extends StatefulWidget {
  @override
  createState() => AddPostState();
}

class AddPostState extends State<AddPost> {
  final titleValue = TextEditingController();
  final subtitleValue = TextEditingController();
  final contentValue = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  File imageFile;
  bool btnPressed;

  AddPostState() {
    imageFile = null;
    btnPressed = false;
  }

  @override
  Widget build(BuildContext context) {
    // btnPressed = false;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey,
            ),
            onPressed: () => Navigator.of(context).pop()),
        title: Text(
          "Add Post",
          style: TextStyle(color: Colors.black),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: FloatingActionButton(
          elevation: 10.0,
          onPressed: addPost,
          child:
              (!btnPressed) ? Icon(Icons.add) : (CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),)),
          heroTag: 'add',
          backgroundColor: Color(0xffea4c89),
        ),
      ),
      body: Container(
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: titleValue,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      contentPadding:
                          const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'You need a title!';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: subtitleValue,
                    decoration: InputDecoration(
                      hintText: 'Subtitle',
                      contentPadding:
                          const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'You need a subtitle!';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (imageFile == null)
                      ? GestureDetector(
                          onTap: getImage,
                          child: (Container(
                            height: 300.0,
                            color: Color(0xffebebeb),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.add,
                                    size: 100,
                                  ),
                                  Text(
                                    "Add your Art!",
                                    style: TextStyle(fontSize: 20.0),
                                  )
                                ],
                              ),
                            ),
                          )))
                      : (Stack(
                          children: <Widget>[
                            Image(image: FileImage(imageFile)),
                            Positioned(
                                right: 0.0,
                                top: 0.0,
                                child: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => setState(() {
                                          imageFile = null;
                                        })))
                          ],
                        )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLines: 10,
                    controller: contentValue,
                    decoration: InputDecoration(
                      fillColor: Color(0xfaf7f0f5),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: true,
                      hintText: 'Add Description',
                      contentPadding:
                          const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'You need a title!';
                      } else {
                        return null;
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getImage() async {
    try {
      imageFile = await ImagePicker.pickImage(
          source: ImageSource.gallery, maxHeight: 5000.0, maxWidth: 5000.0);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void showSnackBar(String error) {
    setState(() {
      btnPressed = false;
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(error),
        duration: Duration(seconds: 2),
      ));
    });
  }

  void addPost() async {
    try {
      final form = _formKey.currentState;
      if (form.validate()) {
        setState(() {
          btnPressed = true;
        });
        // print(btnPressed);
        var dio = Dio();
        Directory appDocDir = await getApplicationDocumentsDirectory();
        var cj = PersistCookieJar(dir: appDocDir.path, ignoreExpires: false);
        dio.interceptors.add(CookieManager(cj));

        FormData formData = FormData.fromMap({
          "title": titleValue.text.trim(),
          "subtitle": subtitleValue.text.trim(),
          "content": contentValue.text.trim(),
          "file": await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split("/").last,
              contentType: MediaType(
                'image',
                imageFile.path.split("/").last.split('.').last,
              ))
        });

        Response response =
            await dio.post(DataProvider.addPost, data: formData);
        Map resp = json.decode(response.toString());

        if (resp.containsKey('success') && resp['success']) {
          setState(() {
            btnPressed = false;
          });
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => PostDetails(resp['data'])));
        } else {
          FetchDataException();
        }
      }
    } catch (e) {
      showSnackBar("Error Uploading");
    }
  }
}
