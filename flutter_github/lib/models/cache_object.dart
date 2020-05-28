
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:fluttergithub/common/Global.dart';

class CacheObject{
  CacheObject(this.response):timeStamp = DateTime.now().millisecondsSinceEpoch;
//  CacheObject(this.response) {
//    timeStamp = DateTime.now().millisecondsSinceEpoch;
//  }
  Response response;
  int timeStamp;

  bool operator == (other) {
    return response.hashCode == other.hashCode;
  }

  //将请求uri作为缓存的key
  int get hashCode => response.realUri.hashCode;
}

class NetCache extends Interceptor {
  var cache = LinkedHashMap<String, CacheObject>();
  @override
  Future onRequest(RequestOptions options) async {
    if (!Global.profile.cache.enable) return options;
    //refresh 标记是否下拉刷新，option.extra是专门用于扩展请求参数的
    bool refresh = options.extra["refresh"] = true;
    if (refresh) {
      if (options.extra['list'] == true) {
        cache.removeWhere((key, value) => key.contains(options.path));
      } else {
        delete(options.uri.toString());
      }
      return options;
    }

    if (options.extra['noCache'] != true && options.method.toLowerCase() == 'get' ) {
      String key = options.extra['cacheKey']?? options.uri.toString();
      var ob = cache[key];

      if (ob != null) {
        //若缓存未过期，则返回缓存内容
        if ((DateTime.now().millisecondsSinceEpoch - ob.timeStamp) / 1000 < Global.profile.cache.maxAge) {
          return cache[key].response;
        } else {
          delete(key);
        }
      }
    }
  }

  @override
  Future onError(DioError err) async {
    ///错误状态不缓存
  }

  @override
  Future onResponse(Response response) async {
    // 如果启用缓存，将返回结果保存到缓存
    if (Global.profile.cache.enable) {
      _saveCache(response);
    }
  }

  _saveCache(Response object) {
    RequestOptions options = object.request;
    if (options.extra['noCache'] != true &&  options.method.toLowerCase() == 'get') {
      if (cache.length == Global.profile.cache.maxCount) {
        cache.remove(cache[cache.keys.first]);
      }
      String key = options.extra['cacheKey']?? options.uri.toString();
      cache[key] = CacheObject(object);
    }
  }

  void delete(String key) {
    cache.remove(key);
  }
}