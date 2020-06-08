import 'dart:io';
import 'dart:convert';

import 'package:dribbble/helpers/DataProvider.dart';
import 'package:dribbble/helpers/FetchDataException.dart';
import 'package:dribbble/pages/PostDetails.dart';
import 'package:dribbble/pages/UserPage.dart';
import 'package:dribbble/widgets/PostCard.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:async/async.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class FollowingPageCard extends StatefulWidget {
  final Map userData;
  FollowingPageCard(this.userData);
  createState() => FollowingPageCardState(this.userData);
}

class FollowingPageCardState extends State<FollowingPageCard> {
  final Map userData;
  int follows;
  FollowingPageCardState(this.userData) {
    follows = userData['follows'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 200,
      child: ListTile(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UserPage(userData['userId'].toString()))),
          leading: Container(
            height: 100.0,
            child: CircleAvatar(
              radius: 30.0,
              child: Image.asset('lib/assets/profile_placeholder.png'),
            ),
          ),
          title: Text(userData['userId'].toString()),
          subtitle: Text(
            userData['name'].toString(),
            overflow: TextOverflow.ellipsis,
            // style: TextStyle(fontSize: 12.0),
          ),
          // title: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: <Widget>[
          //     Text(userData['userId'].toString()),
          //     Text(
          //       userData['name'].toString(),
          //       overflow: TextOverflow.ellipsis,
          //       // style: TextStyle(fontSize: 12.0),
          //     ),
          //   ],
          // ),
          trailing: (follows == 1)
              ? ButtonTheme(
                  height: 25,
                  minWidth: 120.0,
                  child: (OutlineButton(
                    highlightedBorderColor: Colors.black,
                    color: Colors.white,
                    onPressed: setFollowing,
                    child: Text("Following"),
                  )),
                )
              : (follows == 0)
                  ? ButtonTheme(
                      height: 25,
                      minWidth: 120.0,
                      child: (FlatButton(
                          color: Color(0xffea4c89),
                          onPressed: () => setFollowing(),
                          child: Text(
                            'Follow',
                            style: TextStyle(color: Colors.white),
                          ))),
                    )
                  : (Container(
                      width: 0,
                    ))),
    );
  }

  void showSnackBar(String error) {
    setState(() {
      follows = (follows == 1) ? 0 : 1;
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(error),
        duration: Duration(seconds: 2),
      ));
    });
  }

  Future<Null> setFollowing() async {
    follows = (follows == 1) ? 0 : 1;
    setState(() {});
    try {
      var dio = Dio();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      var cj = PersistCookieJar(dir: appDocDir.path, ignoreExpires: false);
      dio.interceptors.add(CookieManager(cj));

      Response response = await dio.post(DataProvider.setFollowing,
          data: {'userId': userData['userId'], 'status': follows});
      print(response);
    } catch (e) {
      showSnackBar("Some Error Occured!");
    }
  }
}
