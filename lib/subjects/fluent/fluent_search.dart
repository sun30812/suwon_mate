import 'package:firebase_database/firebase_database.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:suwon_mate/model/class_info.dart';
import 'package:suwon_mate/styles/style_widget.dart';
import 'package:suwon_mate/subjects/search.dart';

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

/// 검색 버튼 누를 시 나타나는 Fluent 다지인의 검색 페이지이다.
class FluentSearchPage extends StatefulWidget {
  /// 검색 버튼 누를 시 나타나는 검색 페이지이다.
  FluentSearchPage({Key? key}) : super(key: key);

  /// 검색 종류에 관한 `ButtonSegment`리스트
  final List<ComboBoxItem<SearchType>> searchTypeList = SearchType.values
      .map(
          (element) => ComboBoxItem(value: element, child: Text(element.label)))
      .toList();

  /// 빠른 개설 강좌 조회 기능 여부를 확인하는 변수(데스크톱용은 무조건 false)
  final bool quickMode = false;

  @override
  State<FluentSearchPage> createState() => _FluentSearchPageState();
}

class _FluentSearchPageState extends State<FluentSearchPage> {
  /// 과목명을 입력받는 변수이다.
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _searchDepartmentController =
      TextEditingController();

  /// 어떤 유형의 검색을 실시할지에 대한 변수
  SearchType searchType = SearchType.subjectCode;

  var getDepartment = FirebaseDatabase.instance.ref('departments').once();

  /// 학부에 대한 정보가 담긴 [DropdownMenuEntry] 리스트
  List<ComboBoxItem<String>> departmentDropdownList = [];

  /// 검색어
  String _searchKeyword = '';

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
    return NavigationView(
      appBar: NavigationAppBar(),
      content: ScaffoldPage.withPadding(
        padding: EdgeInsets.all(8.0),
        header: PageHeader(
          title: const Text('검색'),
        ),
        content: Column(mainAxisSize: MainAxisSize.max, children: [
          FutureBuilder<DatabaseEvent>(
            future: getDepartment,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ProgressBar();
              } else if (snapshot.hasError) {
                return Container();
              } else {
                var data = snapshot.data?.snapshot.value as Map;
                departmentDropdownList.clear();
                departmentDropdownList
                    .add(const ComboBoxItem(value: '교양', child: Text('교양')));
                for (var department in data.keys) {
                  departmentDropdownList.add(ComboBoxItem(
                      value: department.toString(),
                      child: Text(department.toString())));
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ComboBox<String>(
                    value: '컴퓨터학부',
                    items: departmentDropdownList,
                    placeholder: const Text('검색 대상 학부'),
                    onChanged: (newValue) {
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
            child: ComboBox<SearchType>(
              items: widget.searchTypeList,
              value: searchType,
              onChanged: (newValue) => setState(() {
                searchType = newValue!;
              }),
            ),
          ),
          Row(
            children: [
              Flexible(
                child: TextBox(
                    controller: _searchController,
                    placeholder: searchType.label),
              ),
              IconButton(
                icon: const Icon(FluentIcons.search),
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
    // if (!Platform.isMacOS) {
    //   return FutureBuilder<http.Response>(
    //       future: future, builder: builder
    //   )
    // }
    return StreamBuilder<DatabaseEvent>(
        stream: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ProgressBar();
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
}