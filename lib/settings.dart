import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
                      color: Theme.of(context).colorScheme.surfaceVariant,
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
                      color: Theme.of(context).colorScheme.surfaceVariant,
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
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: true,
      ),
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
                              icon: Icons.restart_alt_outlined,
                              title: '전체 데이터를 초기화 할까요?',
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
                              icon: Icons.restart_alt_outlined,
                              title: 'DB 데이터를 다시 받을까요?',
                              content:
                                  const Text('서버에서 최신 DB의 데이터를 다시 받습니다. 계속하시겠습니까?'),
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
