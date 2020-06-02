import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class UserCache {
  Future _initialization;
  SharedPreferences storage;

  UserCache() {
    _initialization = initializeObject();
  }

  Future initializeObject() async {
    storage = await SharedPreferences.getInstance();
  }

  Future get ensureInitialization => _initialization;

  Future<void> write(var response) async {
    try {
      await this.ensureInitialization;
      await storage.setString("UserCache", json.encode(response));
    } catch (e) {
      print("[ERROR] " + e.toString());
    }
  }

  Future<String> read() async {
    try {
      await this.ensureInitialization;
      String contents = storage.getString("UserCache");
      if (contents == null || contents == "")
        return "{}";
      else
        return contents;
    } catch (e) {
      print("[ERROR] " + e.toString());
      return "{}";
    }
  }

  Future<bool> exists() async {
    try {
      await this.ensureInitialization;
      String contents = storage.getString("UserCache");
      if (contents == null || contents == "")
        return false;
      else
        return true;
    } catch (e) {
      print("[ERROR] " + e.toString());
      return false;
    }
  }

  Future<void> delete() async {
    try {
      await this.ensureInitialization;
      await storage.remove("UserCache");
    } catch (e) {
      print("[ERROR] " + e.toString());
    }
  }
}
