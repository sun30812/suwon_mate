import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../styles/style_widget.dart';

/// 수원대학교의 공지사항을 보여주는 페이지입니다.
///
/// 수원대학교의 공지사항을 받아서 위젯([SimpleCardButton])으로 출력해줍니다.
/// 만일 공지사항을 볼 수 없는 플랫폼인 경우 [NotSupportInPlatform]페이지를 출력한다.
class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  /// 수원대학교의 공지사항을 html문서로 가져오는 메서드이다.
  Future getData() async {
    return await http
        .get(Uri.parse('https://www.suwon.ac.kr/index.html?menuno=674'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SuwonButton(
          icon: Icons.screen_share_outlined,
          buttonName: '브라우저로 보기',
          onPressed: () async {
            await launch('https://www.suwon.ac.kr/index.html?menuno=674',
                forceSafariVC: false, forceWebView: false);
          }),
      body: mainScreen(),
    );
  }

  Widget mainScreen() {
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
              return const DataLoadingError();
            } else {
               rows = parse((snapshot.data as http.Response).body)
                  .getElementsByClassName('board_basic_list')[0];
              return ListView.builder(
                  itemCount: rows.getElementsByClassName('subject').length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, String> dat = {};
                    dat['title'] =
                        rows.getElementsByClassName('subject')[index].text.trim();
                    dat['site_code'] = rows
                        .getElementsByClassName('subject')[index]
                        .innerHtml
                        .split(',')[2]
                        .split(')')[0];
                    return SimpleCardButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed('/info/detail', arguments: dat),
                        title: dat['title']!,
                        content: Text(
                          rows
                                  .getElementsByClassName('info')[index]
                                  .getElementsByClassName('date')[0]
                                  .text
                                  .trim() +
                              '/' +
                              rows
                                  .getElementsByClassName('info')[index]
                                  .getElementsByClassName('hit')[0]
                                  .text
                                  .trim(),
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
