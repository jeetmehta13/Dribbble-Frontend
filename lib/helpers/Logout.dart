import 'dart:io';
import 'dart:async';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:dribbble/cache/UserCache.dart';

import 'DataProvider.dart';

class Logout{
  final userCache = UserCache();
  final manager = DefaultCacheManager();

  Future<void> logout() async {
    try {
      var dio = Dio();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      var cj = PersistCookieJar(dir: appDocDir.path, ignoreExpires: false);
      dio.interceptors.add(CookieManager(cj));

      await userCache.delete();
      await manager.emptyCache();
      await dio.post(DataProvider.logout);
      cj.delete(Uri.parse(DataProvider.baseUrl));
    } catch(e) {
      print(e);
    }
  }
}