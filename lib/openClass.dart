import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/main.dart';

class OpenClass extends StatefulWidget {
  const OpenClass({Key? key}) : super(key: key);

  @override
  _OpenClassState createState() => _OpenClassState();
}

class _OpenClassState extends State<OpenClass> {
  List<DropdownMenuItem> dropdownList = [];
  List orgClassList = [];
  bool isSaved = false;

  void getData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('estbLectDtaiList');
    DatabaseEvent event = await ref.once();
    List map = event.snapshot.value as List;

    for (var dat in map) {
      if (dat['estbDpmjNm'] == '컴퓨터학부') print(dat);
    }
  }

  Future<String?> getExistClass() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    DatabaseReference version = FirebaseDatabase.instance.ref('version');
    Map versionInfo = (await version.once()).snapshot.value as Map;
    isSaved = _pref.containsKey('class');
    if ((_pref.getString('db_ver') ?? "null") != versionInfo["db_ver"]) {
      isSaved = false;
      return null;
    }
    return _pref.getString('class');
  }

  Future getClass() async {
    if (await getExistClass() != null) {
      return getExistClass();
    }
    DatabaseReference ref = FirebaseDatabase.instance.ref('estbLectDtaiList');
    DatabaseReference version = FirebaseDatabase.instance.ref('version');
    SharedPreferences _pref = await SharedPreferences.getInstance();
    Map versionInfo = (await version.once()).snapshot.value as Map;
    _pref.setString('db_ver', versionInfo["db_ver"]);
    return await ref.once();
  }

  @override
  void initState() {
    super.initState();
    dropdownList.add(DropdownMenuItem(child: Text('컴퓨터학부')));
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
        appBar: AppBar(title: Text('개설 강좌 조회')),
        body: FutureBuilder(
          future: getClass(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator.adaptive());
            } else if (snapshot.hasError) {
              return Column(
                children: [Icon(Icons.error_outline), Text('오류가 발생했습니다.')],
              );
            } else {
              if (isSaved) {
                orgClassList = jsonDecode(snapshot.data as String);
              } else {
                DatabaseEvent _event = snapshot.data;
                orgClassList = _event.snapshot.value as List;
              }
              List classList = [];
              for (var classData in orgClassList) {
                if (classData['estbDpmjNm'] == '컴퓨터학부') {
                  classList.add(classData);
                }
              }
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton(
                            items: dropdownList, onChanged: null),
                      ),
                      SuwonButton(
                          icon: Icons.search,
                          buttonName: '조회하기',
                          onPressed: () {}),
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
