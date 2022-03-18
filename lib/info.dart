import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'style_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  Future getData() async {
    return await http
        .get(Uri.parse('https://www.suwon.ac.kr/index.html?menuno=674'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SuwonButton(
          icon: Icons.screen_share_outlined,
          buttonName: '웹에서 보기',
          onPressed: () async {
            await launch('https://www.suwon.ac.kr/index.html?menuno=674',
                forceSafariVC: true, forceWebView: true);
          }),
      appBar: AppBar(title: const Text('공지사항')),
      body: mainScreen(),
    );
  }

  Widget mainScreen() {
    if (kIsWeb) {
      return NotSupportInPlatform('Web');
    }
    return Center(
      child: FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Column(
              children: const [
                CircularProgressIndicator.adaptive(),
                Text('수원대 사이트에 접속 중..'
                    '웹 버전에서는 정상적으로 작동하지 않습니다.')
              ],
            );
          } else {
            var rows = parse((snapshot.data as http.Response).body)
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
                  return GestureDetector(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/info/detail', arguments: dat),
                    child: CardInfo.simplified(
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
                        )),
                  );
                });
          }
        },
      ),
    );
  }
}
