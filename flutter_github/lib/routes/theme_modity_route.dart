import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttergithub/common/Global.dart';
import 'package:fluttergithub/models/theme_model.dart';
import 'package:provider/provider.dart';

class ModifyThemeRoute extends StatefulWidget {
  @override
  _ModifyThemeRouteState createState() => _ModifyThemeRouteState();
}

class _ModifyThemeRouteState extends State<ModifyThemeRoute> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ThemeModel>(context);
    var theme = provider.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text("更改主题"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: Global.themes.map((e) => _widget(e, theme == e)).toList(),
        ),
      ),
    );
  }

  Widget _widget(ColorSwatch swatch, bool isSelect) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: isSelect
          ? Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: swatch,
                  border: Border.all(color: Colors.black, width: 2.0)),
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.done,
                color: Colors.white,
              ),
            )
          : GestureDetector(
              child: Container(
                height: 60,
                width: double.infinity,
                color: swatch,
              ),
              onTap: () {
                Provider.of<ThemeModel>(context).theme = swatch;
              },
            ),
    );
  }
}
