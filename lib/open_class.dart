import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/style_widget.dart';

class OpenClass extends StatefulWidget {
  const OpenClass({Key? key}) : super(key: key);

  @override
  _OpenClassState createState() => _OpenClassState();
}

class _OpenClassState extends State<OpenClass> {
  List<String> gradeList = ['1학년', '2학년', '3학년', '4학년'];
  List<DropdownMenuItem<String>> dropdownList = [];
  List<DropdownMenuItem<String>> gradeDownList = [];
  List<DropdownMenuItem<String>> regionList = const [
    DropdownMenuItem(
      child: Text('전체'),
      value: '전체',
    ),
    DropdownMenuItem(
      child: Text('1영역(언어와 소통)'),
      value: '언어와 소통',
    ),
    DropdownMenuItem(
      child: Text('2영역(세계와 문명)'),
      value: '세계와 문명',
    ),
    DropdownMenuItem(
      child: Text('3영역(역사와 사회)'),
      value: '역사와 사회',
    ),
    DropdownMenuItem(
      child: Text('4영역(문화와 철학)'),
      value: '문화와 철학',
    ),
    DropdownMenuItem(
      child: Text('5영역(기술과 정보)'),
      value: '기술과 정보',
    ),
    DropdownMenuItem(
      child: Text('6영역(건강과 예술)'),
      value: '건강과 예술',
    ),
    DropdownMenuItem(
      child: Text('7영역(자연과 과학)'),
      value: '자연과 과학',
    )
  ];
  List orgClassList = [];
  bool _offline = false;
  bool isSaved = false;
  String _myDept = '컴퓨터학부';
  final String _mySub = '전체';
  String _myGrade = '1학년';
  String _region = '전체';
  Set<String> dpSet = {};
  bool _isFirst = true;
  bool _isFirstDp = true;

  Future getClass() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    if (_isFirst) {
      _myDept = _pref.getString('mySub') ?? '컴퓨터학부';
      _myGrade = _pref.getString('myGrade') ?? '1학년';
      _isFirst = false;
      if (_pref.containsKey('settings')) {
        _offline = (jsonDecode(_pref.getString('settings')!) as Map)['offline'];
      }
    }
    if ((_pref.containsKey('db_ver')) && _offline) {
      isSaved = true;
      return _pref.getString('class');
    }
    DatabaseReference version = FirebaseDatabase.instance.ref('version');
    Map versionInfo = (await version.once()).snapshot.value as Map;
    if ((_pref.getString('db_ver')) == versionInfo["db_ver"]) {
      isSaved = true;
      return _pref.getString('class');
    }
    DatabaseReference ref = FirebaseDatabase.instance.ref('estbLectDtaiList');
    _pref.setString('db_ver', versionInfo["db_ver"]);
    return await ref.once();
  }

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
    String _saveData = jsonEncode(orgClassList);
    _pref.setString('class', _saveData);
    _pref.setStringList('dp_set', dpSet.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('개설 강좌 조회')),
        floatingActionButton: SuwonButton(
            isActivate: true,
            icon: Icons.search,
            buttonName: '검색',
            onPressed: () => Navigator.of(context)
                .pushNamed('/oclass/search', arguments: orgClassList)),
        body: FutureBuilder(
          future: getClass(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Column(
                children: const [
                  Center(child: CircularProgressIndicator.adaptive()),
                  Text('DB 버전 확인 및 갱신 중')
                ],
              );
            } else if (snapshot.hasError) {
              return Column(
                children: const [
                  Icon(Icons.error_outline),
                  Text('오류가 발생했습니다.')
                ],
              );
            } else {
              if (isSaved) {
                orgClassList = jsonDecode(snapshot.data as String);
              } else {
                DatabaseEvent _event = snapshot.data;
                orgClassList = _event.snapshot.value as List;
              }
              List classList = [];
              for (var dat in orgClassList) {
                dpSet.add(dat['estbDpmjNm'].toString());
              }
              if (_isFirstDp) {
                for (String depart in dpSet) {
                  dropdownList.add(DropdownMenuItem(
                    child: Text(depart),
                    value: depart,
                  ));
                }
                dropdownList.sort((a, b) => a.value!.compareTo(b.value!));
                _isFirstDp = false;
              }
              for (var classData in orgClassList) {
                if ((classData['estbDpmjNm'] == _myDept) &&
                    ((classData['trgtGrdeCd'].toString() + '학년') == _myGrade)) {
                  if (_mySub == '전체' &&
                      (_region == '전체' ||
                          _region == (classData["cltTerrNm"] ?? 'none'))) {
                    classList.add(classData);
                  }
                }
              }
              classList.sort((a, b) => ((a["subjtNm"] as String)
                  .compareTo((b["subjtNm"] as String))));
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
                            items: dropdownList,
                            onChanged: (String? value) {
                              setState(() {
                                _myDept = value!;
                              });
                            },
                            value: _myDept,
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
                          return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed('/oclass/info',
                                    arguments: classList[index]);
                              },
                              child: CardInfo.simplified(
                                title: classList[index]["subjtNm"],
                                subTitle:
                                    classList[index]["ltrPrfsNm"] ?? "이름 공개 안됨",
                                content: Text((classList[index]["deptNm"] ??
                                        "학부 전체 대상(전공 없음)") +
                                    ", " +
                                    classList[index]["facDvnm"] +
                                    ', ' +
                                    (classList[index]["timtSmryCn"] ??
                                        "공개 안됨")),
                              ));
                        }),
                  ),
                ],
              );
            }
          },
        ));
  }
}
