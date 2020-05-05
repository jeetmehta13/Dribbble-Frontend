import 'dart:io';
import 'dart:convert';

import 'package:dribbble/helpers/DataProvider.dart';
import 'package:dribbble/pages/FollowingPage.dart';
import 'package:dribbble/pages/RecentPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  @override
  createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController controller;

  void initState() {
    super.initState();
    controller = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafb),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xff9FA0B5),
        bottom: TabBar(
          tabs: [Tab(text: 'Following'), Tab(text: 'Recent')],
          controller: controller,
        ),
        title: SvgPicture.asset(
          'lib/assets/dribbble-4.svg',
          height: 20,
          semanticsLabel: 'Dribbble logo',
          color: Colors.white,
        ),
      ),
      body: TabBarView(
          children: [
            FollowingPage(),
            RecentPage()
          ],
          controller: controller,
        ),
    );
  }
}
