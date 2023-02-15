import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/controller/settings_controller.dart';
import 'package:suwon_mate/styles/style_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class StudentInfoSettingWidget extends StatefulWidget {
  const StudentInfoSettingWidget({Key? key}) : super(key: key);

  @override
  State<StudentInfoSettingWidget> createState() =>
      _StudentInfoSettingWidgetState();
}

class _StudentInfoSettingWidgetState extends State<StudentInfoSettingWidget> {
  /// 현재 학부를 나타내는 변수이다.
  String _myDp = '컴퓨터학부';

  /// 현재 학과를 나타내는 변수이다.
  String _mySub = '전체';

  /// 현재 학년을 나타내는 변수이다.
  String _grade = '1학년';

  /// 학과 목록과 같이 추후 파싱이 필요할 시 한 번만 파싱을 수행하도록 도와주는 변수이다.
  bool _isFirst = true;

  /// 현재 가진 데이터가 동기화된 데이터인지 판단하는 변수이다.
  bool _isSynced = false;

  List<DropdownMenuItem<String>> subDropdownList = [];
  List<DropdownMenuItem<String>> majorDropdownList = [];
  final List<DropdownMenuItem<String>> gradeDropdownList = [
    const DropdownMenuItem(value: '1학년', child: Text('1학년')),
    const DropdownMenuItem(value: '2학년', child: Text('2학년')),
    const DropdownMenuItem(value: '3학년', child: Text('3학년')),
    const DropdownMenuItem(value: '4학년', child: Text('4학년')),
  ];
  late PackageInfo packageInfo;

  Widget noSyncWarning() {
    if (_isSynced) {
      return Container();
    }
    return const NotiCard(
        icon: Icons.warning_amber,
        color: Colors.amber,
        message: '아직 개설 강좌 조회를 들어가지 않은 경우 기본 전공을 지정할 수 있는 범위가 좁습니다.');
  }

  /// 현재 앱의 패키지 정보 및 설정 값을 가져오는 메서드이다.
  ///
  /// 현재 앱의 이름 및 버전등을 가져온 후 설정 저장소를 반환하는 메서드이다.
  /// 만일 패키지 정보를 가져오는데 실패한 경우 코드에 명시된 버전으로 지정된다.
  Future<SharedPreferences> getSettings() async {
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (_) {
      packageInfo = packageInfo = PackageInfo(
          appName: 'Suwon Mate',
          packageName: 'suwon_mate',
          version: '2.3.0',
          buildNumber: '16');
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getSettings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return InfoCard(
              icon: Icons.school_outlined,
              title: '학생 정보',
              detail: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    LinearProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('개설 강좌메뉴에서 기본으로 보여질 학부 및 학년을 선택합니다.'),
                    ),
                  ]));
        } else if (snapshot.hasError) {
          return DataLoadingError(errorMessage: snapshot.error);
        } else {
          majorDropdownList.clear();
          majorDropdownList.add(const DropdownMenuItem(
            value: '전체',
            child: Text('전체'),
          ));
          majorDropdownList.add(const DropdownMenuItem(
            value: '학부 공통',
            child: Text('학부 공통'),
          ));
          if ((snapshot.data as SharedPreferences).containsKey('dpMap')) {
            Map subMap = jsonDecode(
                (snapshot.data as SharedPreferences).getString('dpMap')!);
            subDropdownList = (subMap.keys.toList() as List<String>)
                .map((dat) => DropdownMenuItem(
                      value: dat,
                      child: Text(dat),
                    ))
                .toList();
            subDropdownList.sort((a, b) => a.value!.compareTo(b.value!));
            List tempList = subMap[_myDp] as List;
            tempList.sort((a, b) => a.compareTo(b));
            majorDropdownList.addAll((tempList)
                .map((dat) => DropdownMenuItem(
                      value: dat.toString(),
                      child: Text(dat.toString()),
                    ))
                .toList());
            _isSynced = true;
          }
          if (_isFirst) {
            _grade =
                (snapshot.data as SharedPreferences).getString('myGrade') ??
                    '1학년';
            _myDp = (snapshot.data as SharedPreferences).getString('myDept') ??
                '컴퓨터학부';
            _mySub =
                (snapshot.data as SharedPreferences).getString('mySubject') ??
                    '학부 공통';
            _isFirst = false;
          }
          return InfoCard(
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
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
              ));
        }
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('myDept', _myDp);
    pref.setString('mySubject', _mySub);
    pref.setString('myGrade', _grade);
  }
}

class FunctionSettingWidget extends ConsumerWidget {
  const FunctionSettingWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var functionSetting = ref.watch(functionSettingControllerNotifierProvider);
    if (ref
        .read(functionSettingControllerNotifierProvider.notifier)
        .isLoading) {
      return const InfoCard(
          icon: Icons.settings_outlined,
          title: '기능 설정',
          detail: Center(
            child: CircularProgressIndicator.adaptive(),
          ));
    } else {
      return InfoCard(
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
                                              Navigator.of(context).pop(),
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
                                padding: EdgeInsets.only(right: 10.0),
                                child: Icon(Icons.offline_bolt_outlined),
                              ),
                              Text('데이터 절약 모드'),
                            ],
                          )),
                    ),
                    Switch(
                        activeTrackColor: const Color.fromARGB(255, 0, 54, 112),
                        activeColor: const Color.fromARGB(200, 0, 54, 112),
                        value: functionSetting.offline,
                        onChanged: (newValue) {
                          if (kIsWeb) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('해당 플랫폼에서는 지원하지 않습니다.')));
                            return;
                          }
                          ref
                              .read(functionSettingControllerNotifierProvider
                                  .notifier)
                              .onOfflineSettingChanged(newValue);
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
                                              Navigator.of(context).pop(),
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
                                padding: EdgeInsets.only(right: 10.0),
                                child: Icon(Icons.search),
                              ),
                              Text('입력하여 바로 검색'),
                            ],
                          )),
                    ),
                    Switch(
                        activeTrackColor: const Color.fromARGB(255, 0, 54, 112),
                        activeColor: const Color.fromARGB(200, 0, 54, 112),
                        value: functionSetting.liveSearch,
                        onChanged: ref
                            .read(functionSettingControllerNotifierProvider
                                .notifier)
                            .onLiveSearchSettingChanged),
                  ],
                ),
              ),
              if (functionSetting.liveSearch)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text('슬라이더를 조절하여 자동으로 검색을 시작할 글자 수 지정'),
                      Slider(
                        divisions: 3,
                        label: '${functionSetting.liveSearchCount.round()} 자',
                        min: 0,
                        max: 3,
                        value: functionSetting.liveSearchCount,
                        onChanged: ref
                            .read(functionSettingControllerNotifierProvider
                                .notifier)
                            .onLiveSearchCountSettingChanged,
                      ),
                      Text(
                          '현재 설정된 글자 수: ${functionSetting.liveSearchCount.round()}자')
                    ],
                  ),
                )
            ],
          ));
    }
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          const StudentInfoSettingWidget(),
          const FunctionSettingWidget(),
          InfoCard(
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
                          builder: (BuildContext context) => SuwonDialog(
                              icon: Icons.error_outline,
                              title: '경고',
                              content: const Text(
                                  '학생 정보를 포함한 앱의 모든 데이터를 초기화합니다. 계속하시겠습니까?(이 작업은 되돌릴 수 없습니다.)'),
                              isDestructive: true,
                              onPressed: () {
                                SharedPreferences.getInstance()
                                    .then((value) => value.clear());
                                Navigator.of(context).pop();
                              }));
                    },
                    style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(
                            Colors.redAccent.withAlpha(30)),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.redAccent)),
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
                              content:
                                  const Text('DB의 데이터를 다시 받습니다. 계속하시겠습니까?'),
                              onPressed: () {
                                SharedPreferences.getInstance()
                                    .then((value) => value.remove('db_ver'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('DB 데이터를 지웠습니다.')));
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
          // debugWidget(),
          // versionInfo(snapshot),
          InfoCard(
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
                        const Padding(padding: EdgeInsets.only(right: 8.0)),
                        TextButton(
                            onPressed: (() async {
                              await launchUrlString(
                                  'mailto:orgsun30812+suwon_mate_github@gmail.com');
                            }),
                            child: const Text('이메일 보내기')),
                      ],
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  /// 학부가 포함되는 리스트이다. 나중에 실제 학부들이 이 변수에 추가된다.
  List<String> subList = ['컴퓨터학부', '경영학부'];

  /// 학과가 포함되는 리스트이다. 나중에 실제 학과들이 이 변수에 추가된다.
  List<String> majorList = ['학부 공통', '전체'];

  /// 학년 리스트이다. 학년을 기준으로 쿼리할 때 사용된다.
  List<String> gradeList = ['1학년', '2학년', '3학년', '4학년'];

  /// 현재 학부를 나타내는 변수이다.
  String _myDp = '컴퓨터학부';

  /// 현재 학과를 나타내는 변수이다.
  String _mySub = '전체';

  /// 현재 학년을 나타내는 변수이다.
  String _grade = '1학년';

  /// 학과 목록과 같이 추후 파싱이 필요할 시 한 번만 파싱을 수행하도록 도와주는 변수이다.
  bool _isFirst = true;

  /// 현재 가진 데이터가 동기화된 데이터인지 판단하는 변수이다.
  bool _isSynced = false;

  /// 해당 프로그램이 디버그 용으로 동작하는지에 대한 변수이다.
  final isDebug = true;

  /// 앱의 버전을 출력하기 위한 정보를 가진 변수이다.
  late PackageInfo packageInfo;

  /// 서버DB의 버전을 담고 있는 변수이다.
  late String serverVersion;
  List<DropdownMenuItem<String>> subDropdownList = [];
  List<DropdownMenuItem<String>> majorDropdownList = [];
  List<DropdownMenuItem<String>> gradeDropdownList = [];

  /// 기능 설정과 관련된 항목이다.
  Map<String, dynamic> functionSetting = {
    'offline': false,
    'liveSearch': true,
    'liveSearchCount': 0.0
  };

  /// 현재 앱의 패키지 정보 및 설정 값을 가져오는 메서드이다.
  ///
  /// 현재 앱의 이름 및 버전등을 가져온 후 설정 저장소를 반환하는 메서드이다.
  /// 만일 패키지 정보를 가져오는데 실패한 경우 코드에 명시된 버전으로 지정된다.
  Future<SharedPreferences> getSettings() async {
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (_) {
      packageInfo = packageInfo = PackageInfo(
          appName: 'Suwon Mate',
          packageName: 'suwon_mate',
          version: '2.3.0',
          buildNumber: '16');
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref;
  }

  /// 서버로부터 최신 앱 버전을 가져오는 메서드이다.
  ///
  /// Firebase에서 `app_ver`정보를 가져온다. 이를 통해 최근에 배포된 앱과 현재 설치된 앱의 버전의 차이를 보고
  /// 업데이트 여부를 판단할 수 있도록 도와준다.
  Future<DatabaseEvent> getVersionData() {
    DatabaseReference appVer = FirebaseDatabase.instance.ref('version');
    return appVer.child('app_ver').once();
  }

  @override
  void initState() {
    super.initState();
    subDropdownList = subList
        .map((dat) => DropdownMenuItem(
              value: dat,
              child: Text(dat),
            ))
        .toList();
    gradeDropdownList = gradeList
        .map((dat) => DropdownMenuItem(
              value: dat,
              child: Text(dat),
            ))
        .toList();
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('myDept', _myDp);
    pref.setString('mySubject', _mySub);
    pref.setString('myGrade', _grade);
    pref.setString('settings', jsonEncode(functionSetting));
  }

  /// 개설 강좌 조회를 아직 누르지 않은 경우 경고위젯을 띄우는 메서드
  /// 개설강좌 조회를 아직 누르지 않은 경우 학부 데이터를 받아오지 않았기 때문에 설정에서 고를 수 있는 학부 및 학과가 적다.
  /// 이를 알리기 위해 존재하는 위젯이다.
  Widget noSyncWarning() {
    if (_isSynced) {
      return Container();
    }
    return const NotiCard(
        icon: Icons.warning_amber,
        color: Colors.amber,
        message: '아직 개설 강좌 조회를 들어가지 않은 경우 기본 전공을 지정할 수 있는 범위가 좁습니다.');
  }

  /// [isDebug]가 `true`로 설정되어 있을 시 나타나는 위젯이다.
  ///
  /// 디버그에 용이한 설정을 앱 상에 나오도록 해주며 즐겨찾기 항목을 지운다던지 데이터를 초기화 한다던지의 작업을 수행할 수 있다.
  Widget debugWidget() {
    if (isDebug) {
      return InfoCard(
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
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.remove('favoritesMap');
                    List<String> list = ['06993-001'];
                    await pref.setStringList('favorite', list);
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
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
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                pref.remove('favoritesMap');
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
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
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                pref.remove('favoritesMap');
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (snapshot.hasError) {
              return DataLoadingError(
                errorMessage: snapshot.error,
              );
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
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          pref.remove('dp_set');
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
                value: '전체',
                child: Text('전체'),
              ));
              majorDropdownList.add(const DropdownMenuItem(
                value: '학부 공통',
                child: Text('학부 공통'),
              ));
              if ((snapshot.data as SharedPreferences).containsKey('dpMap')) {
                Map subMap = jsonDecode(
                    (snapshot.data as SharedPreferences).getString('dpMap')!);
                subDropdownList = (subMap.keys.toList() as List<String>)
                    .map((dat) => DropdownMenuItem(
                          value: dat,
                          child: Text(dat),
                        ))
                    .toList();
                subDropdownList.sort((a, b) => a.value!.compareTo(b.value!));
                List tempList = subMap[_myDp] as List;
                tempList.sort((a, b) => a.compareTo(b));
                majorDropdownList.addAll((tempList)
                    .map((dat) => DropdownMenuItem(
                          value: dat.toString(),
                          child: Text(dat.toString()),
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
                shrinkWrap: true,
                children: [
                  InfoCard(
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
                  InfoCard(
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
                  InfoCard(
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
                                            SharedPreferences pref =
                                                await SharedPreferences
                                                    .getInstance();
                                            pref.clear().then((value) =>
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            '앱의 모든 데이터를 초기화 하였습니다.'))));
                                            if (mounted) {
                                              Navigator.of(context).pop();
                                            }
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
                                        SharedPreferences pref =
                                            await SharedPreferences
                                                .getInstance();
                                        pref.remove('db_ver').then((value) =>
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'DB 데이터를 지웠습니다.'))));
                                        if (mounted) {
                                          Navigator.of(context).pop();
                                        }
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
                  InfoCard(
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
                                    onPressed: (() async {
                                      await launchUrlString(
                                          'mailto:orgsun30812+suwon_mate_github@gmail.com');
                                    }),
                                    child: const Text('이메일 보내기')),
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

  /// 현재 앱 버전과 서버상에 명시된 최신 버전을 비교해서 차이날 시 알려주는 메서드이다.
  ///
  /// 현재 앱 버전보다 서버상에 명시된 앱 버전이 높은 경우 앱 업데이트를 권장하는 위젯을 띄우는 위젯이다.
  /// [updated]을 통해 설치된 앱 버전과 최신 버전을 비교한 결과를 받아서 최신 버전인 경우 초록색 완료 마크를
  /// 표시하고, 업데이트가 필요할 시 업데이트 아이콘을 파란색으로 띄운다. 또한 업데이트된 앱을 받을 수 있는 링크로 안내한다.
  Widget updater(bool updated) {
    if (updated) {
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

  /// 로컬 DB버전 및 앱 버전 정보를 출력하는 위젯이다.
  ///
  /// DB버전 정보를 [snapshot]으로부터 가져와서 DB버전을 출력해주고, 앱 버전도 출력해주는 위젯이다.
  /// Web 버전의 경우 항상 최신으로 유지되므로 항상 최신으로 유지된다는 위젯을 출력한다.
  Widget versionInfo(AsyncSnapshot<dynamic> snapshot) {
    if (kIsWeb) {
      return InfoCard(
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
    return FutureBuilder(
        future: getVersionData(),
        builder: (context, versionSnapshot) {
          if (!versionSnapshot.hasData) {
            return const InfoCard(
              icon: Icons.info_outline,
              title: '버전 정보',
              detail: Center(child: CircularProgressIndicator.adaptive()),
            );
          } else if (versionSnapshot.hasError) {
            return InfoCard(
              icon: Icons.info_outline,
              title: '버전 정보',
              detail: Text(
                  '로컬 DB 버전: ${(snapshot.data as SharedPreferences).getString('db_ver') ?? '다운로드 필요'}\n'
                  '로컬 앱 버전: ${packageInfo.version}\n'
                  '최신 앱 버전: 정보를 가져오는데 오류가 발생했습니다.'),
            );
          } else {
            return InfoCard(
              icon: Icons.info_outline,
              title: '버전 정보',
              detail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  updater(int.parse(((versionSnapshot.data as DatabaseEvent)
                              .snapshot
                              .value as String)
                          .replaceAll('.', '')) <=
                      int.parse(packageInfo.version.replaceAll('.', ''))),
                  if ((versionSnapshot.data as DatabaseEvent).snapshot.value !=
                      packageInfo.version)
                    Text(
                        '최신 앱 버전: ${(versionSnapshot.data as DatabaseEvent).snapshot.value ?? '알 수 없음'}'),
                  Text('로컬 앱 버전: ${packageInfo.version}\n'
                      '로컬 DB 버전: ${(snapshot.data as SharedPreferences).getString('db_ver') ?? '다운로드 필요'}')
                ],
              ),
            );
          }
        });
  }

  /// 업데이트 필요 시 나타나는 버튼이다.
  ///
  /// 해당 버튼을 누르면 최신 앱을 받을 수 있는 프로젝트 저장소의 release탭으로 이동한다.
  Widget downloadUpdate() {
    return TextButton(
        onPressed: (() async => await launchUrlString(
            'https://github.com/sun30812/suwon_mate/releases')),
        child: const Text('업데이트 확인 및 다운받기(사이트 이동)'));
  }
}
