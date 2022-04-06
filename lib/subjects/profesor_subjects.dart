import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/styles/style_widget.dart';

class ProfessorSubjectsPage extends StatefulWidget {
  const ProfessorSubjectsPage({Key? key}) : super(key: key);

  @override
  State<ProfessorSubjectsPage> createState() => _ProfessorSubjectsPageState();
}

class _ProfessorSubjectsPageState extends State<ProfessorSubjectsPage> {
  String _myGrade = '전체';
  Set<String> dpSet = {};
  List<String> gradeList = ['전체', '1학년', '2학년', '3학년', '4학년'];
  List<DropdownMenuItem<String>> dropdownList = [];
  List<DropdownMenuItem<String>> gradeDownList = [];
  List orgClassList = [];
  List classList = [];

  bool _isFirst = true;

  Future getClass() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref.getString('class');
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
  Widget build(BuildContext context) {
    final String professorName =
        (ModalRoute.of(context)!.settings.arguments!) as String;
    return Scaffold(
      appBar: AppBar(title: Text('$professorName 강의자의 과목들')),
      body: FutureBuilder(
        future: getClass(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else if (snapshot.hasError) {
            return const DataLoadingError();
          } else {
            orgClassList = jsonDecode(snapshot.data as String);

            Map rawClassList = orgClassList[0];
            if (_isFirst) {
              for (var _dat in rawClassList.values.toList()) {
                for (var _dat2 in _dat) {
                  classList.add(_dat2);
                }
              }
              _isFirst = false;
            }

            List tempList = [];
            for (var classData in classList) {
              if ((classData['ltrPrfsNm'] == professorName)) {
                if (_myGrade == '전체') {
                  tempList.add(classData);
                } else if (((classData['trgtGrdeCd'].toString() + '학년') ==
                    _myGrade)) {
                  tempList.add(classData);
                }
              }
            }
            tempList.sort((a, b) =>
                ((a["subjtNm"] as String).compareTo((b["subjtNm"] as String))));
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                Flexible(
                  child: ListView.builder(
                      itemCount: tempList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SimpleCardButton(
                          onPressed: () => Navigator.of(context).pushNamed(
                              '/oclass/info',
                              arguments: tempList[index]),
                          title: tempList[index]["subjtNm"],
                          subTitle: tempList[index]["ltrPrfsNm"] ?? "이름 공개 안됨",
                          content: Text(
                              (tempList[index]["deptNm"] ?? "학부 전체 대상(전공 없음)") +
                                  ", " +
                                  tempList[index]["facDvnm"] +
                                  ', ' +
                                  (tempList[index]["timtSmryCn"] ?? "공개 안됨") +
                                  ', ' +
                                  (tempList[index]['estbDpmjNm'])),
                        );
                      }),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
