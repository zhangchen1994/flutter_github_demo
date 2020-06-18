import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttergithub/models/repo.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ContentRoute extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Entity args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(args.fullName),
      ),
      body: WebView(
        initialUrl: args.htmlUrl,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
