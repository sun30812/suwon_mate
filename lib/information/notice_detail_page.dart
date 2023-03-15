import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:suwon_mate/model/notice.dart';
import 'package:suwon_mate/styles/style_widget.dart';
import 'package:url_launcher/url_launcher.dart';

/// 공지사항에 대한 상세내용을 출력하는 페이지이다.
///
/// 공지사항 페이지에서 특정 위젯을 클릭 시 상세 공지사항을 출력하는 페이지이다.
/// [notice]를 통해 게시글의 제목과 해당 게시글의 사이트 코드를 받아서 상세정보를 가져와서 보여주는 페이지이다.
class NoticeDetailPage extends StatelessWidget {
  /// 특정 공지사항 게시글의 일부 정보를 가진 변수이다.
  ///
  /// ## 같이보기
  /// * [Notice]
  ///
  final Notice notice;

  /// 공지사항에 대한 상세내용을 출력하는 페이지
  const NoticeDetailPage({required this.notice, Key? key}) : super(key: key);

  /// 공지사항 게시글의 코드를 받아서 특정 공지사항의 html문서를 가져오는 메서드
  ///
  /// [siteCode]에 게시글 코드를 제공해서 공지사항 게시글을 받아올 수 있도록 한다.
  Future getData(String siteCode) async {
    return await http.get(Uri.parse(
        'https://www.suwon.ac.kr/index.html?menuno=674&bbsno=$siteCode&boardno=$siteCode&siteno=37&act=view'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.screen_share_outlined),
          label: const Text('브라우저로 보기'),
          onPressed: () async {
            await launchUrl(
                Uri(
                    scheme: 'https',
                    host:
                        'www.suwon.ac.kr/index.html?menuno=674&bbsno=${notice.siteCode}&boardno=${notice.siteCode}&siteno=37&act=view'),
                mode: LaunchMode.externalApplication);
          }),
      appBar: AppBar(title: Text(notice.title)),
      body: FutureBuilder(
        future: getData(notice.siteCode),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return DataLoadingError(
              errorMessage: snapshot.error,
            );
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
