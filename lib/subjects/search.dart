import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suwon_mate/styles/style_widget.dart';

import '../model/class_info.dart';

/// 검색 버튼 누를 시 나타나는 검색 페이지이다.
class SearchPage extends StatefulWidget {
  /// 검색 대상에 해당하는 전체 강의 목록이다.
  final List<ClassInfo> classList;

  /// 자동으로 검색을 시작하는 기능의 활성화 여부이다.
  final bool liveSearch;

  /// 자동으로 검색을 시작하는 기능이 활성화 되어있을 시 몇자부터 검색을 시작할 지에 대한 변수이다.
  final double liveSearchCount;

  /// 검색 버튼 누를 시 나타나는 검색 페이지이다.
  const SearchPage(
      {required this.classList,
      required this.liveSearch,
      required this.liveSearchCount,
      Key? key})
      : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  /// 과목명을 입력받는 변수이다.
  final TextEditingController _subjectNameController = TextEditingController();

  /// 과목 코드를 입력받는 변수이다.
  final TextEditingController _subjectCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  /// 과목 코드로 강좌를 검색하는 메서드
  ///
  /// 과목 코드를 [code]에 입력하면 [classList]로부터 [code]와 과목 코드를 비교해서
  /// 일치하는 강좌의 정보를 반환한다. 만일 없는 경우 `null`을 반환한다.
  ClassInfo? searchSubject(String code, List<ClassInfo> classList) {
    for (var dat in classList) {
      if (dat.subjectCode == code) {
        return dat;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('강의자 및 과목명 검색'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SuwonDialog(
                  icon: Icons.manage_search_outlined,
                  title: '과목 코드로 검색',
                  content: Column(
                    children: [
                          const Text('과목코드를 입력하여 검색할 수 있습니다.'),
                          TextField(
                            key: const Key('subject_code_field'),
                            controller: _subjectCodeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: '과목 코드 입력',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => setState(() {
                                    _subjectCodeController.text = '';
                                  }),
                                )),
                          )
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (_subjectCodeController.text.contains('-')) {
                          ClassInfo? searchResult = searchSubject(
                              _subjectCodeController.text, widget.classList);
                          if (searchResult != null) {
                            context.push('/oclass/info', extra: searchResult);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('존재하지 않는 과목 코드입니다.')));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('과목코드 전체를 입력해주십시요.')));
                        }
                      },
                    ),
              );
            },
            icon: const Icon(Icons.manage_search_outlined),
            tooltip: '과목코드 검색',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Row(
            children: [
              Flexible(
                child: smartSearchBar(),
              ),
            ],
          ),
          searchHint(_subjectNameController.text.isNotEmpty),
          Flexible(
            child: ListView.builder(
                itemCount: widget.classList.length,
                itemBuilder: (BuildContext context, int index) {
                  if ((_subjectNameController.text.isNotEmpty) &&
                      (widget.classList[index].hostName
                              .toString()
                              .contains(_subjectNameController.text) ||
                          widget.classList[index].name
                              .toString()
                              .contains(_subjectNameController.text))) {
                    return SimpleCard(
                        onPressed: () => context.push('/oclass/info',
                            extra: widget.classList[index]),
                        title: widget.classList[index].name,
                        subTitle:
                            widget.classList[index].hostName ?? "이름 공개 안됨",
                        content: Text(
                          '${widget.classList[index].guestDept ?? '학부 전체 대상(전공 없음)'}, ${widget.classList[index].subjectKind ?? '공개 안됨'}, ${widget.classList[index].classLocation ?? '공개 안됨'}',
                        ));
                  }
                  return Container();
                }),
          )
        ]),
      ),
    );
  }

  /// 자동으로 검색을 시작하는지의 여부에 따라 상황에 맞는 과목 검색 상자를 제공하는 위젯이다.
  ///
  /// [widget.liveSearch]의 여부에 따라 `true`인 경우 자동으로 검색을 수행하는 검색 상자를 제공하고
  /// 그렇지 않은 경우 검색 버튼을 사용자가 눌러서 검색이 가능하도록 하는 검색 상자를 제공하는 위젯이다.
  SearchBar smartSearchBar() {
    if (widget.liveSearch) {
      return SearchBar(
          icon: Icons.search,
          controller: _subjectNameController,
          onChanged: (value) {
            if (_subjectNameController.text.length >= widget.liveSearchCount) {
              setState(() {});
            }
          });
    } else {
      return SearchBar(
          acceptIcon: Icons.search,
          icon: Icons.search,
          controller: _subjectNameController,
          onAcceptPressed: () => setState(() {}));
    }
  }

  /// 검색 시 아무 글자도 입력 안한 경우 검색 방법을 제공하는 위젯이다.
  ///
  /// [available]이 `false`로 설정되면 검색 방법이 나타나고 그렇지 않은 경우 나타나지 않는다.
  Widget searchHint(bool available) {
    if (available) {
      return Container();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.search,
          color: Colors.grey,
          size: 80.0,
        ),
        if (widget.liveSearch)
          Text(
              '강의자의 이름이나 과목명을 ${widget.liveSearchCount.round()}자 이상 입력하면 검색을 시작합니다.\n\n')
        else
          const Text('강의자의 이름이나 과목명을 입력 후 검색 버튼을 누르면 검색이 시작됩니다.\n\n'),
        const Text('과목 코드로 검색을 원하시면 우측 상단에 코드모양 버튼을 누릅니다.')
      ],
    );
  }
}
