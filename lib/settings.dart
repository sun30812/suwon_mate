import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/styles/style_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
    'liveSearchCount': 0.0,
    'bottomBanner': true,
  };

  /// 현재 앱의 패키지 정보 및 설정 값을 가져오는 메서드이다.
  ///
  /// 현재 앱의 이름 및 버전등을 가져온 후 설정 저장소를 반환하는 메서드이다.
  /// 만일 패키지 정보를 가져오는데 실패한 경우 코드에 명시된 버전으로 지정된다.
  Future<SharedPreferences> getSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();
    return pref;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                _mySub = '전체';
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.warning_amber_outlined),
                      Text(
                          '일부 구조 개선으로 인해 데이터 갱신이 필요합니다.\n메인에서 개설 강좌 조회 메뉴에 접속해주세요.'),
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
                      icon: Icons.favorite_outline,
                      title: '광고 설정',
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
                                              title: Text('하단 배너에 광고 표시'),
                                              content: Text(
                                                  '개설강좌 목록에 들어가면 하단에 배너를 표시합니다.'),
                                            );
                                          });
                                    },
                                    child: Row(
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.only(right: 10.0),
                                          child: Icon(Icons
                                              .vertical_align_bottom_rounded),
                                        ),
                                        Text('하단 배너에 광고 표시'),
                                      ],
                                    )),
                                Switch(
                                    activeTrackColor:
                                        const Color.fromARGB(255, 0, 54, 112),
                                    activeColor:
                                        const Color.fromARGB(200, 0, 54, 112),
                                    value:
                                        functionSetting['bottomBanner'] ?? true,
                                    onChanged: (newValue) {
                                      setState(() {
                                        functionSetting['bottomBanner'] =
                                            newValue;
                                      });
                                    }),
                              ],
                            ),
                          ),
                        ],
                      )),
                  InfoCard(
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
                  InfoCard(
                    icon: Icons.info_outline,
                    title: '버전 정보',
                    detail: Text(
                        '로컬 DB 버전: ${(snapshot.data as SharedPreferences).getString('db_ver') ?? '다운로드 필요'}\n'
                        '로컬 앱 버전: ${packageInfo.version}'),
                  ),
                  InfoCard(
                      icon: Icons.help_outline,
                      title: '문의하기',
                      detail: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              '문제가 있는 부분이나 기능 제안은 이메일로 보내시면 신속한 처리가 가능합니다.'),
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
                                          'mailto:orgsun30812+suwon_mate@gmail.com');
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

  Text advertiseLevelText() {
    switch ((functionSetting['advertiseLevel'] ?? 1.0).round()) {
      case 1:
        return const Text('1단계: 광고 보기 페이지에서만 배너광고가 나타납니다.');
      case 2:
        return const Text('2단계: 메인화면에서만 배너광고가 나타납니다.');
      case 3:
        return const Text('3단계: 모든 화면에서 배너 광고가 나타납니다.');
      default:
        return const Text('오류: 지정되지 않은 배너 광고입니다.');
    }
  }
}
