import 'package:fluent_ui/fluent_ui.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:suwon_mate/schedule.dart';
import 'package:suwon_mate/styles/style_widget.dart';

/// 학교의 주요 행사를 안내하는 페이지이다.
///
/// 학교의 주요 행사를 위젯으로 정리해놓은 페이지이다. 해당 페이지에서는 사이트에 게시된 전체 일정과 현재 일정을 확인할 수 있다.
class FluentSchedulePage extends StatelessWidget {
  /// 학교의 주요 행사를 위젯으로 정리해놓은 페이지이다.
  const FluentSchedulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getData();
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('학사일정'),
      ),
      content: Center(
        child: FutureBuilder(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.none) {
              return Card(
                backgroundColor: Colors.orange,
                child: const Row(
                  children: [
                    Icon(FluentIcons.alert_solid),
                    Text('오류가 발생했습니다.'),
                  ],
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ProgressRing(), Text('학사일정 불러오는 중..')],
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
                        const Icon(FluentIcons.calendar_agenda),
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
                        const Divider()
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
