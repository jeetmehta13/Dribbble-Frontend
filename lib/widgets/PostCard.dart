import 'dart:io';
import 'dart:convert';

import 'package:dribbble/helpers/DataProvider.dart';
import 'package:dribbble/pages/PostDetails.dart';
import 'package:dribbble/widgets/TransitionAnimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:async/async.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class PostCard extends StatefulWidget {
  final Map postData;

  PostCard(this.postData);

  @override
  createState() => PostCardState(this.postData);
}

class PostCardState extends State<PostCard>
    with AutomaticKeepAliveClientMixin<PostCard> {
  final Map postData;

  PostCardState(this.postData);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, SlideLeftRoute(page: PostDetails(postData))),
      child: Center(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
              child: Stack(children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 0.2, color: Colors.grey),
                        right: BorderSide(width: 0.2, color: Colors.grey),
                        left: BorderSide(width: 0.2, color: Colors.grey)),
                    color: Colors.white,
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Color(0xffe6e6e6),
                    //     blurRadius: 2.0,
                    //     spreadRadius: 0.001,
                    //     offset: const Offset(8.0, 8.0),
                    //   ),
                    // ],
                  ),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                      10.0, 8.0, 0.0, 0.0),
                              child: CircleAvatar(
                                radius: 17.0,
                                child: Image.asset(
                                    'lib/assets/profile_placeholder.png'),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 8.0, 10.0, 0.0),
                                  child: Text(
                                    this.postData['title'].toString(),
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 2.0, 10.0, 0.0),
                                  child:
                                      Text(this.postData['author'].toString(), style: TextStyle(fontSize: 10.0),),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3),
                            BlendMode.darken,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            // child: FadeInImage.assetNetwork(
                            //   placeholder:
                            //       'lib/assets/landscape_placeholder.png',
                            //   image: postData['postLink'],
                            // ),
                            child: Center(
                              child: Container(
                                color: Colors.white,
                                child: CachedNetworkImage(
                                  imageUrl: postData['postLink'],
                                  placeholder: (context, url) => Container(
                                      color: Colors.white,
                                      height: 200,
                                      child: Center(
                                          child: CircularProgressIndicator())),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                        ),
                      ],
                    ),
                  ),
                )
              ]))),
    );
  }
}
