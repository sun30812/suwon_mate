import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:suwon_mate/styles/style_widget.dart';

/// 수원대학교 공지사항 페이지에서 주요행사를 가져오기 위해 사용되는 메서드이다.
///
/// 수원대학교 주요행사 페이지의 내용을 파싱을 위해 html문서로 가져온다. 비동기적 작업으로 수행을 하고
/// 작업이 완료되는 동안 사용자에게 로딩창을 띄울 수 있도록 [Future]를 반환한다.
Future<http.Response> getData() {
  return http.get(Uri.parse('https://www.suwon.ac.kr/index.html?menuno=727'));
}

/// 학교의 주요 행사를 안내하는 페이지이다.
///
/// 학교의 주요 행사를 위젯으로 정리해놓은 페이지이다. 해당 페이지에서는 사이트에 게시된 전체 일정과 현재 일정을 확인할 수 있다.
class SchedulePage extends StatelessWidget {
  /// 학교의 주요 행사를 위젯으로 정리해놓은 페이지이다.
  const SchedulePage({Key? key}) : super(key: key);

  /// 현재 시행되고 있는 이벤트를 알려주는 메서드이다. 만일 오늘 해당되는 행사가 없을 시 없음 이라는 값을 반환한다.
  ///
  /// 현재 시행되는 이벤트 이름과 날짜 정보를 가진 [scheduleList]를 필요로 한다.
  String getNowEvent(List<Map<String, String>> scheduleList) {
    DateTime now = DateTime.now();
    for (Map dat in scheduleList) {
      String temp = (dat.keys.first as String)
          .replaceAll(RegExp(r'\([^)]*\)'), '')
          .replaceAll('.', '');
      if (now == DateTime.parse(temp.substring(0, 8))) {
        return dat.values.first.toString();
      } else if (temp.contains('~')) {
        if (now.millisecondsSinceEpoch >=
                DateTime.parse(temp.substring(0, 8)).millisecondsSinceEpoch &&
            now.millisecondsSinceEpoch <=
                DateTime.parse(temp.substring(11, 19)).millisecondsSinceEpoch) {
          return dat.values.first.toString();
        }
      }
    }
    return '없음';
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const NotSupportInPlatform('Web');
    }
    getData();
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.none) {
              return Card(
                color: Colors.amber,
                child: Row(
                  children: const [
                    Icon(Icons.announcement),
                    Text("오류가 발생했습니다."),
                  ],
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator.adaptive(),
                    Text('학사 일정 불러오는 중..')
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return DataLoadingError(
                errorMessage: snapshot.error,
              );
            } else {
              var doc = parse((snapshot.data as http.Response).body);
              var rows = doc
                  .getElementsByClassName('contents_table')[0]
                  .getElementsByTagName('tr');
              List<Map<String, String>> scheduleList = [];
              for (int index = 0; index < rows.length - 1; index++) {
                Map<String, String> tempMap = {
                  (rows[1 + index].getElementsByTagName('td')[0]).text:
                      (rows[1 + index].getElementsByTagName('td')[1]).text
                };
                scheduleList.add(tempMap);
              }
              return Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        const Icon(Icons.calendar_month),
                        const Padding(
                          padding: EdgeInsets.only(right: 4.0),
                        ),
                        Flexible(
                          child: Text(
                            '현재 일정: ${getNowEvent(scheduleList)}',
                            softWrap: true,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Divider(
                          height: MediaQuery.of(context).size.height,
                          color: Colors.black,
                        )
                      ]),
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    child: ListView.builder(
                        itemCount: scheduleList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SimpleCard(
                              title: scheduleList[index].values.first,
                              content: Text(scheduleList[index].keys.first));
                        }),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
