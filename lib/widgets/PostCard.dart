import 'dart:io';
import 'dart:convert';

import 'package:dribbble/helpers/DataProvider.dart';
import 'package:dribbble/pages/PostDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:async/async.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class PostCard extends StatefulWidget {
  final Map postData;

  PostCard(this.postData);

  @override
  createState() => PostCardState(this.postData);
}

class PostCardState extends State<PostCard> {
  final Map postData;

  PostCardState(this.postData);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => PostDetails(postData))),
      child: Center(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
              child: Stack(children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffe6e6e6),
                        blurRadius: 2.0,
                        spreadRadius: 0.001,
                        offset: const Offset(8.0, 8.0),
                      ),
                    ],
                  ),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0.0),
                          child: Text(
                            this.postData['title'].toString(),
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0.0),
                          child: Text(this.postData['author'].toString()),
                        ),
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3),
                            BlendMode.darken,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: FadeInImage.assetNetwork(
                              placeholder:
                                  'lib/assets/landscape_placeholder.png',
                              image: postData['postLink'],
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ),
                              Text(postData['likes'].toString())
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ]))),
    );
  }
}
