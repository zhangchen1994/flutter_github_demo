import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttergithub/common/Global.dart';
import 'package:fluttergithub/common/git.dart';
import 'package:fluttergithub/models/locale_model.dart';
import 'package:fluttergithub/models/theme_model.dart';
import 'package:fluttergithub/models/user.dart';
import 'package:fluttergithub/models/user_model.dart';
import 'package:fluttergithub/routes/content_route.dart';
import 'package:fluttergithub/routes/home_route.dart';
import 'package:fluttergithub/routes/theme_modity_route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Global.init().then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        ChangeNotifierProvider.value(value: ThemeModel()),
        ChangeNotifierProvider.value(value: LocaleModel()),
        ChangeNotifierProvider.value(value: UserModel())
      ],
      child: Consumer2<ThemeModel, LocaleModel>(
          builder: (context, themeModel, localeModel, Widget child) {
        bool isLogin = Provider.of<UserModel>(context).isLogin;
        return MaterialApp(
          theme: ThemeData(primarySwatch: themeModel.theme),
          home: isLogin
              ? HomeRoute()
              : MyHomePage(
                  title: "GitHub客户端",
                ),
//          locale: localeModel.getLocale(),
//          supportedLocales: [
//            const Locale('en', 'US'), // 美国英语
//            const Locale('zh', 'CN'), // 中文简体
//          ],

          routes: <String, WidgetBuilder>{
            "home": (context) => HomeRoute(),
            "my_home": (context) => MyHomePage(),
            "theme": (context) => ModifyThemeRoute(),
            "content": (context) => ContentRoute(),
          },
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool isShowPassword = false;
  bool _nameAutoFocus = true;
  bool _isLoginResult = true;
  FocusNode focusNode1 = new FocusNode();
  FocusNode focusNode2 = new FocusNode();
  GlobalKey _formKey = GlobalKey<FormState>();
  bool pwdShow = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 自动填充上次登录的用户名，填充后将焦点定位到密码输入框
    _userNameController.text = Global.profile.lastLogin;
    print(_userNameController.text);
    if (_userNameController.text != null &&
        _userNameController.text.isNotEmpty) {
      _nameAutoFocus = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "请登录"),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: TextFormField(
                      autofocus: _nameAutoFocus,
                      focusNode: focusNode1,
                      controller: _userNameController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "用户名",
                          hintText: "请输入用户名或邮箱",
                          prefixIcon: Icon(Icons.person)),
                      validator: (v) {
                        return v.trim().isNotEmpty ? null : "用户名不能为空";
                      },
                    ),
                  ),
                  TextFormField(
                    controller: _passwordController,
                    autofocus: !_nameAutoFocus,
                    focusNode: focusNode2,
                    decoration: InputDecoration(
                      labelText: "密码",
                      hintText: "请输入密码",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                            pwdShow ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            pwdShow = !pwdShow;
                          });
                        },
                      ),
                    ),
                    obscureText: !pwdShow,
                    validator: (v) {
                      return v.trim().isNotEmpty ? null : "密码不能为空";
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints.expand(height: 50),
                      child: RaisedButton(
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            "登       录",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _login();
                          }),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _login() async {
    if ((_formKey.currentState as FormState).validate()) {
      focusNode1.unfocus();
      focusNode2.unfocus();
      showDialog(
          barrierDismissible: false,
          context: context,
          child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Container(
              width: 50,
              height: 150,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text("登陆中"),
                  ],
                ),
              ),
            ),
          ));
      User user;
      bool isSuccessLogin = false;
      try {
        user = await Git(context)
            .login(_userNameController.text, _passwordController.text);
        Provider.of<UserModel>(context, listen: false).user = user;
        isSuccessLogin = true;
      } catch (e) {
        //登录失败则提示
        if (e.response?.statusCode == 401) {
          Fluttertoast.showToast(msg: "密码或用户名错误");
        } else {
          print(e);
          Fluttertoast.showToast(msg: "登录失败，服务器无响应，请稍后再试");
        }
      } finally {
        Navigator.of(context).pop();
        if (isSuccessLogin) {
          Navigator.pushReplacementNamed(context, "home");
        }
      }
    } else {
      Fluttertoast.showToast(msg: "密码或用户名不能为空");
    }
  }
}
