import 'package:firebase_database/firebase_database.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/model/class_info.dart';
import 'package:suwon_mate/styles/style_widget.dart';

/// 개설 강좌 조회 시 페이지이다.
///
/// Firebase의 RealtimeDatabase를 통해 강좌 목록에 관한 데이터를 가져와서 화면에 카드 형태로 나타내는
/// 페이지이다.
class FluentOpenClass extends StatefulWidget {
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
  const FluentOpenClass(
      {required this.settingsData,
      required this.myDept,
      required this.myMajor,
      required this.myGrade,
      required this.quickMode,
      Key? key})
      : super(key: key);

  @override
  State<FluentOpenClass> createState() => _FluentOpenClassState();
}

class _FluentOpenClassState extends State<FluentOpenClass> {
  late String _myDept = widget.myDept;
  late String _myMajor = widget.myMajor;
  late String _myGrade = widget.myGrade;

  /// 학부 목록([ComboBoxItem]용)
  List<ComboBoxItem<String>> departmentDropdownList = [];

  /// 학과 목록([ComboBoxItem]용)
  List<ComboBoxItem<String>> subjectDropdownList = [];

  /// 학년 목록([ComboBoxItem]용)
  List<ComboBoxItem<String>> gradeDownList = const [
    ComboBoxItem(value: '1학년', child: Text('1학년')),
    ComboBoxItem(value: '2학년', child: Text('2학년')),
    ComboBoxItem(value: '3학년', child: Text('3학년')),
    ComboBoxItem(value: '4학년', child: Text('4학년')),
  ];

  /// 교양 영역 목록([ComboBoxItem]용)
  List<ComboBoxItem<String>> regionList = const [
    ComboBoxItem(
      value: '전체',
      child: Text('전체'),
    ),
    ComboBoxItem(
      value: '언어와 소통',
      child: Text('1영역'),
    ),
    ComboBoxItem(
      value: '세계와 문명',
      child: Text('2영역'),
    ),
    ComboBoxItem(
      value: '역사와 사회',
      child: Text('3영역'),
    ),
    ComboBoxItem(
      value: '문화와 철학',
      child: Text('4영역'),
    ),
    ComboBoxItem(
      value: '기술과 정보',
      child: Text('5영역'),
    ),
    ComboBoxItem(
      value: '건강과 예술',
      child: Text('6영역'),
    ),
    ComboBoxItem(
      value: '자연과 과학',
      child: Text('7영역'),
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
      if (_region == '전체') {
        return ref.child(_myDept).onValue;
      } else {
        return ref
            .child(_myDept)
            .orderByChild('cltTerrNm')
            .equalTo(_region)
            .onValue;
      }
    }
    return ref
        .child(_myDept)
        .orderByChild('estbMjorNm')
        .equalTo(_myMajor != '학부 공통' ? _myMajor : null)
        .onValue;
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('dp_set');
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
        header: PageHeader(
          title: Text(widget.quickMode ? '빠른 개설 강좌 조회' : '개설 강좌 조회'),
          commandBar: CommandBar(
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.search),
                label: const Text('검색'),
                onPressed: () => context.push('/oclass/search'),
              )
            ],
          ),
        ),
        content: Column(
          children: [
            FutureBuilder<DatabaseEvent>(
                future: getDepartment,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ProgressBar();
                  } else if (snapshot.hasError) {
                    return DataLoadingError(errorMessage: snapshot.error);
                  } else {
                    var data = snapshot.data?.snapshot.value as Map;
                    departmentDropdownList.clear();
                    departmentDropdownList.add(
                        const ComboBoxItem(value: '교양', child: Text('교양')));
                    for (var department in data.keys) {
                      departmentDropdownList.add(ComboBoxItem(
                          value: department.toString(),
                          child: Text(department.toString())));
                      subjectDropdownList.clear();
                      subjectDropdownList.add(const ComboBoxItem(
                          value: '학부 공통', child: Text('학부 공통')));
                    }
                    if (_myDept != '교양') {
                      for (String major in data[_myDept]) {
                        subjectDropdownList.add(
                            ComboBoxItem(value: major, child: Text(major)));
                      }
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ComboBox(
                              value: _myDept,
                              items: departmentDropdownList,
                              onChanged: (String? value) {
                                setState(() {
                                  _myDept = value!;
                                  subjectDropdownList.clear();
                                  subjectDropdownList.add(const ComboBoxItem(
                                      value: '학부 공통', child: Text('학부 공통')));
                                  _myMajor = '학부 공통';
                                  if (_myDept == '교양') {
                                    return;
                                  }
                                  for (String major in data[_myDept]) {
                                    subjectDropdownList.add(ComboBoxItem(
                                        value: major, child: Text(major)));
                                  }
                                });
                              },
                            ),
                          ),
                          if (_myDept != '교양') ...[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ComboBox(
                                value: _myMajor,
                                items: subjectDropdownList,
                                onChanged: (String? value) => setState(() {
                                  _myMajor = value!;
                                }),
                              ),
                            ),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ComboBox(
                                  items: regionList,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _region = value!;
                                    });
                                  },
                                  value: _region),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ComboBox(
                              value: _myGrade,
                              items: gradeDownList,
                              onChanged: (String? value) {
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
                  return const ProgressBar();
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
                      itemBuilder: (listContext, index) {
                        return SimpleCard(
                          onPressed: () => listContext.push('/oclass/info',
                              extra: list[index]),
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
