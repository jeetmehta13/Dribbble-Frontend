import 'dart:io';
import 'dart:convert';

import 'package:dribbble/helpers/DataProvider.dart';
import 'package:dribbble/helpers/FetchDataException.dart';
import 'package:dribbble/widgets/PostCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:async/async.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class RecentPage extends StatefulWidget {
  @override
  createState() => RecentPageState();
}

class RecentPageState extends State<RecentPage>
    with AutomaticKeepAliveClientMixin<RecentPage> {
  AsyncMemoizer _memoizer = AsyncMemoizer();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Map<String, Map> posts;

  bool needsRefresh = false;

  @override
  bool get wantKeepAlive => needsRefresh == null ? true : !needsRefresh;

  RecentPageState() {
    needsRefresh = false;
    posts = null;
  }

  @override
  Widget build(BuildContext context) {

    super.build(context);
    needsRefresh = false;

    final placeholder = Center(
      child: Column(
        children: <Widget>[
          Image(
            image: AssetImage('lib/assets/dribbble-logo.png'),
            height: 40,
          ),
          Text(
            "No Data to Show!",
            style: TextStyle(color: Color(0xffea4c89)),
          )
        ],
      ),
    );

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
                      return placeholder;
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
                              print(ele);
                          ret.add(Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: PostCard(ele),
                          ));
                        }
                      }
                    }
                    return ListView(
                      shrinkWrap: true,
                      children: ret,
                    );
                  }
                  default: return placeholder; 
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
        Response response = await dio.get(DataProvider.getAllPosts);
        temp = json.decode(response.toString());
        print(temp);
        ret['postData'] = temp;
        if (!ret['postData'].containsKey('success') ||
            !ret['postData'].containsKey('data') ||
            !ret['postData']['success'])
        {
          FetchDataException();
        }  
        
      } catch (e) {
        ret['postData'] = {};
      }
      print(ret);
      return ret;
    });
  }
}
