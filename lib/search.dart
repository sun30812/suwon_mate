import 'package:flutter/material.dart';
import 'package:suwon_mate/style_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  List classList = [];
  bool _isFirst = true;
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

  @override
  Widget build(BuildContext context) {
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    Map rawClassList = args[0];
    if (_isFirst) {
      for(var _dat in rawClassList.values.toList()) {
        for(var _dat2 in _dat) {
          classList.add(_dat2);

        }
      }
      _isFirst = false;
    }

    return Scaffold(
      appBar: AppBar(
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
                        controller: _controller2,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: '과목 코드 입력',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() {
                                _controller2.text = '';
                              }),
                            )),
                      )
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    int _count = 0;
                    bool _isFound = false;
                    if (_controller2.text.contains('-')) {
                      for (var dat in classList) {
                        if (_controller2.text ==
                            '${dat['subjtCd']}-${dat['diclNo']}') {
                          _isFound = true;
                          Navigator.of(context).pushNamed('/oclass/info',
                              arguments: classList[_count]);
                          break;
                        }
                        _count++;
                      }
                      if (!_isFound) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('해당 과목은 존재하지 않습니다.')));
                      }
                    } else {
                      String subjectName =
                          searchSubjectName(_controller2.text, classList);
                      if (subjectName == 'none') {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('해당 과목은 존재하지 않습니다.')));
                      } else {
                        setState(() {
                          _controller.text = subjectName;
                        });
                      }
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
                child: InputBar(
                    icon: Icons.search,
                    controller: _controller,
                    onChanged: (value) {
                      setState(() {});
                    }),
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
                    return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/oclass/info',
                              arguments: classList[index]);
                        },
                        child: CardInfo.simplified(
                          title: classList[index]["subjtNm"],
                          subTitle: classList[index]["ltrPrfsNm"] ?? "이름 공개 안됨",
                          content: Text((classList[index]["deptNm"] ??
                                  "학부 전체 대상(전공 없음)") +
                              ", " +
                              classList[index]["facDvnm"] +
                              ', ' +
                              (classList[index]["timtSmryCn"] ?? "공개 안됨")),
                        ));
                  }
                  return Container();
                }),
          )
        ]),
      ),
    );
  }

  Widget searchHint(bool available) {
    if (available) {
      return Container();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.search,
          color: Colors.grey,
          size: 80.0,
        ),
        Text('강의자의 이름이나 과목명을 입력하면 검색을 시작합니다.\n\n'),
        Text('과목 코드로 검색을 원하시면 우측 상단에 코드모양 버튼을 누릅니다.')
      ],
    );
  }
}
