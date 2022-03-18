import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/style_widget.dart';

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
            return Text('error');
          } else {
            orgClassList = jsonDecode(snapshot.data as String);
            List classList = [];
            for (var classData in orgClassList) {
              if ((classData['ltrPrfsNm'] == professorName)) {
                if (_myGrade == '전체') {
                  classList.add(classData);
                } else if (((classData['trgtGrdeCd'].toString() + '학년') ==
                    _myGrade)) {
                  classList.add(classData);
                }
              }
            }
            classList.sort((a, b) =>
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
                                  (classList[index]["timtSmryCn"] ?? "공개 안됨") +
                                  ', ' +
                                  (classList[index]['estbDpmjNm'])),
                            ));
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
