import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/style_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final isDebug = false;
  late PackageInfo packageInfo;
  late String serverVersion;
  List<DropdownMenuItem<String>> subDropdownList = [];
  List<DropdownMenuItem<String>> gradeDropdownList = [];
  Map<String, dynamic> functionSetting = {'offline': false};

  Future<SharedPreferences> getSettings() async {
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (_) {
      packageInfo = packageInfo = PackageInfo(
          appName: 'Suwon Mate',
          packageName: 'suwon_mate',
          version: '1.3.5',
          buildNumber: '1');
    }
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref;
  }

  Future getVersionData() async {
    DatabaseReference appVer = FirebaseDatabase.instance.ref('version');
    Map versionInfo = (await appVer.once()).snapshot.value as Map;
    return versionInfo['app_ver'];
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
                      title: '학생 정보',
                      detail: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('개설 강좌메뉴에서 기본으로 보여질 전공과 학년을 선택합니다.'),
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
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
                                      ScaffoldMessenger.of(context).showMaterialBanner(
                                        MaterialBanner(content: Row(
                                          children: const [
                                            Icon(Icons.warning_amber_rounded),
                                            Text('앱을 재시작 해야 변경사항이 적용됩니다.')
                                          ],
                                        ), actions:  [
                                          TextButton(style: ButtonStyle(
                                              overlayColor: MaterialStateProperty.all(
                                                  Colors.redAccent.withAlpha(30)),
                                            foregroundColor: MaterialStateProperty.all(Colors.redAccent)
                                          ),onPressed: (()  {
                                            dispose();
                                            SystemNavigator.pop(animated: true);
                                          }), child: const Text('앱 종료')),
                                          TextButton(onPressed: (()  {
                                            ScaffoldMessenger.of(context).clearMaterialBanners();
                                          }), child: const Text('메세지 닫기')),
                                        ])
                                      );
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
                                        _pref.remove('db_ver');
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

  Widget updater(bool equalVersion) {
    if (equalVersion) {
      return Container();
    } else {
      return Column(
        children: [
          Row(
            children: const [
              Icon(Icons.system_update_alt),
              Padding(padding: EdgeInsets.only(right: 10.0)),
              Text(
                '업데이트 사용가능',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          downloadUpdate(),
        ],
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
    } else if (Platform.isWindows || Platform.isLinux) {
      return CardInfo(
        icon: Icons.info_outline,
        title: '버전 정보',
        detail: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '로컬 DB 버전: ${(snapshot.data as SharedPreferences).getString('db_ver') ?? '다운로드 필요'}\n'
                '로컬 앱 버전: ${packageInfo.version}\n'
                '최신 앱 버전: 해당 플랫폼에서 확인 불가'),
            downloadUpdate()
          ],
        ),
      );
    }
    return FutureBuilder(
        future: getVersionData(),
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
                  updater(_snapshot.data == packageInfo.version),
                  Text(
                      '로컬 DB 버전: ${(snapshot.data as SharedPreferences).getString('db_ver') ?? '다운로드 필요'}\n'
                      '로컬 앱 버전: ${packageInfo.version}\n'
                      '최신 앱 버전: ${_snapshot.data}'),
                ],
              ),
            );
          }
        });
  }

  Widget downloadUpdate() {
    return TextButton(
        onPressed: (() async {
          await launch('https://github.com/sun30812/suwon_mate/releases');
        }),
        child: const Text('업데이트 확인 및 다운받기(사이트 이동)'));
  }
}
