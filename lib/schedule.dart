import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:suwon_mate/styles/style_widget.dart';

Future<http.Response> getData() async {
  return await http.get(
      Uri.parse('https://www.suwon.ac.kr/index.html?menuno=727'),
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS, HEAD",
        "Access-Control-Allow-Credentials": "true",
        "Access-Control-Allow-Headers":
            "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
      });
}

class SchedulePage extends StatelessWidget {
  const SchedulePage({Key? key}) : super(key: key);

  String getNowEvent(List<Map<String, String>> scheduleList) {
    DateTime now = DateTime.now();
    for (Map dat in scheduleList) {
      String _temp = (dat.keys.first as String)
          .replaceAll(RegExp(r'\([^)]*\)'), '')
          .replaceAll('.', '');
      if (now == DateTime.parse(_temp.substring(0, 8))) {
        return dat.values.first.toString();
      } else if (_temp.contains('~')) {
        if (now.millisecondsSinceEpoch >=
                DateTime.parse(_temp.substring(0, 8)).millisecondsSinceEpoch &&
            now.millisecondsSinceEpoch <=
                DateTime.parse(_temp.substring(11, 19))
                    .millisecondsSinceEpoch) {
          return dat.values.first.toString();
        }
      }
    }
    return '없음';
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.none) {
              return Card(
                child: Row(
                  children: const [
                    Icon(Icons.announcement),
                    Text("오류가 발생했습니다."),
                  ],
                ),
                color: Colors.amber,
              );
            } else if (!snapshot.hasData) {
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
              return const DataLoadingError();
            } else {
              var doc = parse((snapshot.data as http.Response).body);
              var rows = doc
                  .getElementsByClassName('contents_table')[0]
                  .getElementsByTagName('tr');
              List<Map<String, String>> _scheduleList = [];
              for (int index = 0; index < rows.length - 1; index++) {
                Map<String, String> _tempMap = {
                  (rows[1 + index].getElementsByTagName('td')[0]).text:
                      (rows[1 + index].getElementsByTagName('td')[1]).text
                };
                _scheduleList.add(_tempMap);
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
                            '현재 일정: ${getNowEvent(_scheduleList)}',
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
                        itemCount: _scheduleList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SimpleCardButton(
                              title: _scheduleList[index].values.first,
                              content: Text(_scheduleList[index].keys.first));
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
