import 'dart:io';
import 'dart:convert';

import 'package:dribbble/helpers/DataProvider.dart';
import 'package:dribbble/helpers/FetchDataException.dart';
import 'package:dribbble/widgets/FollowPageCard.dart';
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

class FollowPage extends StatefulWidget {
  final Map userData;
  final int initialIndex;
  FollowPage(this.userData, this.initialIndex);
  @override
  createState() => FollowPageState(this.userData, this.initialIndex);
}

class FollowPageState extends State<FollowPage>
    with SingleTickerProviderStateMixin {
  TabController controller;
  final Map userData;
  final int initialIndex;

  FollowPageState(this.userData, this.initialIndex);

  void initState() {
    super.initState();
    controller =
        new TabController(length: 2, vsync: this, initialIndex: initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafb),
      appBar: AppBar(
        // centerTitle: true,
        backgroundColor: Colors.white,
        bottom: TabBar(
          tabs: [
            Tab(
                child: Text(
              userData['followers'].toString() + ' Followers',
              style: TextStyle(color: Colors.black),
            )),
            Tab(
                child: Text(
              userData['following'].toString() + ' Following',
              style: TextStyle(color: Colors.black),
            ))
          ],
          controller: controller,
        ),
        leading: IconButton(
            icon: Icon(
              Icons.keyboard_backspace,
              color: Colors.grey,
            ),
            onPressed: () => Navigator.pop(context, true)),
        title: Text(
          userData['userId'],
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: TabBarView(
        children: [UserFollowers(userData), UserFollowing(userData)],
        controller: controller,
      ),
    );
  }
}

class UserFollowers extends StatefulWidget {
  final Map userData;
  UserFollowers(this.userData);
  createState() => UserFollowersState(this.userData);
}

class UserFollowersState extends State<UserFollowers>
    with AutomaticKeepAliveClientMixin<UserFollowers> {
  final Map userData;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool needsRefresh = false;

  UserFollowersState(this.userData) {
    needsRefresh = false;
  }

  @override
  bool get wantKeepAlive => needsRefresh == null ? true : !needsRefresh;

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
                    else if (snapshot.data.containsKey('followersData') &&
                        snapshot.data.containsKey('followersData') &&
                        snapshot.data['followersData'].containsKey('success') &&
                        snapshot.data['followersData'].containsKey('data') &&
                        snapshot.data['followersData']['success'] &&
                        (snapshot.data['followersData']['data'] as List)
                                .length >
                            0) {
                      for (Map ele in snapshot.data['followersData']['data']) {
                        if (ele.containsKey('userId') &&
                            ele.containsKey('name') &&
                            ele.containsKey('follows')) {
                          // print(ele);
                          ret.add(Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(2.0, 1.0, 2.0, 1.0),
                              child: FollowingPageCard(ele)));
                        }
                      }
                    } else {
                      // print("xkdi");
                      ret.add(PlaceHolder("No Followers!"));
                    }
                    return ListView(
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
    });
  }

  _fetchData() async {
    Map ret = {}, temp;

    var dio = Dio();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    var cj = PersistCookieJar(dir: appDocDir.path, ignoreExpires: false);
    dio.interceptors.add(CookieManager(cj));

    try {
      Response response = await dio
          .get(DataProvider.getFollowers + '/' + userData['userId'].toString());
      temp = json.decode(response.toString());
      // print(temp);
      ret['followersData'] = temp;
      if (!ret['followersData'].containsKey('success') ||
          !ret['followersData'].containsKey('data') ||
          !ret['followersData']['success']) {
        FetchDataException();
      }
    } catch (e) {
      ret['followersData'] = {};
    }
    // print(ret);
    return ret;
  }
}

class UserFollowing extends StatefulWidget {
  final Map userData;
  UserFollowing(this.userData);
  createState() => UserFollowingState(this.userData);
}

class UserFollowingState extends State<UserFollowing>
    with AutomaticKeepAliveClientMixin<UserFollowing> {
  final Map userData;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool needsRefresh = false;

  UserFollowingState(this.userData) {
    needsRefresh = false;
  }

  @override
  bool get wantKeepAlive => needsRefresh == null ? true : !needsRefresh;

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
                    else if (snapshot.data.containsKey('followingData') &&
                        snapshot.data.containsKey('followingData') &&
                        snapshot.data['followingData'].containsKey('success') &&
                        snapshot.data['followingData'].containsKey('data') &&
                        snapshot.data['followingData']['success'] &&
                        (snapshot.data['followingData']['data'] as List)
                                .length >
                            0) {
                      for (Map ele in snapshot.data['followingData']['data']) {
                        if (ele.containsKey('userId') &&
                            ele.containsKey('name') &&
                            ele.containsKey('follows')) {
                          // print(ele);
                          ret.add(Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(2.0, 1.0, 2.0, 1.0),
                              child: FollowingPageCard(ele)));
                        }
                      }
                    } else {
                      // print("xkdi");
                      ret.add(PlaceHolder("No Followers!"));
                    }
                    return ListView(
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
    });
  }

  _fetchData() async {
    Map ret = {}, temp;

    var dio = Dio();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    var cj = PersistCookieJar(dir: appDocDir.path, ignoreExpires: false);
    dio.interceptors.add(CookieManager(cj));

    try {
      Response response = await dio
          .get(DataProvider.getFollowing + '/' + userData['userId'].toString());
      temp = json.decode(response.toString());
      // print(temp);
      ret['followingData'] = temp;
      if (!ret['followingData'].containsKey('success') ||
          !ret['followingData'].containsKey('data') ||
          !ret['followingData']['success']) {
        FetchDataException();
      }
    } catch (e) {
      ret['followingData'] = {};
    }
    // print(ret);
    return ret;
  }
}
