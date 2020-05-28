import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttergithub/common/Global.dart';
import 'package:fluttergithub/models/profile_change_notifier.dart';

class ThemeModel extends ProfileChangeNotifier {
  /// firstWhere 返回数组中满足给定条件的第一个元素
  ColorSwatch get theme =>
      Global.themes.firstWhere((element) => element.value == profile.theme,
          orElse: () => Colors.blue);

  set theme(ColorSwatch color) {
    if (color != theme) {
      profile.theme = color[500].value;
      notifyListeners();
    }
  }
}
