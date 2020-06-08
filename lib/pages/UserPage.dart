import 'dart:io';
import 'dart:convert';
import 'dart:ui';

import 'package:dribbble/helpers/DataProvider.dart';
import 'package:dribbble/helpers/FetchDataException.dart';
import 'package:async/async.dart';
import 'package:dribbble/pages/EditProfilePage.dart';
import 'package:dribbble/pages/FollowPage.dart';
import 'package:dribbble/pages/LoginPage.dart';
import 'package:dribbble/widgets/PlaceHolder.dart';
import 'package:dribbble/widgets/PostCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class UserPage extends StatefulWidget {
  final String userId;
  UserPage(this.userId);
  @override
  createState() => UserPageState(userId);
}

class UserPageState extends State<UserPage>
    with AutomaticKeepAliveClientMixin<UserPage> {
  final String userId;
  int follows;
  int followers;
  int following;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  AsyncMemoizer _memoizer = AsyncMemoizer();
  bool needsRefresh = false;

  final scrollController = ScrollController();

  UserPageState(this.userId) {
    needsRefresh = false;
    follows = 0;
  }

  @override
  bool get wantKeepAlive => needsRefresh == null ? true : !needsRefresh;

  @override
  Widget build(BuildContext context) {
    needsRefresh = false;
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xffececea),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey,
            ),
            onPressed: () => Navigator.of(context).pop()),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 8.0, 6.0, 8.0),
          child: Row(
            children: <Widget>[
              Text(
                userId,
                style: TextStyle(color: Colors.black, fontSize: 17.0),
              ),
              Expanded(child: Container()),
              (follows == -1)
                  ? (IconButton(
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Colors.red,
                      ),
                      onPressed: () => logoutConfirmation()))
                  : (Container())
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _onRefresh,
        child: FutureBuilder(
            future: _fetchData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.done:
                  {
                    List<Widget> ret = [];
                    if (snapshot.hasError)
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("Some error occured1"),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Ok"))
                        ],
                      );
                    else if (!snapshot.hasData)
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    else if (snapshot.data.toString().length > 0 &&
                        snapshot.data.containsKey('userData') &&
                        snapshot.data['userData'] != null) {
                      ret.add(Container(
                        color: Colors.white,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Hero(
                                  tag: 'prof',
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20.0, 10.0, 20.0, 20.0),
                                    child: CircleAvatar(
                                      radius: 50.0,
                                      child: Image.asset(
                                          'lib/assets/profile_placeholder.png'),
                                    ),
                                  ),
                                ),
                                Column(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0.0, 30.0, 0.0, 15.0),
                                            child: FlatButton(
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0.0, 10.0, 0.0, 10.0),
                                              onPressed: () => scrollController
                                                  .animateTo(250.0,
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.ease),
                                              child: RichText(
                                                  text: TextSpan(
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: snapshot.data[
                                                                        'userData']
                                                                        [
                                                                        'totalposts']
                                                                    .toString() +
                                                                '\n',
                                                            style: TextStyle(
                                                                fontSize: 20.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text: 'Artworks')
                                                      ]),
                                                  textAlign: TextAlign.center),
                                            )),
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0.0, 30.0, 0.0, 15.0),
                                            child: FlatButton(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0.0, 10.0, 0.0, 10.0),
                                              onPressed: () => Navigator.of(
                                                      context)
                                                  .push(MaterialPageRoute(
                                                      builder: (context) =>
                                                          FollowPage(
                                                              snapshot.data[
                                                                  'userData'],
                                                              0)))
                                                  .then((value) =>
                                                      {_refreshData()}),
                                              child: RichText(
                                                  text: TextSpan(
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: followers
                                                                    .toString() +
                                                                '\n',
                                                            // text: '145\n',
                                                            style: TextStyle(
                                                                fontSize: 20.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text: 'Followers')
                                                      ]),
                                                  textAlign: TextAlign.center),
                                            )),
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0.0, 30.0, 0.0, 15.0),
                                            child: FlatButton(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0.0, 10.0, 0.0, 10.0),
                                              onPressed: () => Navigator.of(
                                                      context)
                                                  .push(MaterialPageRoute(
                                                      builder: (context) =>
                                                          FollowPage(
                                                              snapshot.data[
                                                                  'userData'],
                                                              1)))
                                                  .then((value) =>
                                                      {_refreshData()}),
                                              child: RichText(
                                                  text: TextSpan(
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: following
                                                                    .toString() +
                                                                '\n',
                                                            style: TextStyle(
                                                                fontSize: 20.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text: 'Following')
                                                      ]),
                                                  textAlign: TextAlign.center),
                                            ))
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 0.0, 20.0, 5.0),
                              child: Text(
                                snapshot.data['userData']['name'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.0,
                                ),
                              ),
                            ),
                            (snapshot.data['userData']['personalbio'] != null)
                                ? (Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20.0, 0.0, 20.0, 10.0),
                                    child: Wrap(
                                      children: <Widget>[
                                        Text(
                                          (snapshot.data['userData']
                                                      ['personalbio'] ==
                                                  null)
                                              ? ("")
                                              : (snapshot.data['userData']
                                                      ['personalbio']
                                                  .toString()),
                                          style: TextStyle(
                                            // fontWeight: FontWeight.bold,
                                            fontSize: 13.0,
                                          ),
                                        ),
                                      ],
                                    )))
                                : (Container()),
                            (follows == 0)
                                ? (Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20.0, 0.0, 20.0, 50.0),
                                    child: ButtonTheme(
                                      height: 30.0,
                                      // minWidth: 220,
                                      child: FlatButton(
                                          color: Color(0xffea4c89),
                                          onPressed: () => {
                                                setFollowing(),
                                                snapshot.data['userData']
                                                    ['followers'] = followers,
                                                snapshot.data['userData']
                                                    ['following'] = following
                                              },
                                          child: Text(
                                            'Follow',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                    ),
                                  ))
                                : (follows == 1)
                                    ? (Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20.0, 0.0, 20.0, 50.0),
                                        child: ButtonTheme(
                                          height: 30.0,
                                          // minWidth: 220,
                                          child: OutlineButton(
                                              // shape: Border.all(width: 1.5, color: Colors.red),
                                              highlightedBorderColor:
                                                  Colors.black,
                                              color: Colors.white,
                                              onPressed: () => {
                                                    setFollowing(),
                                                    snapshot.data['userData']
                                                            ['followers'] =
                                                        followers,
                                                    snapshot.data['userData']
                                                            ['following'] =
                                                        following
                                                  },
                                              child: Text(
                                                'Following',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )),
                                        ),
                                      ))
                                    : (Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20.0, 0.0, 20.0, 30.0),
                                        child: ButtonTheme(
                                          height: 30.0,

                                          // minWidth: 220,
                                          child: OutlineButton(
                                              // shape: Border.all(width: 1.5, color: Colors.red),
                                              highlightedBorderColor:
                                                  Colors.black,
                                              color: Colors.white,
                                              onPressed: () => Navigator.of(
                                                      context)
                                                  .push(MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProfilePage(
                                                              snapshot.data[
                                                                  'userData'],
                                                              _refreshData))),
                                              child: Text(
                                                'Edit Profile',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )),
                                        ),
                                      )),
                          ],
                        ),
                      ));
                      if (snapshot.data.containsKey('postData') &&
                          snapshot.data['postData'] != null &&
                          snapshot.data['postData']['data'].length != 0) {
                        for (Map ele in snapshot.data['postData']['data']) {
                          if (ele.containsKey('title') &&
                              ele.containsKey('author') &&
                              ele.containsKey('postLink') &&
                              ele.containsKey('likes')) {
                            // print(ele);
                            ret.add(Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: PostCard(ele),
                            ));
                          }
                        }
                      } else
                        ret.add(PlaceHolder("No Artworks Found!"));
                      return ListView(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: scrollController,
                        children: ret,
                      );
                    }
                    return AlertDialog(
                      title: Text("Error"),
                      content: Text("Some error occured"),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Ok"))
                      ],
                    );
                  }
                default:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              }
            }),
      ),
    );
  }

  _refreshData() {
    setState(() {
      // needsRefresh = true;
      _memoizer = AsyncMemoizer();
    });
  }

  _fetchData() async {
    return this._memoizer.runOnce(() async {
      Map ret = {};
      try {
        var dio = Dio();
        Directory appDocDir = await getApplicationDocumentsDirectory();
        var cj = PersistCookieJar(dir: appDocDir.path, ignoreExpires: false);
        dio.interceptors.add(CookieManager(cj));
        Response response =
            await dio.get(DataProvider.getUserDetails + '/' + userId);
        Map resp = json.decode(response.toString());
        // print(resp);
        if (resp.containsKey('success') &&
            resp['success'] &&
            resp.containsKey('data') &&
            resp['data'].containsKey('name') &&
            resp['data'].containsKey('followers') &&
            resp['data'].containsKey('following') &&
            resp['data'].containsKey('follows')) {
          // print("bk");
          ret['userData'] = resp['data'];
          follows = ret['userData']['follows'];
          followers = ret['userData']['followers'];
          following = ret['userData']['following'];
          setState(() {});
          response = await dio.get(DataProvider.getUserPosts + '/' + userId);
          resp = json.decode(response.toString());
          // print(resp);
          if (resp.containsKey('success') &&
              resp['success'] &&
              resp.containsKey('data')) {
            ret['postData'] = resp;
            // print(ret['postData']);
          } else
            FetchDataException();
        } else
          FetchDataException();
      } catch (e) {
        ret['userData'] = null;
        ret['postData'] = null;
      }
      // print(ret);
      return ret;
    });
  }

  Future<Null> _onRefresh() async {
    setState(() {
      needsRefresh = true;
      _memoizer = AsyncMemoizer();
    });
  }

  void logoutButtonBind() async {
    try {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("[ERROR] " + e.toString());
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Error logging out"),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<Null> setFollowing() async {
    setState(() {
      if (follows == 1) {
        follows = 0;
        followers--;
      } else {
        follows = 1;
        followers++;
      }
    });
    try {
      var dio = Dio();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      var cj = PersistCookieJar(dir: appDocDir.path, ignoreExpires: false);
      dio.interceptors.add(CookieManager(cj));

      Response response = await dio.post(DataProvider.setFollowing,
          data: {'userId': userId, 'status': follows});
      print(response);
    } catch (e) {
      showSnackBar("Some Error Occured!");
    }
  }

  void showSnackBar(String error) {
    setState(() {
      if (follows == 1) {
        follows = 0;
        followers--;
      } else {
        follows = 1;
        followers++;
      }
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(error),
        duration: Duration(seconds: 2),
      ));
    });
  }

  void logoutConfirmation() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: AlertDialog(
            title: Text("Logout?"),
            content: Text("Are you sure you want to logout?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel")),
              FlatButton(
                  onPressed: () => logoutButtonBind(), child: Text("Logout"))
            ],
          ),
        );
      },
    );
  }
}
