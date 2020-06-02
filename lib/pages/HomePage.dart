import 'dart:convert';

import 'package:dribbble/cache/UserCache.dart';
import 'package:dribbble/helpers/FetchDataException.dart';
import 'package:dribbble/pages/AddPostPage.dart';
import 'package:dribbble/pages/FollowingPage.dart';
import 'package:dribbble/pages/RecentPage.dart';
import 'package:dribbble/pages/UserPage.dart';
import 'package:dribbble/widgets/TransitionAnimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  @override
  createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController controller;
  String username;

  void initState() {
    super.initState();
    controller = new TabController(length: 2, vsync: this);
    getUserId();
  }

  final cachedUserData = UserCache();

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   backgroundColor: Color(0xffececea),
    //   // appBar: AppBar(
    //   //   leading: Hero(
    //   //     tag: 'prof',
    //   //     child: GestureDetector(
    //   //       onTap: () {
    //   //         Navigator.push(
    //   //           context,
    //   //           MaterialPageRoute(
    //   //             builder: (context) => UserPage(username),
    //   //           ),
    //   //         );
    //   //       },
    //   //       child: Padding(
    //   //         padding: const EdgeInsets.fromLTRB(12.0, 10.0, 4.0, 12.0),
    //   //         child: ClipOval(

    //   //           child: Image(
    //   //             image: AssetImage('lib/assets/profile_placeholder.png'),
    //   //             height: 5.0,
    //   //           ),
    //   //         ),
    //   //       ),
    //   //     ),
    //   //   ),

    //   //   centerTitle: true,
    //   //   backgroundColor: Color(0xff262626),
    //   //   bottom: TabBar(
    //   //     // indicatorPadding: EdgeInsets.only(left: 15.0, right: 100.0),
    //   //     tabs: [Tab(text: 'Following'), Tab(text: 'Recent')],
    //   //     controller: controller,
    //   //   ),
    //   //   title: Padding(
    //   //     padding: const EdgeInsets.fromLTRB(0.0, 8.0, 6.0, 8.0),
    //   //     child: Row(
    //   //       children: <Widget>[
    //   //         SvgPicture.asset(
    //   //           'lib/assets/dribbble-4.svg',
    //   //           height: 20,
    //   //           semanticsLabel: 'Dribbble logo',
    //   //           color: Colors.white,
    //   //         ),
    //   //         Expanded(child: Container()),
    //   //         IconButton(icon: Icon(Icons.add, color: Colors.white,), onPressed: null)
    //   //       ],
    //   //     ),
    //   //   ),
    //   // ),
    //   body:  CustomScrollView(
    //     slivers: <Widget>[
    //       SliverAppBar(
    //         // title: Text("Silver AppBar With ToolBar"),
    //         floating: true,
    //         backgroundColor: Color(0xff262626),
    //         // pinned: true,
    //         // expandedHeight: 120.0,
    //         // flexibleSpace: FlexibleSpaceBar(
    //         //     centerTitle: true,
    //         //     title: Text("Collapsing Toolbar",
    //         //         style: TextStyle(
    //         //           color: Colors.white,
    //         //           fontSize: 16.0,
    //         //         )),
    //         //     // background: Image.network(
    //         //     //   "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350",
    //         //     //   fit: BoxFit.cover,
    //         //     // )
    //         //     ),
    //         bottom: new TabBar(
    //           tabs: [
    //             Tab(text: 'Following'), Tab(text: 'Recent')
    //           ],
    //           controller: controller,
    //         ),
    //       ),
    //       SliverFillRemaining(
    //         child: TabBarView(
    //           controller: controller,
    //           children: <Widget>[
    //             FollowingPage(),
    //             RecentPage()
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),

    // );
    return Scaffold(
      body: new NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            new SliverAppBar(
              leading: Hero(
                  tag: 'prof',
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => UserPage(username),
                      //   ),
                      // );
                      Navigator.push(
                          context, SlideRightRoute(page: UserPage(username)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 4.0, 12.0),
                      child: ClipOval(
                        child: Image(
                          image:
                              AssetImage('lib/assets/profile_placeholder.png'),
                          height: 5.0,
                        ),
                      ),
                    ),
                  )),
              centerTitle: true,
              backgroundColor: Color(0xff262626),
              title: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 6.0, 8.0),
                child: Row(
                  children: <Widget>[
                    SvgPicture.asset(
                      'lib/assets/dribbble-4.svg',
                      height: 20,
                      semanticsLabel: 'Dribbble logo',
                      color: Colors.white,
                    ),
                    Expanded(child: Container()),
                    IconButton(
                        icon: Hero(
                          tag: 'add',
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => AddPost())))
                  ],
                ),
              ),
              floating: true,
              pinned: true,
              snap: true,
              bottom: new TabBar(
                controller: controller,
                tabs: [Tab(text: 'Following'), Tab(text: 'Recent')],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: controller,
          children: <Widget>[FollowingPage(), RecentPage()],
        ),
      ),
    );
  }

  Future<Null> getUserId() async {
    try {
      if (await cachedUserData.exists()) {
        Map userData = json.decode(await cachedUserData.read());
        if (userData.containsKey('success') &&
            userData.containsKey('data') &&
            userData['success']) {
          username = userData['data']['userId'];
        } else
          throw FetchDataException();
      } else
        throw FetchDataException();
    } catch (e) {
      print(e);
    }
  }
}
