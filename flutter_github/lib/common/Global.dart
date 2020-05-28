import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttergithub/common/git.dart';
import 'package:fluttergithub/models/cache_config.dart';
import 'package:fluttergithub/models/cache_object.dart';
import 'package:fluttergithub/models/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static const _themes = <MaterialColor>[
    Colors.red,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.red,
  ];
  static SharedPreferences _sharedPreferences;
  static Profile profile = Profile.init();

  // 网络缓存对象
  static NetCache netCache = NetCache();

  // 可选的主题列表
  static List<MaterialColor> get themes => _themes;

  // 是否为release版
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  static Future init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    var _profile = _sharedPreferences.getString("profile");
    if (_profile != null) {
      try {
        profile = Profile.fromJson(json.decode(_profile));
      } catch (e) {
        print(e);
      }
    }
    //如果没有缓存策略，设置默认缓存策略
    profile.cache = profile.cache ?? CacheConfig(true, 3600, 100);
    //初始化网络请求相关配置
    Git.init();
  }
  //持久化存储信息
  static saveProfile() => _sharedPreferences.setString("profile", jsonEncode(profile.toJson()));
}
