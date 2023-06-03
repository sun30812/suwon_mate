import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/api/keys.dart';
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

  /// 학부 목록([DropdownMenuItem]용)
  List<DropdownMenuItem<String>> departmentDropdownList = [];

  /// 학과 목록([DropdownMenuItem]용)
  List<DropdownMenuItem<String>> subjectDropdownList = [];

  /// 학년 목록([DropdownMenuItem]용)
  List<DropdownMenuItem<String>> gradeDownList = const [
    DropdownMenuItem(value: '1학년', child: Text('1학년')),
    DropdownMenuItem(value: '2학년', child: Text('2학년')),
    DropdownMenuItem(value: '3학년', child: Text('3학년')),
    DropdownMenuItem(value: '4학년', child: Text('4학년')),
  ];

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
  var getDepartment = FirebaseDatabase.instance.ref('departments').once();
  BannerAd? _bannerAd;
  bool _loadBanner = false;

  /// 개설 강좌 조회에서 하단 배너에 광고를 생성하는 메서드이다.
  ///
  /// 앱 내 설정의 하단 배너 광고표시 여부에 따라 광고를 표시하는 메서드로
  /// 사용자 기기의 화면 크기를 계산하여 거기에 맞는 크기의 광고를 제공한다.
  /// 만일 광고가 어떠한 문제로 인해 송출되지 않는 경우이거나 사용자가 광고표시를 설정에서 활성화 하지 않은 경우
  /// 광고는 나타나지 않는다.
  Future<void> _createBanner(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map settingData = jsonDecode(pref.getString('settings') ?? '{}') as Map;
    final bottomBannerAd = settingData['bottomBanner'] ?? true;
    if (!bottomBannerAd) {
      return;
    }
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
            Orientation.portrait, MediaQuery.of(context).size.width.truncate());
    if (size == null) {
      return;
    }
    final BannerAd bannerAd = BannerAd(
        size: size,
        adUnitId: oclassAdUintId,
        listener: BannerAdListener(
            onAdLoaded: (ad) => setState(() {
                  _bannerAd = ad as BannerAd?;
                }),
            onAdFailedToLoad: (ad, _) => ad.dispose()),
        request: const AdRequest());
    return bannerAd.load();
  }

  /// 과목에 대한 정보를 FirebaseDatabase로부터 가져오는 메서드이다.
  Stream<DatabaseEvent> getData() {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref(widget.quickMode ? 'estbLectDtaiList_quick' : 'estbLectDtaiList');
    if (_myDept == '교양') {
      if (_region == '전체') {
        return ref
            .child(_myDept)
            .onValue;
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

    pref.setString('db_ver', versionInfo["db_ver"]);
    return ref.once();
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
    _bannerAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadBanner) {
      _createBanner(context);
      _loadBanner = true;
    }
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
                    departmentDropdownList.add(
                        const DropdownMenuItem(value: '교양', child: Text('교양')));
                    for (var department in data.keys) {
                      departmentDropdownList.add(DropdownMenuItem(
                          value: department.toString(),
                          child: Text(department.toString())));
                      subjectDropdownList.clear();
                      subjectDropdownList.add(const DropdownMenuItem(
                          value: '학부 공통', child: Text('학부 공통')));
                    }
                    if (_myDept != '교양') {
                      for (String major in data[_myDept]) {
                        subjectDropdownList.add(
                            DropdownMenuItem(value: major, child: Text(major)));
                      }
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton(
                              borderRadius: BorderRadius.circular(12.0),
                              underline: Container(),
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_outlined),
                              value: _myDept,
                              items: departmentDropdownList,
                              onChanged: (String? value) {
                                setState(() {
                                  _myDept = value!;
                                  subjectDropdownList.clear();
                                  subjectDropdownList.add(
                                      const DropdownMenuItem(
                                          value: '학부 공통',
                                          child: Text('학부 공통')));
                                  _myMajor = '학부 공통';
                                  if (_myDept == '교양') {
                                    return;
                                  }
                                  for (String major in data[_myDept]) {
                                    subjectDropdownList.add(DropdownMenuItem(
                                        value: major, child: Text(major)));
                                  }
                                });
                              },
                            ),
                          ),
                          if (_myDept != '교양') ...[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownButton(
                                borderRadius: BorderRadius.circular(12.0),
                                underline: Container(),
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_outlined),
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
                              child: DropdownButton(
                                  borderRadius: BorderRadius.circular(12.0),
                                  underline: Container(),
                                  icon: const Icon(
                                      Icons.keyboard_arrow_down_outlined),
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
                            child: DropdownButton(
                              borderRadius: BorderRadius.circular(12.0),
                              underline: Container(),
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_outlined),
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
                    flex: 10,
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
            ),
            if (_bannerAd != null)
              Flexible(flex: 1, child: AdWidget(ad: _bannerAd!))
          ],
        ));
  }
}
