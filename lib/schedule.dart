import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:suwon_mate/style_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
      appBar: AppBar(
        title: const Text('학사 일정'),
      ),
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
              return ListView.builder(
                  itemCount: rows.length - 1,
                  itemBuilder: (BuildContext context, int index) {
                    return SimpleCardButton(
                        title: (rows[1 + index].getElementsByTagName('td')[1])
                            .text,
                        content: Text(
                            (rows[1 + index].getElementsByTagName('td')[0])
                                .text));
                  });
            }
          },
        ),
      ),
    );
  }
}
