import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/styles/style_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<String> subList = ['컴퓨터학부', '경영학부'];
  List<String> majorList = ['학부 공통', '전체'];
  List<String> gradeList = ['1학년', '2학년', '3학년', '4학년'];
  String _myDp = '컴퓨터학부';
  String _mySub = '전체';
  String _grade = '1학년';
  bool _isFirst = true;
  bool _isSynced = false;
  final isDebug = true;
  late PackageInfo packageInfo;
  late String serverVersion;
  List<DropdownMenuItem<String>> subDropdownList = [];
  List<DropdownMenuItem<String>> majorDropdownList = [];
  List<DropdownMenuItem<String>> gradeDropdownList = [];
  Map<String, dynamic> functionSetting = {
    'offline': false,
    'liveSearch': true,
    'liveSearchCount': 0.0
  };

  Future<SharedPreferences> getSettings() async {
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (_) {
      packageInfo = packageInfo = PackageInfo(
          appName: 'Suwon Mate',
          packageName: 'suwon_mate',
          version: '2.1.0',
          buildNumber: '13');
    }
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref;
  }

  Stream getVersionData() {
    DatabaseReference appVer = FirebaseDatabase.instance.ref('version');
    return appVer.child('app_ver').onValue;
  }

  Stream getDepartment() {
    DatabaseReference data = FirebaseDatabase.instance.ref('departments');
    return data.onValue;
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
    _pref.setString('myDept', _myDp);
    _pref.setString('mySubject', _mySub);
    _pref.setString('myGrade', _grade);
    _pref.setString('settings', jsonEncode(functionSetting));
  }

  Widget noSyncWarning() {
    if (_isSynced) {
      return Container();
    }
    return const NotiCard(
        icon: Icons.warning_amber,
        color: Colors.amber,
        message: '아직 개설 강좌 조회를 들어가지 않은 경우 기본 전공을 지정할 수 있는 범위가 좁습니다.');
  }

  Widget debugWidget() {
    if (isDebug) {
      return CardInfo(
          icon: Icons.adb_outlined,
          title: '디버그 설정',
          detail: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NotiCard(
                color: Colors.amber,
                icon: Icons.warning_amber_outlined,
                message: '이 설정을 숨기려면 settings.dart의 isDebug변수를 false로 지정합니다.',
              ),
              TextButton(
                  onPressed: (() async {
                    SharedPreferences _pref =
                        await SharedPreferences.getInstance();
                    _pref.remove('favoritesMap');
                    List<String> _list = ['06993-001'];
                    await _pref.setStringList('favorite', _list);
                    Navigator.of(context).pop();
                  }),
                  child: const Text('디버그: 이전 즐겨찾기 항목으로 설정')),
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
                                _pref.remove('favoritesMap');
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
                                _pref.remove('favoritesMap');
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
      body: FutureBuilder(
          future: getSettings(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (snapshot.hasError) {
              return const DataLoadingError();
            } else {
              if (_isFirst &&
                  (snapshot.data as SharedPreferences)
                      .containsKey('settings')) {
                functionSetting = jsonDecode(
                    (snapshot.data as SharedPreferences)
                        .getString('settings')!);
              }
              if ((snapshot.data as SharedPreferences).containsKey('dp_set')) {
                AlertDialog(
                  title: Row(
                    children: const [
                      Icon(Icons.warning_amber_outlined),
                      Text('경고'),
                    ],
                  ),
                  content: const Text('최신버전과 호환되지 않는 데이터가 존재합니다.\n'
                      '해결을 위해 기본 설정된 전공과목을 초기화하고 DB를 다시 받습니다.'),
                  actions: [
                    TextButton(
                        onPressed: () => SystemNavigator.pop(animated: true),
                        child: const Text('무시(앱 종료)')),
                    TextButton(
                        onPressed: (() async {
                          SharedPreferences _pref =
                              await SharedPreferences.getInstance();
                          _pref.remove('dp_set');
                        }),
                        child: const Text('확인'))
                  ],
                );
              }
              if ((snapshot.data as SharedPreferences).containsKey('dp_set')) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.warning_amber_outlined),
                      Text(
                          '일부 구조 개선으로 인해 데이터 갱신이 필요합니다.\n앱스에서 개설 강좌 조회 메뉴에 접속해주세요.'),
                    ],
                  ),
                );
              }

              majorDropdownList.clear();
              majorDropdownList.add(const DropdownMenuItem(
                child: Text('전체'),
                value: '전체',
              ));
              majorDropdownList.add(const DropdownMenuItem(
                child: Text('학부 공통'),
                value: '학부 공통',
              ));
              if ((snapshot.data as SharedPreferences).containsKey('dpMap')) {
                Map _subMap = jsonDecode(
                    (snapshot.data as SharedPreferences).getString('dpMap')!);
                subDropdownList = (_subMap.keys.toList() as List<String>)
                    .map((dat) => DropdownMenuItem(
                          child: Text(dat),
                          value: dat,
                        ))
                    .toList();
                subDropdownList.sort((a, b) => a.value!.compareTo(b.value!));
                List _tempList = _subMap[_myDp] as List;
                _tempList.sort((a, b) => a.compareTo(b));
                majorDropdownList.addAll((_tempList)
                    .map((dat) => DropdownMenuItem(
                          child: Text(dat.toString()),
                          value: dat.toString(),
                        ))
                    .toList());
                _isSynced = true;
              }
              if (_isFirst) {
                _grade =
                    (snapshot.data as SharedPreferences).getString('myGrade') ??
                        '1학년';
                _myDp =
                    (snapshot.data as SharedPreferences).getString('myDept') ??
                        '컴퓨터학부';
                _mySub = (snapshot.data as SharedPreferences)
                        .getString('mySubject') ??
                    '학부 공통';
                _isFirst = false;
              }
              return ListView(
                children: [
                  CardInfo(
                      icon: Icons.school_outlined,
                      title: '학생 정보',
                      detail: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('개설 강좌메뉴에서 기본으로 보여질 학부 및 학년을 선택합니다.'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: noSyncWarning(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('기본 학부: '),
                                DropdownButton<String>(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    items: subDropdownList,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _myDp = value!;
                                        _mySub = '학부 공통';
                                      });
                                    },
                                    value: _myDp),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('기본 전공: '),
                                DropdownButton<String>(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    items: majorDropdownList,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _mySub = value!;
                                      });
                                    },
                                    value: _mySub),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('기본 학년: '),
                                DropdownButton<String>(
                                    items: gradeDropdownList,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    onChanged: (String? value) {
                                      setState(() {
                                        _grade = value!;
                                      });
                                    },
                                    value: _grade),
                              ],
                            ),
                          ),
                        ],
                      )),
                  CardInfo(
                      icon: Icons.settings_outlined,
                      title: '기능 설정',
                      detail: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('각 항목을 클릭하면 설명을 볼 수 있습니다.'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Material(
                                  color: Colors.grey[300],
                                  child: InkWell(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: const Text('확인'))
                                                ],
                                                title: const Text('데이터 절약 모드'),
                                                content: const Text(
                                                    '데이터 사용량을 줄이기 위해 일부 기능의 사용을 제한하고, DB 업데이트를 '
                                                    '자동으로 하지 않습니다. \nWeb 플랫폼에서는 지원하지 않습니다.'),
                                              );
                                            });
                                      },
                                      child: Row(
                                        children: const [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(right: 10.0),
                                            child: Icon(
                                                Icons.offline_bolt_outlined),
                                          ),
                                          Text('데이터 절약 모드'),
                                        ],
                                      )),
                                ),
                                Switch(
                                    activeTrackColor:
                                        const Color.fromARGB(255, 0, 54, 112),
                                    activeColor:
                                        const Color.fromARGB(200, 0, 54, 112),
                                    value: functionSetting['offline']!,
                                    onChanged: (newValue) {
                                      if (kIsWeb) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    '해당 플랫폼에서는 지원하지 않습니다.')));
                                        return;
                                      }
                                      setState(() {
                                        functionSetting['offline'] = newValue;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('설정 되었습니다.'),
                                        duration: Duration(seconds: 2),
                                      ));
                                    }),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Material(
                                  color: Colors.grey[300],
                                  child: InkWell(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: const Text('확인'))
                                                ],
                                                title: const Text('입력하여 바로 검색'),
                                                content: const Text(
                                                    '과목을 검색할 때 입력하는 즉시 검색을 바로 시작합니다.\n'
                                                    '검색 시 동작이 많이 끊기는 경우 해당 설정을 조절하여 개선할 수 있습니다.'),
                                              );
                                            });
                                      },
                                      child: Row(
                                        children: const [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(right: 10.0),
                                            child: Icon(Icons.search),
                                          ),
                                          Text('입력하여 바로 검색'),
                                        ],
                                      )),
                                ),
                                Switch(
                                    activeTrackColor:
                                        const Color.fromARGB(255, 0, 54, 112),
                                    activeColor:
                                        const Color.fromARGB(200, 0, 54, 112),
                                    value:
                                        functionSetting['liveSearch'] ?? true,
                                    onChanged: (newValue) {
                                      setState(() {
                                        functionSetting['liveSearch'] =
                                            newValue;
                                      });
                                    }),
                              ],
                            ),
                          ),
                          if (functionSetting['liveSearch'] ?? true)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  const Text('슬라이더를 조절하여 자동으로 검색을 시작할 글자 수 지정'),
                                  Slider(
                                    divisions: 3,
                                    label:
                                        '${((functionSetting['liveSearchCount'] ?? 0.0) as double).round()} 자',
                                    min: 0,
                                    max: 3,
                                    value: functionSetting['liveSearchCount'] ??
                                        0.0,
                                    onChanged: (value) => setState(() {
                                      functionSetting['liveSearchCount'] =
                                          value;
                                    }),
                                  ),
                                  Text(
                                      '현재 설정된 글자 수: ${((functionSetting['liveSearchCount'] ?? 0.0) as double).round()}자')
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
                                              '학생 정보를 포함한 앱의 모든 데이터를 초기화합니다. 계속하시겠습니까?(이 작업은 되돌릴 수 없습니다.)'),
                                          isDestructive: true,
                                          onPressed: () async {
                                            SharedPreferences _pref =
                                                await SharedPreferences
                                                    .getInstance();
                                            _pref.clear().then((value) =>
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            '앱의 모든 데이터를 초기화 하였습니다.'))));
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
                                        _pref.remove('db_ver').then((value) =>
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'DB 데이터를 지웠습니다.'))));
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  });
                            },
                            child: const Text(
                              'DB 데이터 다시 받기',
                            )),
                      ],
                    ),
                  ),
                  debugWidget(),
                  versionInfo(snapshot),
                  CardInfo(
                      icon: Icons.help_outline,
                      title: '문의하기',
                      detail: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              '문제가 있는 부분이나 기능 제안은 이메일로 보내셔도 좋고 깃허브에 issue를 열어도 됩니다.'),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.email_outlined),
                                const Padding(
                                    padding: EdgeInsets.only(right: 8.0)),
                                TextButton(
                                    child: const Text('이메일 보내기'),
                                    onPressed: (() async {
                                      await launchUrlString(
                                          'mailto:orgsun30812+suwon_mate_github@gmail.com');
                                    })),
                              ],
                            ),
                          )
                        ],
                      ))
                ],
              );
            }
          }),
    );
  }

  Widget updater(bool equalVersion) {
    if (equalVersion) {
      return Row(
        children: const [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
          ),
          Padding(padding: EdgeInsets.only(right: 10.0)),
          Text(
            '현재 최신 버전을 사용하고 있습니다.',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      );
    } else {
      return Material(
        color: Colors.grey[300],
        child: InkWell(
          onTap: ((() async => await launchUrlString(
              'https://github.com/sun30812/suwon_mate/releases'))),
          child: Column(
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.arrow_circle_up_outlined,
                    color: Colors.blue,
                  ),
                  Padding(padding: EdgeInsets.only(right: 10.0)),
                  Text(
                    '업데이트 사용가능(클릭하여 다운받기)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget versionInfo(AsyncSnapshot<dynamic> snapshot) {
    if (kIsWeb) {
      return CardInfo(
        icon: Icons.info_outline,
        title: '버전 정보',
        detail: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
                Padding(padding: EdgeInsets.only(right: 10.0)),
                Text(
                  'Web 플랫폼은 항상 최신 버전으로 유지됩니다.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            Text(
                '로컬 DB 버전: ${(snapshot.data as SharedPreferences).getString('db_ver') ?? '다운로드 필요'}\n'
                '앱 버전: ${packageInfo.version}'),
          ],
        ),
      );
    }
    return StreamBuilder(
        stream: getVersionData(),
        builder: (context, _snapshot) {
          if (!_snapshot.hasData) {
            return const CardInfo(
              icon: Icons.info_outline,
              title: '버전 정보',
              detail: Center(child: CircularProgressIndicator.adaptive()),
            );
          } else if (_snapshot.hasError) {
            return CardInfo(
              icon: Icons.info_outline,
              title: '버전 정보',
              detail: Text(
                  '로컬 DB 버전: ${(snapshot.data as SharedPreferences).getString('db_ver') ?? '다운로드 필요'}\n'
                  '로컬 앱 버전: ${packageInfo.version}\n'
                  '최신 앱 버전: 정보를 가져오는데 오류가 발생했습니다.'),
            );
          } else {
            return CardInfo(
              icon: Icons.info_outline,
              title: '버전 정보',
              detail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  updater((_snapshot.data as DatabaseEvent).snapshot.value ==
                      packageInfo.version),
                  if ((_snapshot.data as DatabaseEvent).snapshot.value !=
                      packageInfo.version)
                    Text(
                        '최신 앱 버전: ${(_snapshot.data as DatabaseEvent).snapshot.value ?? '알 수 없음'}'),
                  Text('로컬 앱 버전: ${packageInfo.version}\n'
                      '로컬 DB 버전: ${(snapshot.data as SharedPreferences).getString('db_ver') ?? '다운로드 필요'}')
                ],
              ),
            );
          }
        });
  }

  Widget downloadUpdate() {
    return TextButton(
        onPressed: (() async => await launchUrlString(
            'https://github.com/sun30812/suwon_mate/releases')),
        child: const Text('업데이트 확인 및 다운받기(사이트 이동)'));
  }
}
