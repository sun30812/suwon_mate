import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? _mySub;
  List<DropdownMenuItem> menu = [
    DropdownMenuItem(child: Text('컴퓨터학부')),
    DropdownMenuItem(child: Text('경영학부'))
  ];
  @override
  void initState() {
    super.initState();
    _mySub = '컴퓨터학부';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: ListView(
        children: [
          Text('기본 학부 설정'),
          OutlinedButton(
              onPressed: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          children: [
                            Icon(Icons.warning_amber_outlined),
                            Text('경고')
                          ],
                        ),
                        content: Text('저장된 개설 과목 데이터를 지우고 '
                            '다음 실행 시 다시 받도록 하시겠습니까?'),
                        scrollable: true,
                        actions: [
                          TextButton(
                              onPressed: () async {
                                SharedPreferences _pref =
                                    await SharedPreferences.getInstance();
                                _pref.remove('class');
                              },
                              child: Text('확인')),
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('취소'))
                        ],
                      );
                    });
              },
              child: Text('디버그: 다음 번에 개설 과목 동기화'))
        ],
      ),
    );
  }
}
