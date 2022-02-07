import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

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

Future checkInternet() async {
  return await Connectivity().checkConnectivity();
}

class SchedulePage extends StatelessWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
        appBar: AppBar(
          title: Text('학사 일정'),
        ),
        body: checkInternetPage());
  }

  Widget checkInternetPage() {
    return Center(
      child: FutureBuilder(
        future: checkInternet(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator.adaptive();
          } else if (snapshot.hasError) {
            return Card(
              child: Row(
                children: [
                  Icon(Icons.announcement),
                  Text("오류가 발생했습니다."),
                ],
              ),
              color: Colors.amber,
            );
          } else {
            ConnectivityResult _result = snapshot.data as ConnectivityResult;
            if (_result == ConnectivityResult.none) {
              return Center(
                child: Column(
                  children: [
                    Icon(Icons.signal_cellular_connected_no_internet_0_bar),
                    Text('사용자의 기기가 네트워크에 연결되어있지 않습니다.')
                  ],
                ),
              );
            }
            return dataLoadingPage();
          }
        },
      ),
    );
  }

  Widget dataLoadingPage() {
    return Center(
      child: FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.none) {
            return Card(
              child: Row(
                children: [
                  Icon(Icons.announcement),
                  Text("오류가 발생했습니다."),
                ],
              ),
              color: Colors.amber,
            );
          } else if (!snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator.adaptive(),
                Text('수원대 사이트에 접속 중..')
              ],
            );
          } else if (snapshot.hasError) {
            return Card(
              child: Row(
                children: [
                  Icon(Icons.announcement),
                  Text("오류가 발생했습니다."),
                ],
              ),
              color: Colors.amber,
            );
          } else {
            var doc = parse((snapshot.data as http.Response).body);
            var rows = doc
                .getElementsByClassName('contents_table')[0]
                .getElementsByTagName('tr');
            return ListView.builder(
                itemCount: rows.length - 1,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (rows[1 + index].getElementsByTagName('td')[1])
                                .text,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            (rows[1 + index].getElementsByTagName('td')[0])
                                .text,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }
        },
      ),
    );
  }
}
