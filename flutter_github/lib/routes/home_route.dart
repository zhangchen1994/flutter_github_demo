import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttergithub/common/git.dart';
import 'package:fluttergithub/models/repo.dart';
import 'package:fluttergithub/models/theme_model.dart';
import 'package:fluttergithub/models/user_model.dart';
import 'package:provider/provider.dart';

class HomeRoute extends StatefulWidget {
  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  UserModel _userModel;
  List<Entity> _mData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userModel = Provider.of<UserModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_userModel.profile.user.login),
      ),
      drawer: myDrawer(), //抽屉菜单
      body: _mData == null
          ? FutureBuilder(
              future: Git(context).getRepos(refresh: false, queryParameters: {
                'page': 0,
                'page_size': 20,
              }),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Entity>> snapshot) {
                Widget widget;
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    widget = Text(snapshot.error.toString());
                  } else {
                    widget = mainWidget(data: snapshot.data);
                  }
                } else {
                  widget = Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return widget;
              },
            )
          : mainWidget(data: _mData),
    );
  }

  Widget mainWidget({@required List<Entity> data}) {
    return RefreshIndicator(
        child: ListView.separated(
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: FlutterLogo(),
                    dense: true,
                    title: Row(
                      children: <Widget>[
                        Text(data[index].name),
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: data[index].private
                              ? Icon(
                            Icons.lock,
                            size: 15,
                            color: Provider.of<ThemeModel>(context).theme,
                          )
                              : null,
                        )
                      ],
                    ),
                    subtitle: Text(data[index].fullName),
                    isThreeLine: false,
                    trailing: Text(data[index].language),
                    onTap: () {
                      Navigator.of(context).pushNamed("content", arguments: data[index]);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      children: <Widget>[
                        Text("更新日期:${data[index].updatedAt}", style: TextStyle(color: Colors.grey, fontSize: 12),)
                      ],
                    ),
                  )
                ],
              );
            },
            separatorBuilder: (context, index) => Divider(
                  height: 1,
                ),
            itemCount: data.length),
        onRefresh: () async {
          List<Entity> data =
              await Git(context).getRepos(refresh: true, queryParameters: {
            'page': 0,
            'page_size': 20,
          });

          setState(() {
            _mData = data;
            SnackBar snackBar = SnackBar(content: Text("刷新完成"), action: SnackBarAction(label: "知道了", onPressed: null),);
            Scaffold.of(context).showSnackBar(snackBar);
          });
        });
  }

  Drawer myDrawer() {
    print(_userModel.user.avatarUrl);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: ClipOval(
              child: FadeInImage.assetNetwork(
                placeholder: "no_login.png",
                image: _userModel.user.avatarUrl,
              ),
            ),
            //currentAccountPicture: Image.network(_userModel.user.avatarUrl),
            accountEmail: null,
            accountName: Text(_userModel.user.login),
          ),
          ListTile(
            title: Text("更改主题"),
            onTap: () {
              Navigator.pushNamed(context, "theme");
            },
          ),
          Divider(
            height: 1,
          ),
          ListTile(
            title: Text("注销"),
            onTap: () {
              showDialog(
                  context: context,
                  child: AlertDialog(
                    title: Text("注销"),
                    content: Container(
                      height: 50,
                      child: Text("要注销此账号吗？"),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("取消"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text("确定"),
                        onPressed: () {
                          Navigator.pop(context);
                          Provider.of<UserModel>(context, listen: false).user =
                              null;
                          Navigator.pushReplacementNamed(context, "my_home");
                        },
                      ),
                    ],
                  ));
            },
          ),
          Divider(
            height: 1,
          ),
        ],
      ),
    );
  }
}
