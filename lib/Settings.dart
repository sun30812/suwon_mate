import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<String> subList = ['컴퓨터학부', '경영학부'];
  String _mySub = '컴퓨터학부';
  List<DropdownMenuItem<String>> menu = [];

  @override
  void initState() {
    super.initState();
    for(var sub in subList) {
      menu.add(DropdownMenuItem(value: sub, child: Text(sub)));
    }
    print("OK");
  }


  @override
  void dispose() async {
    super.dispose();
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setString('mySub', _mySub);
  }

  Future<String?> getSettings() async {
    print("GS");
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref.getString('mySub');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('기본 전공: '),
                DropdownButton<String>(items: menu, onChanged: (String? value){
                  setState(() {
                    _mySub = value!;
                  });
                }, value: _mySub),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.amber,),
              Text('이 설정(기본 전공 설정)은 현재 적용이 불가능합니다.'),
            ],
          ),
          const Divider(),
          TextButton(
              onPressed: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          children: const [
                            Icon(Icons.warning_amber_outlined),
                            Text('경고')
                          ],
                        ),
                        content: const Text('저장된 개설 과목 데이터를 지우고 '
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
              child: Text('디버그: 다음 번에 개설 과목 동기화')),
          Divider(),
          TextButton(onPressed: () async {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      children: const [
                        Icon(Icons.error_outline),
                        Text('경고')
                      ],
                    ),
                    content: const Text('이 앱의 모든 데이터를 지우시겠습니까?'),
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
    }, child: Text('디버그: 앱의 모든 설정 데이터 지우기', style: TextStyle(color: Colors.redAccent))),
          Divider()
        ],
      ),
    );
  }
}
