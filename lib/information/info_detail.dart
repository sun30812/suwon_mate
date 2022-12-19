import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:suwon_mate/styles/style_widget.dart';
import 'package:url_launcher/url_launcher.dart';

/// 공지사항에 대한 상세내용을 출력하는 페이지이다.
///
/// **주의: 본 클래스는 더 이상 사용되지 않는 페이지 입니다.**
///
/// 더 이상 해당 코드에 대해서는 유지보수가 진행되지 않을 것이며, 추후 업데이트 시 해당 클래스 및 코드는 제거됩니다.
class InfoDetailPage extends StatelessWidget {
  const InfoDetailPage({Key? key}) : super(key: key);

  Future getData(String siteCode) async {
    return await http.get(Uri.parse(
        'https://www.suwon.ac.kr/index.html?menuno=674&bbsno=$siteCode&boardno=$siteCode&siteno=37&act=view'));
  }

  @override
  Widget build(BuildContext context) {
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      floatingActionButton: SuwonButton(
          icon: Icons.screen_share_outlined,
          buttonName: '브라우저로 보기',
          onPressed: () async {
            await launch(
                'https://www.suwon.ac.kr/index.html?menuno=674&bbsno=${args['site_code']}&boardno=${args['site_code']}&siteno=37&act=view',
                forceSafariVC: false,
                forceWebView: false);
          }),
      appBar: AppBar(title: Text(args['title'])),
      body: FutureBuilder(
        future: getData(args['site_code']),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return const DataLoadingError();
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
