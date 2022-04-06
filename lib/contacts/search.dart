// 해당 기능은 작동하도록 작업하지 않았으며 사라질 수도 있습니다.
import 'package:flutter/material.dart';
import 'package:suwon_mate/styles/style_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List classList = [];
  bool _isFirst = true;
  bool _liveSearch = true;
  double _liveSearchCount = 0.0;

  @override
  void initState() {
    super.initState();
  }

  String searchSubjectName(String code, List classList) {
    for (var dat in classList) {
      if (dat['subjtCd'] == code) {
        return dat['subjtNm'];
      }
    }
    return 'none';
  }

  int getSubjectIndex(String code, List listData) {
    int _index = 0;
    for (var dat in listData) {
      if (code == '${dat['subjtCd']}-${dat['diclNo']}') {
        return _index;
      }
      _index++;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    Map rawClassList = args[0][0];
    _liveSearch = args[1] ?? true;
    _liveSearchCount = args[2] ?? 0.0;
    if (_isFirst) {
      for (var _dat in rawClassList.values.toList()) {
        for (var _dat2 in _dat) {
          classList.add(_dat2);
        }
      }
      _isFirst = false;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('전화번호 검색')),
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
          searchHint(_controller.text.isNotEmpty),
          Flexible(
            child: ListView.builder(
                itemCount: classList.length,
                itemBuilder: (BuildContext context, int index) {
                  if ((_controller.text.isNotEmpty) &&
                      (classList[index]["ltrPrfsNm"]
                              .toString()
                              .contains(_controller.text) ||
                          classList[index]["subjtNm"]
                              .toString()
                              .contains(_controller.text))) {
                    return SimpleCardButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                          '/oclass/info',
                          arguments: classList[index]),
                      title: classList[index]["subjtNm"],
                      subTitle: classList[index]["ltrPrfsNm"] ?? "이름 공개 안됨",
                      content: Text(
                          (classList[index]["deptNm"] ?? "학부 전체 대상(전공 없음)") +
                              ", " +
                              classList[index]["facDvnm"] +
                              ', ' +
                              (classList[index]["timtSmryCn"] ?? "공개 안됨")),
                    );
                  }
                  return Container();
                }),
          )
        ]),
      ),
    );
  }

  SearchBar smartSearchBar() {
    if (_liveSearch) {
      return SearchBar(
          icon: Icons.search,
          controller: _controller,
          onChanged: (value) {
            if (_controller.text.length >= _liveSearchCount) {
              setState(() {});
            }
          });
    } else {
      return SearchBar(
          acceptIcon: Icons.search,
          icon: Icons.search,
          controller: _controller,
          onAcceptPressed: () => setState(() {}));
    }
  }

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
        if (_liveSearch)
          Text('이름을 ${_liveSearchCount.round()}자 이상 입력하면 검색을 시작합니다.\n\n')
        else
          const Text('이름을 입력 후 검색 버튼을 누르면 검색이 시작됩니다.'),
      ],
    );
  }
}
