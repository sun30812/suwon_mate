import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suwon_mate/model/class_info.dart';
import 'package:suwon_mate/styles/style_widget.dart';

/// 검색 유형
///
/// 검색 페이지에서 사용되는 검색 유형의 열거형
enum SearchType {
  /// 과목 이름으로 검색
  subjectName,

  /// 강의자 이름으로 검색
  professorName,

  /// 과목 코드로 검색
  subjectCode
}

extension on SearchType {
  /// 검색 유형에 따라 필요한 데이터베이스 필드 이름을 반환하는 메서드
  String get query {
    switch (this) {
      case SearchType.subjectName:
        return 'subjtNm';
      case SearchType.professorName:
        return 'ltrPrfsNm';
      case SearchType.subjectCode:
        return 'subjtCd';
    }
  }

  /// 검색 유형을 버튼에서 라벨로 출력하고 싶을 시 사용되는 메서드
  String get label {
    switch (this) {
      case SearchType.subjectName:
        return '과목 이름';
      case SearchType.professorName:
        return '강의자 이름';
      case SearchType.subjectCode:
        return '과목 코드';
    }
  }
}

/// 검색 버튼 누를 시 나타나는 검색 페이지이다.
class SearchPage extends StatefulWidget {
  /// 검색 버튼 누를 시 나타나는 검색 페이지이다.
  SearchPage({Key? key}) : super(key: key);

  /// 검색 종류에 관한 `ButtonSegment`리스트
  final List<ButtonSegment<SearchType>> searchTypeList = SearchType.values
      .map((element) =>
          ButtonSegment(value: element, label: Text(element.label)))
      .toList();

  /// 빠른 개설 강좌 조회 기능 여부를 확인하는 변수
  final bool quickMode = FirebaseRemoteConfig.instance.getBool('quick_mode');

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  /// 과목명을 입력받는 변수이다.
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _searchDepartmentController =
      TextEditingController();

  /// 어떤 유형의 검색을 실시할지에 대한 변수
  SearchType searchType = SearchType.subjectCode;

  var getDepartment = FirebaseDatabase.instance.ref('departments').once();

  /// 학부에 대한 정보가 담긴 [DropdownMenuEntry] 리스트
  List<DropdownMenuEntry<String>> departmentDropdownList = [];

  /// 검색어
  String _searchKeyword = '';

  /// 과목 코드로 강좌를 검색하는 메서드
  ///
  /// 과목 코드를 [code]에 입력하면 [classList]로부터 [code]와 과목 코드를 비교해서
  /// 일치하는 강좌의 정보를 반환한다. 만일 없는 경우 `null`을 반환한다.
  @Deprecated('해당 메서드는 추후 버전에서 제거될 예정입니다.')
  ClassInfo? searchSubject(String code, List<ClassInfo> classList) {
    for (var dat in classList) {
      if (dat.subjectCode == code) {
        return dat;
      }
    }
    return null;
  }

  /// 검색할 과목에 대한 정보를 FirebaseDatabase로부터 가져오는 메서드이다.
  Stream<DatabaseEvent> getData() {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref(widget.quickMode ? 'estbLectDtaiList_quick' : 'estbLectDtaiList');
    return ref
        .child(_searchDepartmentController.text)
        .orderByChild(searchType.query)
        .equalTo(_searchKeyword)
        .onValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('검색'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          FutureBuilder<DatabaseEvent>(
            future: getDepartment,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              } else if (snapshot.hasError) {
                return Container();
              } else {
                var data = snapshot.data?.snapshot.value as Map;
                departmentDropdownList.clear();
                departmentDropdownList
                    .add(const DropdownMenuEntry(value: '교양', label: '교양'));
                for (var department in data.keys) {
                  departmentDropdownList.add(DropdownMenuEntry(
                      value: department.toString(),
                      label: department.toString()));
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownMenu<String>(
                    initialSelection: '컴퓨터학부',
                    controller: _searchDepartmentController,
                    inputDecorationTheme:
                        const InputDecorationTheme(filled: true),
                    dropdownMenuEntries: departmentDropdownList,
                    label: const Text('검색 대상 학부'),
                    onSelected: (newValue) {
                      setState(() {
                        _searchDepartmentController.text = newValue!;
                      });
                    },
                  ),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<SearchType>(
              segments: widget.searchTypeList,
              selected: {searchType},
              onSelectionChanged: (newValue) => setState(() {
                searchType = newValue.first;
              }),
            ),
          ),
          Row(
            children: [
              Flexible(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                      label: Text(searchType.label), filled: true),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _searchKeyword = _searchController.text;
                  });
                },
              )
            ],
          ),
          Flexible(
            child: searchResult(),
          )
        ]),
      ),
    );
  }

  /// 검색 결과를 보여주는 [Widget]
  ///
  /// [_searchKeyword]에 글자를 입력하지 않았을 시 아무런 동작 없이 빈 화면을 띄운다.
  /// 글자가 입력이 되어있을 시 검색 결과를 [ListView] 형태로 출력한다.
  Widget searchResult() {
    if (_searchKeyword.isEmpty) {
      return Container();
    }
    return StreamBuilder<DatabaseEvent>(
        stream: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          } else if (snapshot.hasError) {
            return DataLoadingError(errorMessage: snapshot.error);
          } else {
            var value = snapshot.data?.snapshot.value;
            if (value == null) {
              return Container();
            }
            var classList = ClassInfo.fromFirebaseDatabase(value);
            return ListView.builder(
                itemCount: classList.length,
                itemBuilder: (BuildContext context, int index) {
                  return SimpleCard(
                      onPressed: () =>
                          context.push('/oclass/info', extra: classList[index]),
                      title: classList[index].name,
                      subTitle: classList[index].hostName ?? '이름 공개 안됨',
                      content: Text(
                        '${classList[index].guestDept ?? '학부 전체 대상(전공 없음)'}, ${classList[index].subjectKind ?? '공개 안됨'}, ${classList[index].classLocation ?? '공개 안됨'}',
                      ));
                });
          }
        });
  }

  /// 검색 시 아무 글자도 입력 안한 경우 검색 방법을 제공하는 위젯이다.
  ///
  /// [available]이 `false`로 설정되면 검색 방법이 나타나고 그렇지 않은 경우 나타나지 않는다.
  @Deprecated('해당 메서드는 추후 버전에서 제거될 예정입니다.')
  Widget searchHint(bool available) {
    if (available) {
      return Container();
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search,
          color: Colors.grey,
          size: 80.0,
        ),
        Text('강의자의 이름이나 과목명을 입력 후 검색 버튼을 누르면 검색이 시작됩니다.\n\n'),
        Text('과목 코드로 검색을 원하시면 우측 상단에 코드모양 버튼을 누릅니다.')
      ],
    );
  }
}
