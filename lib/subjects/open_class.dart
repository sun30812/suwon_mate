import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/model/class_info.dart';
import 'package:suwon_mate/styles/style_widget.dart';

/// 개설 강좌 조회 시 페이지이다.
///
/// Firebase의 RealtimeDatabase를 통해 강좌 목록에 관한 데이터를 가져와서 화면에 카드 형태로 나타내는
/// 페이지이다.
class OpenClass extends StatefulWidget {
  /// 본인의 학부를 나타내는 변수
  final String myDept;

  /// 본인의 전공을 나타내는 변수
  final String myMajor;

  /// 본인의 학년을 나타내는 변수
  final String myGrade;

  /// 설정 값에 대한 정보가 담긴 변수
  final Map<String, dynamic> settingsData;

  /// 빠른 개설 강좌 조회 기능 여부를 확인하는 변수
  final bool quickMode;

  /// 개설 강좌 조회 시 페이지이다.
  ///
  /// [myDept]에는 사용자의 학부가 들어가고, [myMajor]에는 사용자의 학과가 들어가야 한다.
  /// 학년은 [myGrade]를 통해 전달되며 사용자의 개인 설정을 전달하기 위해 [settingsData]를 이용한다.
  const OpenClass(
      {required this.settingsData,
      required this.myDept,
      required this.myMajor,
      required this.myGrade,
      required this.quickMode,
      Key? key})
      : super(key: key);

  @override
  State<OpenClass> createState() => _OpenClassState();
}

class _OpenClassState extends State<OpenClass> {
  late String _myDept = widget.myDept;
  late String _myMajor = widget.myMajor;
  late String _myGrade = widget.myGrade;

  /// 학년 목록
  List<String> gradeList = ['1학년', '2학년', '3학년', '4학년'];

  /// 학부 목록([DropdownMenuItem]용)
  List<DropdownMenuItem<String>> dpDropdownList = [];

  /// 학과 목록([DropdownMenuItem]용)
  List<DropdownMenuItem<String>> subjectDropdownList = [];

  /// 학년 목록([DropdownMenuItem]용)
  List<DropdownMenuItem<String>> gradeDownList = [];

  /// 교양 영역 목록([DropdownMenuItem]용)
  List<DropdownMenuItem<String>> regionList = const [
    DropdownMenuItem(
      value: '전체',
      child: Text('전체'),
    ),
    DropdownMenuItem(
      value: '언어와 소통',
      child: Text('1영역'),
    ),
    DropdownMenuItem(
      value: '세계와 문명',
      child: Text('2영역'),
    ),
    DropdownMenuItem(
      value: '역사와 사회',
      child: Text('3영역'),
    ),
    DropdownMenuItem(
      value: '문화와 철학',
      child: Text('4영역'),
    ),
    DropdownMenuItem(
      value: '기술과 정보',
      child: Text('5영역'),
    ),
    DropdownMenuItem(
      value: '건강과 예술',
      child: Text('6영역'),
    ),
    DropdownMenuItem(
      value: '자연과 과학',
      child: Text('7영역'),
    )
  ];
  Map allClassList = {};
  String _region = '전체';
  Set<String> dpSet = {};
  Map<String, List> dpMap = {};
  Map subjects = {};
  bool _isFirstDp = true;

  /// DB버전을 [SharedPreferences]에 저장하고 과목에 대한 정보를 FirebaseDatabase로부터 가져오는 메서드이다.
  Future getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    DatabaseReference version = FirebaseDatabase.instance.ref('version');
    Map versionInfo = (await version.once()).snapshot.value as Map;
    DatabaseReference ref = FirebaseDatabase.instance
        .ref(widget.quickMode ? 'estbLectDtaiList_quick' : 'estbLectDtaiList');

    pref.setString('db_ver', versionInfo["db_ver"]);
    return ref.once();
  }

  /// 어떤 영역인지 고르는 [DropdownButton]이다.
  ///
  /// [dept]가 교양인 경우 영역을 고를 수 있는 [DropdownButton]이 나타나고, 아닌경우 나타나지 않는다.
  Widget regionSelector(String dept) {
    if (dept == '교양') {
      return DropdownButton(
          items: regionList,
          onChanged: (String? value) {
            setState(() {
              _region = value!;
            });
          },
          value: _region);
    }
    return Container();
  }

  @override
  void initState() {
    super.initState();
    for (var dat in gradeList) {
      gradeDownList.add(DropdownMenuItem(
        value: dat,
        child: Text(dat),
      ));
    }
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('dp_set');
    if (!widget.quickMode) {
      pref.setString('subjects', jsonEncode(subjects));
      pref.setString('dpMap', jsonEncode(dpMap));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: Text(widget.quickMode ? '빠른 개설 강좌 조회' : '개설 강좌 조회')),
        floatingActionButton: SuwonButton(
            isActivate: true,
            icon: Icons.search,
            buttonName: '검색',
            onPressed: () {
              List<ClassInfo> classList = [];
              for (List data in allClassList.values) {
                classList.addAll(ClassInfo.fromFirebaseDatabase(data));
              }
              context.push('/oclass/search',
                  extra: [classList, widget.settingsData]);
            }),
        body: FutureBuilder(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Center(child: CircularProgressIndicator.adaptive()),
                  Text('DB 버전 확인 및 갱신 중')
                ],
              );
            } else if (snapshot.hasError) {
              return DataLoadingError(
                errorMessage: snapshot.error,
              );
            } else {
              DatabaseEvent event = snapshot.data;
              allClassList = event.snapshot.value as Map;
              List<ClassInfo> classList = [];
              Set tempSet = {};
              dpSet = {};

              for (var department in allClassList.keys) {
                Set subSet = {};
                for (var dat2 in ClassInfo.fromFirebaseDatabase(
                    allClassList[department])) {
                  if (dat2.guestMjor != null) {
                    subSet.add(dat2.guestMjor);
                  }
                }
                dpMap[department.toString()] = subSet.toList();
              }
              for (var department in allClassList.keys) {
                if ((department != '교양') && (department != '교양(야)')) {
                  dpSet.add(department.toString());
                }
              }
              for (var dat
                  in ClassInfo.fromFirebaseDatabase(allClassList[_myDept])) {
                if (dat.guestMjor != null) {
                  tempSet.add(dat.guestMjor);
                }
              }
              if (_isFirstDp) {
                List<String> tempList0 = [];
                dpDropdownList.add(const DropdownMenuItem(
                  value: '교양',
                  child: Text('교양'),
                ));
                dpDropdownList.add(const DropdownMenuItem(
                  value: '교양(야)',
                  child: Text('교양(야)'),
                ));
                for (String depart in dpSet) {
                  tempList0.add(depart);
                }
                tempList0.sort((a, b) => a.compareTo(b));
                for (String depart in tempList0) {
                  dpDropdownList.add(DropdownMenuItem(
                    value: depart,
                    child: Text(depart),
                  ));
                }

                _isFirstDp = false;
              }
              List tempList = [];
              subjectDropdownList.clear();
              subjectDropdownList.add(const DropdownMenuItem(
                value: '전체',
                child: Text('전체'),
              ));
              subjectDropdownList.add(const DropdownMenuItem(
                value: '학부 공통',
                child: Text('학부 공통'),
              ));
              for (String subject in tempSet) {
                tempList.add(subject);
              }
              tempList.sort((a, b) => a.compareTo(b));
              for (String subject in tempList) {
                subjectDropdownList.add(DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                ));
              }
              for (var classData
                  in ClassInfo.fromFirebaseDatabase(allClassList[_myDept])) {
                if (_myDept == '교양') {
                  if (('${classData.guestGrade}학년' == _myGrade) &&
                      ((_region == '전체' ||
                          _region == (classData.region ?? 'none')))) {
                    classList.add(classData);
                  }
                } else if (_myMajor == '학부 공통') {
                  if ((classData.guestMjor == null) &&
                      (('${classData.guestGrade}학년') == _myGrade)) {
                    classList.add(classData);
                  }
                } else if ((_myMajor == '전체' ||
                        (classData.guestMjor == _myMajor)) &&
                    (('${classData.guestGrade}학년') == _myGrade)) {
                  classList.add(classData);
                }
              }
              classList.sort((a, b) => (a.name.compareTo(b.name)));
              return Column(
                children: [
                  if (widget.quickMode)
                    const NotiCard(
                        icon: Icons.info_outline,
                        message: '학과 분류가 되어있지 않기 때문에 학과가 학부 목록에 같이 표시됩니다.'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: regionSelector(_myDept),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton(
                            items: dpDropdownList,
                            onChanged: (String? value) {
                              setState(() {
                                _myDept = value!;
                                _myMajor = '학부 공통';
                              });
                            },
                            value: _myDept,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton(
                            items: subjectDropdownList,
                            onChanged: (String? value) {
                              setState(() {
                                _myMajor = value!;
                              });
                            },
                            value: _myMajor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton(
                            items: gradeDownList,
                            onChanged: (String? value) {
                              setState(() {
                                _myGrade = value!;
                              });
                            },
                            value: _myGrade,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                        itemCount: classList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SimpleCard(
                            onPressed: () => context.push('/oclass/info',
                                extra: classList[index]),
                            title: classList[index].name,
                            subTitle: classList[index].hostName ?? "이름 공개 안됨",
                            content: Text(
                                '${classList[index].guestMjor ?? '학부 전체 대상'}, ${classList[index].subjectKind ?? '공개 안됨'} ,${classList[index].classLocation ?? '공개 안됨'}'),
                          );
                        }),
                  ),
                ],
              );
            }
          },
        ));
  }
}
