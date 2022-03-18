import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/style_widget.dart';

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
  late String _version;
  final isDebug = false;
  late PackageInfo packageInfo;
  late String serverVersion;
  List<DropdownMenuItem<String>> subDropdownList = [];
  List<DropdownMenuItem<String>> gradeDropdownList = [];
  Map<String, dynamic> functionSetting = {'offline': false};

  Future<SharedPreferences> getSettings() async {
    packageInfo = await PackageInfo.fromPlatform();
    DatabaseReference appVer = FirebaseDatabase.instance.ref('version');
    Map versionInfo = (await appVer.once()).snapshot.value as Map;
    _version = versionInfo['app_ver'];
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
    _pref.setString('settings', jsonEncode(functionSetting));
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
              Text(
                '주의',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              )
            ],
          ),
          const Text('아직 개설 강좌 조회를 들어가지 않은 경우 기본 전공을 지정할 수 있는 범위가 좁습니다.')
        ],
      ),
    );
  }

  Widget debugWidget() {
    if (isDebug) {
      return CardInfo(
          icon: Icons.adb_outlined,
          title: '디버그 설정',
          detail: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotiCard(
                color: Colors.amber,
                icon: Icons.warning_amber_outlined,
                message: '이 설정을 숨기려면 settings.dart의 isDebug변수를 false로 지정합니다.',
              ),
              TextButton(
                  onPressed: () async {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) => SuwonDialog(
                              icon: Icons.error_outline,
                              title: '경고',
                              content: const Text('즐겨찾는 과목의 데이터를 모두 지웁니까?'),
                              onPressed: () async {
                                SharedPreferences _pref =
                                    await SharedPreferences.getInstance();
                                _pref.remove('favorites');
                                Navigator.of(context).pop();
                              },
                            ));
                  },
                  child: const Text('디버그: 즐겨찾기 항목 모두 제거')),
              TextButton(
                  onPressed: () async {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) => SuwonDialog(
                              icon: Icons.error_outline,
                              title: '경고',
                              content: const Text('앱의 데이터를 모두 지웁니까?'),
                              onPressed: () async {
                                SharedPreferences _pref =
                                    await SharedPreferences.getInstance();
                                _pref.remove('favorites');
                                Navigator.of(context).pop();
                              },
                            ));
                  },
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          Colors.redAccent.withAlpha(30)),
                      foregroundColor:
                          MaterialStateProperty.all(Colors.redAccent)),
                  child: const Text(
                    '디버그: 앱의 모든 설정 데이터 지우기',
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
              return const Center(child: CircularProgressIndicator.adaptive());
            } else {
              if (_isFirst &&
                  (snapshot.data as SharedPreferences)
                      .containsKey('settings')) {
                functionSetting = jsonDecode(
                    (snapshot.data as SharedPreferences)
                        .getString('settings')!);
              }
              if ((snapshot.data as SharedPreferences).containsKey('dp_set')) {
                subDropdownList = (snapshot.data as SharedPreferences)
                    .getStringList('dp_set')!
                    .map((dat) => DropdownMenuItem(
                          child: Text(dat),
                          value: dat,
                        ))
                    .toList();
                subDropdownList.sort((a, b) => a.value!.compareTo(b.value!));
                _isSynced = true;
              }
              if (_isFirst) {
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
                  CardInfo(
                      icon: Icons.school_outlined,
                      title: '기본 정보 수정',
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
                      )),
                  CardInfo(
                      icon: Icons.settings,
                      title: '기능 설정',
                      detail: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const AlertDialog(
                                              title: Text('데이터 절약 모드'),
                                              content: Text(
                                                  '데이터 사용량을 줄이기 위해 일부 기능의 사용을 제한하고, DB 업데이트를 '
                                                  '자동으로 하지 않습니다.'),
                                            );
                                          });
                                    },
                                    child: Row(
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.only(right: 10.0),
                                          child:
                                              Icon(Icons.offline_bolt_outlined),
                                        ),
                                        Text('데이터 절약 모드'),
                                      ],
                                    )),
                                Switch(
                                    value: functionSetting['offline']!,
                                    onChanged: (newValue) {
                                      setState(() {
                                        functionSetting['offline'] = newValue;
                                      });
                                    }),
                              ],
                            ),
                          )
                        ],
                      )),
                  CardInfo(
                    icon: Icons.restore,
                    title: '초기화 메뉴',
                    detail: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                            onPressed: () async {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) =>
                                      SuwonDialog(
                                          icon: Icons.error_outline,
                                          title: '경고',
                                          content: const Text(
                                              '앱의 모든 데이터를 초기화합니다. 계속하시겠습니까?'),
                                          onPressed: () async {
                                            SharedPreferences _pref =
                                                await SharedPreferences
                                                    .getInstance();
                                            _pref.clear();
                                            Navigator.of(context).pop();
                                          }));
                            },
                            style: ButtonStyle(
                                overlayColor: MaterialStateProperty.all(
                                    Colors.redAccent.withAlpha(30)),
                                foregroundColor: MaterialStateProperty.all(
                                    Colors.redAccent)),
                            child: const Text(
                              '전체 데이터 초기화',
                            )),
                        TextButton(
                            onPressed: () async {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SuwonDialog(
                                      icon: Icons.error_outline,
                                      title: '경고',
                                      content: const Text(
                                          'DB의 데이터를 다시 받습니다. 계속하시겠습니까?'),
                                      onPressed: () async {
                                        SharedPreferences _pref =
                                            await SharedPreferences
                                                .getInstance();
                                        _pref.remove('class');
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  });
                            },
                            style: ButtonStyle(
                                overlayColor: MaterialStateProperty.all(
                                    Colors.redAccent.withAlpha(30)),
                                foregroundColor: MaterialStateProperty.all(
                                    Colors.redAccent)),
                            child: const Text(
                              'DB 데이터 다시 받기',
                            )),
                      ],
                    ),
                  ),
                  debugWidget(),
                  versionInfo(snapshot)
                ],
              );
            }
          }),
    );
  }

  Widget versionInfo(AsyncSnapshot<dynamic> snapshot) {
    if (kIsWeb) {
      return CardInfo(
        icon: Icons.info_outline,
        title: '버전 정보',
        detail: Column(
          children: [
            const Text(
              'Web 플랫폼에서는 앱 버전이 항상 최신 버전으로 유지됩니다.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
                '로컬 DB 버전: ${(snapshot.data as SharedPreferences).getString('db_ver') ?? '다운로드 필요'}\n'
                '앱 버전: ${packageInfo.version}'),
          ],
        ),
      );
    }
    return CardInfo(
      icon: Icons.info_outline,
      title: '버전 정보',
      detail: Text(
          '로컬 DB 버전: ${(snapshot.data as SharedPreferences).getString('db_ver') ?? '다운로드 필요'}\n'
          '로컬 앱 버전: ${packageInfo.version}\n'
          '최신 앱 버전: $_version'),
    );
  }
}
