import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttergithub/common/Global.dart';
import 'package:fluttergithub/models/repo.dart';
import 'package:fluttergithub/models/user.dart';

class Git {
  // 在网络请求过程中可能会需要使用当前的context信息，比如在请求失败时
  // 打开一个新路由，而打开新路由需要context信息。

  Git([this.context]) : _options = Options(extra: {"context": context});

  BuildContext context;
  Options _options;

  static Dio dio = new Dio(BaseOptions(
    baseUrl: 'https://api.github.com',
    responseType: ResponseType.plain,
    headers: {
      HttpHeaders.acceptHeader: "application/vnd.github.v3+json,"
          "application/vnd.github.symmetra-preview+json",
    },
  ));

  static init() {
    // 添加缓存插件
    dio.interceptors.add(Global.netCache);
    // 设置用户token（可能为null，代表未登录）
    dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;
  }

  // 登录接口，登录成功后返回用户信息
  Future<User> login(String login, String pwd) async {
    String basic = 'Basic ' + base64.encode(utf8.encode('$login:$pwd'));

    var r = await dio.get('/users/$login',
        options: _options.merge(headers: {
          HttpHeaders.authorizationHeader: basic
        }, extra: {
          'noCache': true, //登录禁用缓存
        }));

    //登录成功后更新公共头（authorization），此后的所有请求都会带上用户身份信息
    dio.options.headers[HttpHeaders.authorizationHeader] = basic;
    //清空所有缓存
    Global.netCache.cache.clear();
    //更新profile中的token信息
    Global.profile.token = basic;
    print(r.data);
    Map<String, dynamic> data = json.decode(r.data);
    return User.fromJson(data);
  }

  Future getRepos(
      {Map<String, dynamic> queryParameters, refresh = false}) async {
    if (refresh) {
      _options.extra.addAll({"refresh": true, "list": true});
    }

    var r = await dio.get("/user/repos",
        queryParameters: queryParameters,
        options: _options);
    return r;
  }
}
