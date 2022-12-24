import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:go_router/go_router.dart';
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

  /// 개설 강좌 조회 시 페이지이다.
  const OpenClass(
      {required this.settingsData,
      required this.myDept,
      required this.myMajor,
      required this.myGrade,
      Key? key})
      : super(key: key);

  @override
  _OpenClassState createState() => _OpenClassState();
}

class _OpenClassState extends State<OpenClass> {
  late String _myDept = widget.myDept;
  late String _myMajor = widget.myMajor;
  late String _myGrade = widget.myGrade;
  List<String> gradeList = ['1학년', '2학년', '3학년', '4학년'];
  List<DropdownMenuItem<String>> dpDropdownList = [];
  List<DropdownMenuItem<String>> subjectDropdownList = [];
  List<DropdownMenuItem<String>> gradeDownList = [];
  List<DropdownMenuItem<String>> regionList = const [
    DropdownMenuItem(
      child: Text('전체'),
      value: '전체',
    ),
    DropdownMenuItem(
      child: Text('1영역'),
      value: '언어와 소통',
    ),
    DropdownMenuItem(
      child: Text('2영역'),
      value: '세계와 문명',
    ),
    DropdownMenuItem(
      child: Text('3영역'),
      value: '역사와 사회',
    ),
    DropdownMenuItem(
      child: Text('4영역'),
      value: '문화와 철학',
    ),
    DropdownMenuItem(
      child: Text('5영역'),
      value: '기술과 정보',
    ),
    DropdownMenuItem(
      child: Text('6영역'),
      value: '건강과 예술',
    ),
    DropdownMenuItem(
      child: Text('7영역'),
      value: '자연과 과학',
    )
  ];
  Map allClassList = {};
  String _region = '전체';
  Set<String> dpSet = {};
  Map<String, List> dpMap = {};
  Map subjects = {};
  bool _isFirstDp = true;
  BannerAd? _bannerAd;
  bool _loadBanner = false;

  Future<void> _createBanner(BuildContext context) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    Map settingData = jsonDecode(_pref.getString('settings')!) as Map;
    final _bottomBannerAd = settingData['bottomBanner'] ?? true;
    if (!_bottomBannerAd) {
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

  Future getData() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    DatabaseReference version = FirebaseDatabase.instance.ref('version');
    Map versionInfo = (await version.once()).snapshot.value as Map;
    DatabaseReference ref = FirebaseDatabase.instance.ref('estbLectDtaiList');

    _pref.setString('db_ver', versionInfo["db_ver"]);
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
        child: Text(dat),
        value: dat,
      ));
    }
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.remove('dp_set');
    _pref.setString('subjects', jsonEncode(subjects));
    _pref.setString('dpMap', jsonEncode(dpMap));
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
          title: const Text('개설 강좌 조회'),
          actions: [
            IconButton(
              onPressed: () {
                List<ClassInfo> classList = [];
              for (List data in allClassList.values) {
                classList.addAll(ClassInfo.fromFirebaseDatabase(data));
              }
              context.push('/oclass/search', extra: [
                 classList,
                  widget.settingsData
                ]);
            }),
              ]),
              icon: const Icon(Icons.search),
              tooltip: '검색',
            )
          ],
        ),
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
              return const DataLoadingError();
            } else {
              DatabaseEvent _event = snapshot.data;
              allClassList = _event.snapshot.value as Map;
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
                List<String> _tempList = [];
                dpDropdownList.add(const DropdownMenuItem(
                  child: Text('교양'),
                  value: '교양',
                ));
                dpDropdownList.add(const DropdownMenuItem(
                  child: Text('교양(야)'),
                  value: '교양(야)',
                ));
                for (String depart in dpSet) {
                  _tempList.add(depart);
                }
                _tempList.sort((a, b) => a.compareTo(b));
                for (String depart in _tempList) {
                  dpDropdownList.add(DropdownMenuItem(
                    child: Text(depart),
                    value: depart,
                  ));
                }

                _isFirstDp = false;
              }
              List _tempList = [];
              subjectDropdownList.clear();
              subjectDropdownList.add(const DropdownMenuItem(
                child: Text('전체'),
                value: '전체',
              ));
              subjectDropdownList.add(const DropdownMenuItem(
                child: Text('학부 공통'),
                value: '학부 공통',
              ));
              for (String subject in tempSet) {
                _tempList.add(subject);
              }
              _tempList.sort((a, b) => a.compareTo(b));
              for (String subject in _tempList) {
                subjectDropdownList.add(DropdownMenuItem(
                  child: Text(subject),
                  value: subject,
                ));
              }
              for (var classData
                  in ClassInfo.fromFirebaseDatabase(allClassList[_myDept])) {
                if (_myDept == '교양') {
                  if ((classData.guestGrade.toString() + '학년' == _myGrade) &&
                      ((_region == '전체' ||
                          _region == (classData.region ?? 'none')))) {
                    classList.add(classData);
                  }
                } else if (_myMajor == '학부 공통') {
                  if ((classData.guestMjor == null) &&
                      ((classData.guestGrade.toString() + '학년') == _myGrade)) {
                    classList.add(classData);
                  }
                } else if ((_myMajor == '전체' ||
                        (classData.guestMjor == _myMajor)) &&
                    ((classData.guestGrade.toString() + '학년') == _myGrade)) {
                  classList.add(classData);
                }
              }
              classList.sort((a, b) => (a.name.compareTo(b.name)));
              return Column(
                children: [
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
                    flex: 10,
                    child: ListView.builder(
                        itemCount: classList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SimpleCardButton(
                            onPressed: () => context.push('/oclass/info',
                                extra: classList[index]),
                            title: classList[index].name,
                            subTitle: classList[index].hostName ?? "이름 공개 안됨",
                            content: Text((classList[index].guestMjor ??
                                    "학부 전체 대상") +
                                ", " +
                                (classList[index].subjectKind ?? '공개 안됨') +
                                ', ' +
                                (classList[index].classLocation ?? "공개 안됨")),
                          );
                        }),
                  ),
                  if (_bannerAd != null)
                    Flexible(flex: 1, child: AdWidget(ad: _bannerAd!))
                ],
              );
            }
          },
        ));
  }
}
