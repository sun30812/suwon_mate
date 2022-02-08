import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenClass extends StatefulWidget {
  const OpenClass({Key? key}) : super(key: key);

  @override
  _OpenClassState createState() => _OpenClassState();
}

class _OpenClassState extends State<OpenClass> {
  List<String> gradeList = ['1학년', '2학년', '3학년', '4학년'];
  List<DropdownMenuItem<String>> dropdownList = [];
  List<DropdownMenuItem<String>> gradeDownList = [];
  List orgClassList = [];
  bool isSaved = false;
  String _mySub = '컴퓨터학부';
  String _myGrade = '1학년';
  bool _isFirst = true;
  bool _isFirstDp = true;

  void getData() async {

    DatabaseReference ref = FirebaseDatabase.instance.ref('estbLectDtaiList');
    DatabaseEvent event = await ref.once();
    List map = event.snapshot.value as List;

    for (var dat in map) {
      if (dat['estbDpmjNm'] == ('컴퓨터학부')) print(dat);
    }
  }
  // TODO: 웹 상에서 getExistClass함수 동작하도록 하기

  // Future<String?> getExistClass() async {
  //   SharedPreferences _pref = await SharedPreferences.getInstance();
  //   DatabaseReference version = FirebaseDatabase.instance.ref('version');
  //   Map versionInfo = (await version.once()).snapshot.value as Map;
  //   isSaved = _pref.containsKey('class');
  //   if ((_pref.getString('db_ver') ?? "null") != versionInfo["db_ver"]) {
  //     isSaved = false;
  //     return null;
  //   }
  //   return _pref.getString('class');
  // }


  Future getClass() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    if (_isFirst) {
      _mySub = _pref.getString('mySub') ?? '컴퓨터학부';
      _isFirst = false;
    }
    // if (await getExistClass() != null) {
    //   return getExistClass();
    // }
    DatabaseReference ref = FirebaseDatabase.instance.ref('estbLectDtaiList');
    DatabaseReference version = FirebaseDatabase.instance.ref('version');
    Map versionInfo = (await version.once()).snapshot.value as Map;
    _pref.setString('db_ver', versionInfo["db_ver"]);
    return await ref.once();
  }

  @override
  void initState() {
    super.initState();
    // dropdownList.add(const DropdownMenuItem(child: Text('컴퓨터학부'), value: '컴퓨터학부',));
    // dropdownList.add(const DropdownMenuItem(child: Text('경영학부'), value: '경영학부',));

    for(var dat in gradeList) {
      gradeDownList.add(DropdownMenuItem(child: Text(dat), value: dat,));
    }
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String _saveData = jsonEncode(orgClassList);
    _pref.setString('class', _saveData);
  }

  @override
  Widget build(BuildContext context) {
    // getData();
    return Scaffold(
        appBar: AppBar(title: const Text('개설 강좌 조회')),
        body: FutureBuilder(
          future: getClass(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (snapshot.hasError) {
              return Column(
                children: const [Icon(Icons.error_outline), Text('오류가 발생했습니다.')],
              );
            } else {
              if (isSaved) {
                orgClassList = jsonDecode(snapshot.data as String);
              } else {
                DatabaseEvent _event = snapshot.data;
                orgClassList = _event.snapshot.value as List;
              }
              List classList = [];
              Set dpSet = {};
              for(var dat in orgClassList) {
                dpSet.add(dat['estbDpmjNm'].toString());
              }
              if (_isFirstDp) {
                for(String depart in dpSet) {
                  dropdownList.add(DropdownMenuItem(child: Text(depart), value: depart,));
                }
                _isFirstDp = false;
              }
              for (var classData in orgClassList) {
                if ((classData['estbDpmjNm'] == _mySub) && classData['trgtGrdeNm'] == _myGrade) {
                  classList.add(classData);
                }
              }
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton(
                            items: dropdownList, onChanged: (String? value) {
                              setState(() {
                                _mySub = value!;
                              });
                        }, value: _mySub,),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton(
                          items: gradeDownList, onChanged: (String? value) {
                          setState(() {
                            _myGrade = value!;
                          });
                        }, value: _myGrade,),
                      ),
                    ],
                  ),
                  Flexible(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: classList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    classList[index]["subjtNm"],
                                    style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    classList[index]["stafNm"] ?? "이름 공개 안됨",
                                    style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(classList[index]["trgtGrdeNm"] +
                                      ", " +
                                      classList[index]["point"].toString() +
                                      "학점, " +
                                      classList[index]["facDvnm"]),
                                ],
                              ),
                            ),
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
