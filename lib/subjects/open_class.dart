import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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

  /// 학부 목록([DropdownMenuEntry]용)
  List<DropdownMenuEntry<String>> departmentDropdownList = [];

  /// 학과 목록([DropdownMenuEntry]용)
  List<DropdownMenuEntry<String>> subjectDropdownList = [];

  /// 학년 목록([DropdownMenuEntry]용)
  List<DropdownMenuEntry<String>> gradeDownList = const [
    DropdownMenuEntry(value: '1학년', label: '1학년'),
    DropdownMenuEntry(value: '2학년', label: '2학년'),
    DropdownMenuEntry(value: '3학년', label: '3학년'),
    DropdownMenuEntry(value: '4학년', label: '4학년'),
  ];

  /// 교양 영역 목록([DropdownMenuEntry]용)
  List<DropdownMenuEntry<String>> regionList = const [
    DropdownMenuEntry(
      value: '전체',
      label: '전체',
    ),
    DropdownMenuEntry(
      value: '언어와 소통',
      label: '1영역',
    ),
    DropdownMenuEntry(
      value: '세계와 문명',
      label: '2영역',
    ),
    DropdownMenuEntry(
      value: '역사와 사회',
      label: '3영역',
    ),
    DropdownMenuEntry(
      value: '문화와 철학',
      label: '4영역',
    ),
    DropdownMenuEntry(
      value: '기술과 정보',
      label: '5영역',
    ),
    DropdownMenuEntry(
      value: '건강과 예술',
      label: '6영역',
    ),
    DropdownMenuEntry(
      value: '자연과 과학',
      label: '7영역',
    )
  ];
  Map allClassList = {};
  String _region = '전체';
  var getDepartment = FirebaseDatabase.instance.ref('departments').once();

  /// 과목에 대한 정보를 FirebaseDatabase로부터 가져오는 메서드이다.
  Stream<DatabaseEvent> getData() {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref(widget.quickMode ? 'estbLectDtaiList_quick' : 'estbLectDtaiList');
    if (_myDept == '교양') {
      return ref
          .child(_myDept)
          .orderByChild('cltTerrNm')
          .equalTo(_region)
          .onValue;
    }
    return ref
        .child(_myDept)
        .orderByChild('estbMjorNm')
        .equalTo(_myMajor != '학부 공통' ? _myMajor : null)
        .onValue;
  }

  /// 어떤 영역인지 고르는 [DropdownButton]이다.
  ///
  /// [dept]가 교양인 경우 영역을 고를 수 있는 [DropdownButton]이 나타나고, 아닌경우 나타나지 않는다.
  Widget regionSelector(String dept) {
    if (dept == '교양') {
      return DropdownMenu(
          dropdownMenuEntries: regionList,
          label: const Text('교양 영역'),
          inputDecorationTheme: const InputDecorationTheme(filled: true),
          onSelected: (String? value) {
            setState(() {
              _region = value!;
            });
          },
          initialSelection: _region);
    }
    return Container();
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('dp_set');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text(widget.quickMode ? '빠른 개설 강좌 조회' : '개설 강좌 조회')),
        floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.search),
            label: const Text('검색'),
            onPressed: () {
              context.push('/oclass/search');
            }),
        body: Column(
          children: [
            FutureBuilder<DatabaseEvent>(
                future: getDepartment,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  } else if (snapshot.hasError) {
                    return DataLoadingError(errorMessage: snapshot.error);
                  } else {
                    var data = snapshot.data?.snapshot.value as Map;
                    departmentDropdownList.clear();
                    departmentDropdownList
                        .add(const DropdownMenuEntry(value: '교양', label: '교양'));
                    for (var department in data.keys) {
                      departmentDropdownList.add(DropdownMenuEntry(
                          value: department.toString(),
                          label: department.toString()));
                      subjectDropdownList.clear();
                      subjectDropdownList.add(const DropdownMenuEntry(
                          value: '학부 공통', label: '학부 공통'));
                    }
                    if (_myDept != '교양') {
                      for (String major in data[_myDept]) {
                        subjectDropdownList
                            .add(DropdownMenuEntry(value: major, label: major));
                      }
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownMenu(
                              initialSelection: _myDept,
                              label: const Text('학부'),
                              inputDecorationTheme: const InputDecorationTheme(
                                filled: true,
                              ),
                              dropdownMenuEntries: departmentDropdownList,
                              onSelected: (String? value) {
                                setState(() {
                                  _myDept = value!;
                                  subjectDropdownList.clear();
                                  subjectDropdownList.add(
                                      const DropdownMenuEntry(
                                          value: '학부 공통', label: '학부 공통'));
                                  _myMajor = '학부 공통';
                                  if (_myDept == '교양') {
                                    return;
                                  }
                                  for (String major in data[_myDept]) {
                                    subjectDropdownList.add(DropdownMenuEntry(
                                        value: major, label: major));
                                  }
                                });
                              },
                            ),
                          ),
                          if (_myDept != '교양') ...[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownMenu(
                                initialSelection: _myMajor,
                                width: 202.0,
                                label: const Text('학과'),
                                inputDecorationTheme:
                                    const InputDecorationTheme(
                                  filled: true,
                                ),
                                dropdownMenuEntries: subjectDropdownList,
                                onSelected: (String? value) => setState(() {
                                  _myMajor = value!;
                                }),
                              ),
                            ),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownMenu(
                                  dropdownMenuEntries: regionList,
                                  label: const Text('교양 영역'),
                                  inputDecorationTheme:
                                      const InputDecorationTheme(filled: true),
                                  onSelected: (String? value) {
                                    setState(() {
                                      _region = value!;
                                    });
                                  },
                                  initialSelection: _region),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownMenu(
                              initialSelection: _myGrade,
                              label: const Text('학년'),
                              inputDecorationTheme: const InputDecorationTheme(
                                filled: true,
                              ),
                              dropdownMenuEntries: gradeDownList,
                              onSelected: (String? value) {
                                setState(() {
                                  _myGrade = value!;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    );
                  }
                }),
            StreamBuilder<DatabaseEvent>(
              stream: getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                } else if (snapshot.hasError) {
                  return DataLoadingError(errorMessage: snapshot.error);
                } else if (snapshot.hasData) {
                  var value = snapshot.data?.snapshot.value;
                  if (value == null) {
                    return Container();
                  }
                  var list = ClassInfo.fromFirebaseDatabase(value);
                  list.removeWhere(
                      (classInfo) => '${classInfo.guestGrade}학년' != _myGrade);
                  return Flexible(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return SimpleCard(
                          onPressed: () =>
                              context.push('/oclass/info', extra: list[index]),
                          title: list[index].name,
                          subTitle: list[index].hostName ?? '이름 공개 안됨',
                          content: Text(
                              '${list[index].guestMjor ?? '학부 전체 대상'}, ${list[index].subjectKind ?? '공개 안됨'} ,${list[index].classLocation ?? '공개 안됨'}'),
                        );
                      },
                    ),
                  );
                } else {
                  return Container();
                }
              },
            )
          ],
        ));
  }
}
