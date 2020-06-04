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

class PostDetails extends StatelessWidget {
  final postDetails;
  PostDetails(this.postDetails);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            title: Text(
              this.postDetails['title'].toString(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black),
            ),
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                ),
                onPressed: () => Navigator.of(context).pop())),
        body: FutureBuilder(
          future: _fetchData(),
          builder: (context, snapshot) {
            List<Widget> ret = [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserPage(this.postDetails['author'].toString()),
                  ),
                ),
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
              Divider(
                thickness: 1.0,
              ),
            ];
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                {
                  if (snapshot.hasError)
                    ret.add(PlaceHolder("Could not load Content"));
                  else if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  else if (snapshot.data.containsKey('success') &&
                      snapshot.data.containsKey('data') &&
                      snapshot.data['success'] &&
                      snapshot.data['data'].containsKey('content')) {
                    ret.add(Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 30.0),
                      child: Text(
                        snapshot.data['data']['content'].toString(),
                      ),
                    ));
                  } else
                    ret.add(PlaceHolder("Could not load Content"));
                  return ListView(children: ret);
                }
              default:
                {
                  ret.add(PlaceHolder("Could not load Content"));
                  return ListView(children: ret);
                }
            }
          },
        ));
  }

  _fetchData() async {
    Map ret = {};

    var dio = Dio();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    var cj = PersistCookieJar(dir: appDocDir.path, ignoreExpires: false);
    dio.interceptors.add(CookieManager(cj));

    try {
      Response response = await dio.get(
          DataProvider.postDetails + '/' + postDetails['postId'].toString());
      ret = json.decode(response.toString());
      if (!ret.containsKey('success') ||
          !ret.containsKey('data') ||
          !ret['success']) FetchDataException();
    } catch (e) {
      ret = null;
    }
    print(ret);
    return ret;
  }
}
