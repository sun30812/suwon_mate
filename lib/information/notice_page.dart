import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:suwon_mate/model/notice.dart';
import 'package:url_launcher/url_launcher.dart';

import '../styles/style_widget.dart';

/// 수원대학교의 공지사항을 보여주는 페이지입니다.
///
/// 수원대학교의 공지사항을 받아서 위젯([SimpleCard])으로 출력해줍니다.
/// 만일 공지사항을 볼 수 없는 플랫폼인 경우 [NotSupportInPlatform]페이지를 출력한다.
class NoticePage extends StatefulWidget {
  const NoticePage({Key? key}) : super(key: key);

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  /// 수원대학교의 공지사항을 html문서로 가져오는 메서드이다.
  Future getData() async {
    return await http
        .get(Uri.parse('https://www.suwon.ac.kr/index.html?menuno=674'));
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
                    host: 'www.suwon.ac.kr/index.html?menuno=674'),
                mode: LaunchMode.externalApplication);
          }),
      body: mainScreen(),
    );
  }

  /// 학교 공지사항 목록을 출력하는 위젯이다.
  ///
  /// 만일 Web환경에서 해당 앱을 실행시키는 경우 작동되지 않기 때문에 플랫폼 관련 경고 메세지를 출력한다.
  Widget mainScreen() {
    if (kIsWeb) {
      return const NotSupportInPlatform('Web');
    }
    dom.Element rows;
    return RefreshIndicator(
      onRefresh: () async {
        http.Response response = await http
            .get(Uri.parse('https://www.suwon.ac.kr/index.html?menuno=674'));
        setState(() {
          rows = parse(response.body)
              .getElementsByClassName('board_basic_list')[0];
        });
      },
      child: Center(
        child: FutureBuilder(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator.adaptive(),
                  Text('공지사항 불러오는 중..')
                ],
              );
            } else if (snapshot.hasError) {
              return DataLoadingError(
                errorMessage: snapshot.error,
              );
            } else {
              rows = parse((snapshot.data as http.Response).body)
                  .getElementsByClassName('board_basic_list')[0];
              return ListView.builder(
                  itemCount: rows.getElementsByClassName('subject').length,
                  itemBuilder: (BuildContext context, int index) {
                    Notice siteData = Notice(
                        title: rows
                            .getElementsByClassName('subject')[index]
                            .text
                            .trim(),
                        siteCode: rows
                            .getElementsByClassName('subject')[index]
                            .innerHtml
                            .split(',')[2]
                            .split(')')[0]);
                    return SimpleCard(
                        onPressed: () =>
                            context.push('/notice/detail', extra: siteData),
                        title: siteData.title,
                        content: Text(
                          '${rows.getElementsByClassName('info')[index].getElementsByClassName('date')[0].text.trim()}/${rows.getElementsByClassName('info')[index].getElementsByClassName('hit')[0].text.trim()}',
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 16.0),
                        ));
                  });
            }
          },
        ),
      ),
    );
  }
}
