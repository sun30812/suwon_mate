import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  List<String> majorList = ['학부 공통', '전체'];
  List<String> gradeList = ['1학년', '2학년', '3학년', '4학년'];
  String _myDp = '컴퓨터학부';
  String _mySub = '전체';
  String _grade = '1학년';
  bool _isFirst = true;
  bool _isSynced = false;
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
    SharedPreferences _pref = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();
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
                majorDropdownList = (_subMap[_myDp] as List)
                    .map((dat) => DropdownMenuItem(
                          child: Text(dat.toString()),
                          value: dat.toString(),
                        ))
                    .toList();
                majorDropdownList.add(const DropdownMenuItem(
                  child: Text('학부 공통'),
                  value: '학부 공통',
                ));
                majorDropdownList.add(const DropdownMenuItem(
                  child: Text('전체'),
                  value: '전체',
                ));
                majorDropdownList.sort((a, b) => a.value!.compareTo(b.value!));
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
                      icon: Icons.settings,
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
                                GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const AlertDialog(
                                              title: Text('데이터 절약 모드'),
                                              content: Text(
                                                  '데이터 사용량을 줄이기 위해 일부 기능의 사용을 제한하고, DB 업데이트를 '
                                                  '자동으로 하지 않습니다. \nWeb 플랫폼에서는 지원하지 않습니다.'),
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
                                          .showMaterialBanner(MaterialBanner(
                                              content: Row(
                                                children: const [
                                                  Icon(Icons
                                                      .warning_amber_rounded),
                                                  Text('앱을 재시작 해야 변경사항이 적용됩니다.')
                                                ],
                                              ),
                                              actions: [
                                            TextButton(
                                                style: ButtonStyle(
                                                    overlayColor:
                                                        MaterialStateProperty
                                                            .all(Colors
                                                                .redAccent
                                                                .withAlpha(30)),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors
                                                                .redAccent)),
                                                onPressed: (() {
                                                  dispose();
                                                  SystemNavigator.pop(
                                                      animated: true);
                                                }),
                                                child: const Text('앱 종료')),
                                            TextButton(
                                                onPressed: (() {
                                                  ScaffoldMessenger.of(context)
                                                      .clearMaterialBanners();
                                                }),
                                                child: const Text('메세지 닫기')),
                                          ]));
                                    }),
                              ],
                            ),
                          ),
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
                                              title: Text('입력하여 바로 검색'),
                                              content: Text(
                                                  '과목을 검색할 때 입력하는 즉시 검색을 바로 시작합니다. 이 기능을 비활성화 한다면 '
                                                  '검색 버튼이 표시되며 검색 버튼을 눌러야 검색을 진행합니다.'),
                                            );
                                          });
                                    },
                                    child: Row(
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.only(right: 10.0),
                                          child: Icon(Icons.search),
                                        ),
                                        Text('입력하여 바로 검색'),
                                      ],
                                    )),
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
                        const Text(
                            'DB데이터를 다운받다가 문제가 생겨서 개설 강좌 목록이 정상 출력되지 않는 경우 DB데이터 다시 받기가 도움이 됩니다.'),
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
                  CardInfo(
                    icon: Icons.info_outline,
                    title: '버전 정보',
                    detail: Text(
                        '로컬 DB 버전: ${(snapshot.data as SharedPreferences).getString('db_ver') ?? '다운로드 필요'}\n'
                        '로컬 앱 버전: ${packageInfo.version}'),
                  )
                ],
              );
            }
          }),
    );
  }
}
