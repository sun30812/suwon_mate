import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:suwon_mate/styles/style_widget.dart';

/// 수원대 학식 정보를 페이지 URL
const uri = 'https://www.suwon.ac.kr/index.html?menuno=1792';

/// 학식 정보를 확인할 수 있는 페이지이다.
///
/// 각 학생 식당의 금주의 식단을 화면에 출력하는 페이지이다.
/// 요일을 선택하면 그 요일의 식단이 화면에 출력된다.
class FoodInfoPage extends StatefulWidget {
  /// 학식 정보를 확인할 수 있는 페이지이다.
  const FoodInfoPage({Key? key}) : super(key: key);

  @override
  State<FoodInfoPage> createState() => _FoodInfoPageState();
}

class _FoodInfoPageState extends State<FoodInfoPage> {
  /// 수원대 학식 정보를 HTML로 가져오는 메서드
  Future getData() async {
    return await http.get(Uri.parse(uri));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Center(
          child: Column(
            children: [
              const TabBar(tabs: [
                Tab(
                  child: Text('종합강의동'),
                ),
                Tab(
                  child: Text('아마랜스홀'),
                ),
              ]),
              Expanded(
                child: TabBarView(
                  children: [
                    FutureBuilder(
                        future: getData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator.adaptive(),
                                Text('학식 정보 불러오는 중..')
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return DataLoadingError(
                              errorMessage: snapshot.error,
                            );
                          } else {
                            return FoodInfo(
                                data: snapshot.data as http.Response);
                          }
                        }),
                    const InvalidFoodInfoPage()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 학식 정보가 존재하지 않을 시 출력하는 페이지
class InvalidFoodInfoPage extends StatelessWidget {
  /// 학식 정보가 존재하지 않을 시 출력하는 페이지
  const InvalidFoodInfoPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.disabled_visible_outlined,
          size: 38.0,
        ),
        Text(
          '현재 학식은 제공되지 않습니다.',
          style: Theme.of(context).textTheme.titleLarge,
        )
      ],
    );
  }
}

/// 실질적으로 음식에 대한 정보를 나타내는 페이지에 해당된다.
class FoodInfo extends StatefulWidget {
  final http.Response data;

  const FoodInfo({required this.data, Key? key}) : super(key: key);

  @override
  State<FoodInfo> createState() => _FoodInfoState();
}

class _FoodInfoState extends State<FoodInfo> {
  /// 현재 선택된 요일
  int selectedDayWeek = 0;

  @override
  Widget build(BuildContext context) {
    try {
      var studentFoodElement =
          parse(widget.data.body).getElementsByClassName('contents_table2')[0];
      var stampFoodElement =
          parse(widget.data.body).getElementsByClassName('contents_table2')[1];
      var studentRows = studentFoodElement
          .getElementsByTagName('tr')[0]
          .getElementsByTagName('th');
      var studentCols = studentFoodElement.getElementsByTagName('td');
      var stampCols = stampFoodElement.getElementsByTagName('td');
      List<DropdownMenuEntry<int>> dayWeekEntries = [];
      for (int index = 0; index < studentRows.length - 1; index++) {
        dayWeekEntries.add(DropdownMenuEntry(
            value: index, label: studentRows[index + 1].text));
      }
      var studentFoodList =
          studentCols[selectedDayWeek + 2].innerHtml.replaceAll('<br>', '\n');
      var stampFoodList =
          stampCols[selectedDayWeek + 1].innerHtml.replaceAll('<br>', '\n');
      var infoList = parse(widget.data.body)
          .getElementsByClassName('dotlist')[0]
          .getElementsByTagName('li');
      return SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.calendar_month),
                const Padding(
                  padding: EdgeInsets.only(right: 4.0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 70,
                      child: Text(
                        parse(widget.data.body)
                            .getElementsByClassName('fl tp10')[0]
                            .text
                            .trim(),
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ]),
            ),
            DropdownMenu<int>(
                dropdownMenuEntries: dayWeekEntries,
                initialSelection: selectedDayWeek,
                onSelected: (newDayWeek) {
                  if (newDayWeek != null) {
                    setState(() {
                      selectedDayWeek = newDayWeek;
                    });
                  }
                },
                inputDecorationTheme: const InputDecorationTheme(filled: true)),
            InfoCard(
              icon: Icons.food_bank_outlined,
              title:
                  '학생식단 | ${studentCols[0].text.trim()} | ${studentCols[1].text.trim()}',
              detail: Text(
                studentFoodList,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            InfoCard(
              icon: Icons.food_bank_outlined,
              title: '교직원식단 | ${stampCols[0].text.trim()}',
              detail: Text(
                stampFoodList,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            InfoCard(
              icon: Icons.info_outline,
              title: '식당별 이용 안내',
              detail: ListView.builder(
                shrinkWrap: true,
                itemCount: infoList.length,
                itemBuilder: (context, index) => Text(
                    infoList[index].text.trim(),
                    style: Theme.of(context).textTheme.bodyLarge),
              ),
            )
          ],
        ),
      );
    } catch (_) {
      return const InvalidFoodInfoPage();
    }
  }
}
