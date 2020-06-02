import 'dart:io';
import 'dart:convert';

import 'package:dribbble/helpers/DataProvider.dart';
import 'package:dribbble/helpers/FetchDataException.dart';
import 'package:dribbble/pages/UserPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:async/async.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class PostDetails extends StatelessWidget {
  final postDetails;
  PostDetails(this.postDetails);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                ),
                onPressed: () => Navigator.of(context).pop())),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0.0),
              child: Text(
                this.postDetails['title'].toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
            GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserPage(this.postDetails['author'].toString()),
                  ),
                )
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0.0),
                child: Text(this.postDetails['author'].toString()),
              ),
            ),
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                // child: FadeInImage.assetNetwork(
                //   placeholder:
                //       'lib/assets/landscape_placeholder.png',
                //   image: postData['postLink'],
                // ),
                child: Center(
                  child: Container(
                    color: Colors.white,
                    child: CachedNetworkImage(
                      imageUrl: postDetails['postLink'],
                      placeholder: (context, url) => Container(
                          color: Colors.white,
                          height: 200,
                          child: Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                  Text(postDetails['likes'].toString())
                ],
              ),
            ),
            Divider(
              thickness: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0.0),
              child: Text(this.postDetails['subtitle'].toString()),
            ),
          ],
        ));
  }
}
