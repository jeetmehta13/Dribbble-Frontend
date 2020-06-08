import 'dart:io';
import 'dart:convert';

import 'package:dribbble/helpers/DataProvider.dart';
import 'package:dribbble/helpers/FetchDataException.dart';
import 'package:dribbble/widgets/PlaceHolder.dart';
import 'package:dribbble/widgets/PostCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:async/async.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class FollowingPage extends StatefulWidget {
  @override
  createState() => FollowingPageState();
}

class FollowingPageState extends State<FollowingPage>
    with AutomaticKeepAliveClientMixin<FollowingPage> {
  AsyncMemoizer _memoizer = AsyncMemoizer();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool needsRefresh = false;

  @override
  bool get wantKeepAlive => needsRefresh == null ? true : !needsRefresh;

  FollowingPageState() {
    needsRefresh = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    needsRefresh = false;

    return RefreshIndicator(
        key: _refreshIndicatorKey,
        child: FutureBuilder(
            future: _fetchData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                case ConnectionState.done:
                  {
                    List<Widget> ret = [];
                    if (snapshot.hasError)
                      return PlaceHolder("Some Error Occured!");
                    else if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());
                    else if (snapshot.data.containsKey('postData') &&
                        snapshot.data.containsKey('postData') &&
                        snapshot.data['postData'].containsKey('success') &&
                        snapshot.data['postData'].containsKey('data') &&
                        snapshot.data['postData']['success'] &&
                        (snapshot.data['postData']['data'] as List).length >
                            0) {
                      for (Map ele in snapshot.data['postData']['data']) {
                        if (ele.containsKey('title') &&
                            ele.containsKey('author') &&
                            ele.containsKey('postLink') &&
                            ele.containsKey('likes')) {
                          // print(ele);
                          ret.add(Padding(
                            padding:
                                const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 5.0),
                            child: PostCard(ele),
                          ));
                        }
                      }
                    } else {
                      // print("xkdi");
                      ret.add(PlaceHolder("No Posts from Following!"));
                    }
                    return ListView(
                      shrinkWrap: true,
                      children: ret,
                    );
                  }
                default:
                  return PlaceHolder("Some Error Occured!");
              }
            }),
        onRefresh: _onRefresh);
  }

  Future<Null> _onRefresh() async {
    setState(() {
      needsRefresh = true;
      _memoizer = AsyncMemoizer();
    });
  }

  _fetchData() async {
    return this._memoizer.runOnce(() async {
      Map ret = {}, temp;

      var dio = Dio();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      var cj = PersistCookieJar(dir: appDocDir.path, ignoreExpires: false);
      dio.interceptors.add(CookieManager(cj));

      try {
        Response response = await dio.get(DataProvider.getFollowingPost);
        temp = json.decode(response.toString());
        // print(temp);
        ret['postData'] = temp;
        if (!ret['postData'].containsKey('success') ||
            !ret['postData'].containsKey('data') ||
            !ret['postData']['success']) {
          FetchDataException();
        }
      } catch (e) {
        ret['postData'] = {};
      }
      // print(ret);
      return ret;
    });
  }
}
