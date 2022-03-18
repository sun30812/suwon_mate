import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class InfoDetailPage extends StatelessWidget {
  Future getData(String siteCode) async {
    return await http.get(Uri.parse(
        'https://www.suwon.ac.kr/index.html?menuno=674&bbsno=$siteCode&boardno=$siteCode&siteno=37&act=view'));
  }

  @override
  Widget build(BuildContext context) {
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: AppBar(title: Text(args['title'])),
      body: FutureBuilder(
        future: getData(args['site_code']),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Text('ERR');
          } else {
            var body = parse((snapshot.data as http.Response).body);
            return SingleChildScrollView(
              child: Html(
                  customRender: {
                    "table": (context, child) => SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: (context.tree as TableLayoutElement)
                              .toWidget(context),
                        )
                  },
                  data: body
                      .getElementsByClassName('board_viewcont')[0]
                      .innerHtml),
            );
          }
        },
      ),
    );
  }
}
