import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<String> subList = ['컴퓨터학부', '경영학부'];
  List<String> gradeList = ['1학년', '2학년', '3학년', '4학년'];
  String _mySub = '컴퓨터학부';
  String _grade = '1학년';
  bool _isFirst = true;
  List<DropdownMenuItem<String>> subDropdownList = [];
  List<DropdownMenuItem<String>> gradeDropdownList = [];

  Future<SharedPreferences> getSettings() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    // _mySub = _pref.getString('mySub') ?? '';
    // _grade = _pref.getString('myGrade') ?? '';
    return _pref;
  }

  @override
  void initState() {
    super.initState();
    getSettings();
    print("init");
    subDropdownList = subList
        .map((dat) => DropdownMenuItem(
              child: Text(dat),
              value: dat,
            ))
        .toList();
    gradeDropdownList = gradeList
        .map((dat) => DropdownMenuItem(
              child: Text(dat),
              value: dat,
            ))
        .toList();
    print(_grade);
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setString('mySub', _mySub);
    _pref.setString('myGrade', _grade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: FutureBuilder(
        future: getSettings(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          if (_isFirst)
          {
                _grade =
                    (snapshot.data as SharedPreferences).getString('myGrade') ??
                        '1학년';
                _mySub =
                    (snapshot.data as SharedPreferences).getString('mySub') ??
                        '컴퓨터학부';
                _isFirst = false;
              }
              return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('기본 전공: '),
                    DropdownButton<String>(
                        items: subDropdownList,
                        onChanged: (String? value) {
                          setState(() {
                            _mySub = value!;
                          });
                        },
                        value: _mySub),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('기본 학년: '),
                  DropdownButton<String>(
                      items: gradeDropdownList,
                      onChanged: (String? value) {
                        setState(() {
                          _grade = value!;
                        });
                      },
                      value: _grade),
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
              TextButton(
                  onPressed: () async {
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
                  },
                  child: Text('디버그: 앱의 모든 설정 데이터 지우기',
                      style: TextStyle(color: Colors.redAccent))),
              Divider()
            ],
          );
        }
      }),
    );
  }
}
