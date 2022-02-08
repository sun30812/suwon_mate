import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:suwon_mate/main.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  Future getData() async {
    return await http
        .get(Uri.parse('https://www.suwon.ac.kr/index.html?menuno=674'));
  }

  void getTestData() async {
    var dd = await http
        .get(Uri.parse('https://www.suwon.ac.kr/index.html?menuno=674'));
    print(parse(dd.body)
        .getElementsByClassName('board_basic_list')[0]
        .getElementsByClassName('subject')[0]
        .text);
  }

  @override
  Widget build(BuildContext context) {
    getTestData();
    return Scaffold(
      floatingActionButton: SuwonButton(
          icon: Icons.school_outlined,
          buttonName: '학교사이트 이동',
          onPressed: () async {
            await launch('https://suwon.ac.kr',
                forceSafariVC: true, forceWebView: true);
          }),
      appBar: AppBar(title: const Text('공지사항')),
      body: Center(
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
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              rows
                                  .getElementsByClassName('subject')[index]
                                  .text
                                  .trim(),
                              style: const TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            Text(
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
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            }
          },
        ),
      ),
    );
  }
}
