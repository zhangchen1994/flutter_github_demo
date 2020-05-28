
import 'package:flutter/widgets.dart';
import 'package:fluttergithub/common/Global.dart';
import 'package:fluttergithub/models/profile.dart';

///全局的共享状态基类
class ProfileChangeNotifier extends ChangeNotifier{
  Profile get profile => Global.profile;

  @override
  void notifyListeners() {
    Global.saveProfile(); // 保存Profile变更
    super.notifyListeners(); // 通知依赖的Widget更新
  }


}