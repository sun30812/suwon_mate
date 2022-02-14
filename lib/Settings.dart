import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/styleWidget.dart';

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
  bool _isSynced = false;
  final isDebug = true;
  List<DropdownMenuItem<String>> subDropdownList = [];
  List<DropdownMenuItem<String>> gradeDropdownList = [];

  Future<SharedPreferences> getSettings() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref;
  }

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setString('mySub', _mySub);
    _pref.setString('myGrade', _grade);
  }

  Widget noSyncWarning() {
    if (_isSynced) {
      return Container();
    }
    return Card(
      color: Colors.amber,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.warning),
              Text('주의', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),)
            ],
          ),
          const Text('아직 개설 강좌 조회를 들어가지 않은 경우 기본 전공을 지정할 수 있는 범위가 좁습니다.')
        ],
      ),
    );
  }

  Widget debugWidget() {
    if (isDebug) {
      return CardInfo(icon: Icons.adb_outlined, title: '디버그 설정',
          detail: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.amber,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_outlined),
                      Padding(padding: EdgeInsets.only(right: 3.0)),
                      Flexible(child: Text('이 설정을 숨기려면 Settings.dart의 isDebug변수를 false로 지정합니다.')),
                    ],
                  ),
                ),
              ),
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
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('확인')),
                              TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('취소'))
                            ],
                          );
                        });
                  },
                  child: const Text('디버그: 다음 번에 개설 과목 동기화')),
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
                            content: const Text('저장된 즐겨찾기 과목을 모두 지우시겠습니까?'),
                            scrollable: true,
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    SharedPreferences _pref =
                                    await SharedPreferences.getInstance();
                                    _pref.remove('favorites');
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('확인')),
                              TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('취소'))
                            ],
                          );
                        });
                  },
                  child: const Text('디버그: 즐겨찾기 항목 모두 제거')),
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
                                    _pref.clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('확인'),
                              ),
                              TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('취소'))
                            ],
                          );
                        });
                  },
                  style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.redAccent.withAlpha(50)),
                    foregroundColor: MaterialStateProperty.all(Colors.redAccent)
                  ),
                  child: const Text('디버그: 앱의 모든 설정 데이터 지우기',
                      )),
            ],
          ));
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: FutureBuilder(
        future: getSettings(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          if ((snapshot.data as SharedPreferences).containsKey('dp_set')) {
            subDropdownList = (snapshot.data as SharedPreferences).getStringList('dp_set')!
                .map((dat) => DropdownMenuItem(
              child: Text(dat),
              value: dat,
            ))
                .toList();
            subDropdownList.sort((a,b) => a.value!.compareTo(b.value!));
            _isSynced = true;
          }
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
              CardInfo(icon: Icons.school_outlined, title: '기본 정보 수정',
                  detail: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: noSyncWarning(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('기본 전공: '),
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
                          const Text('기본 학년: '),
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
                    ],
                  )
              ),
              debugWidget(),
              CardInfo(
                icon: Icons.info_outline,
                title: '버전 정보',
                detail: Text('로컬 DB 버전: ${(snapshot.data as SharedPreferences).getString('db_ver') ?? 'unknown'}'),
              )
            ],
          );
        }
      }),
    );
  }
}
