import 'package:flutter/material.dart';
import 'package:suwon_mate/style_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    List classList = args;

    return Scaffold(
      appBar: AppBar(
        title: const Text('강의자 및 과목명 검색'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Row(
            children: [
              Flexible(
                child: InputBar(
                    controller: _controller,
                    onChanged: (value) {
                      setState(() {});
                    }),
              ),
            ],
          ),
          Flexible(
            child: ListView.builder(
                itemCount: classList.length,
                itemBuilder: (BuildContext context, int index) {
                  if (_controller.text.isEmpty ||
                      classList[index]["ltrPrfsNm"]
                          .toString()
                          .contains(_controller.text) ||
                      classList[index]["subjtNm"]
                          .toString()
                          .contains(_controller.text)) {
                    return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/oclass/info',
                              arguments: classList[index]);
                        },
                        child: CardInfo.Simplified(
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
}
