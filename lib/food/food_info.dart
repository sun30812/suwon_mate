import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:suwon_mate/styles/style_widget.dart';
import 'package:url_launcher/url_launcher.dart';

/// 수원대 페이지 URL
const uri = 'https://www.suwon.ac.kr/index.html?menuno=';

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
  ///
  /// [code]의 경우 메뉴 번호인데 1792는 종합강의동 학식 확인 메뉴 1793은 아마랜스홀 학식 확인 메뉴이다.
  Future getData(String code) async {
    return await http.get(Uri.parse(uri + code));
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
                        future: getData('1792'),
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
                    FutureBuilder(
                        future: getData('1793'),
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
                        })
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
          '현재 학식 정보를 제공하지 않거나 사이트와의 연동 문제로 인해 표시할 수 없습니다.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        TextButton(
            onPressed: () async {
              await launchUrl(
                  Uri.parse('https://www.suwon.ac.kr/index.html?menuno=1792'),
                  mode: LaunchMode.externalApplication);
            },
            child: const Text('사이트에서 확인'))
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
      var foodElement =
          parse(widget.data.body).getElementsByClassName('contents_table2');
      var studentRows = foodElement[0]
          .getElementsByTagName('tr')[0]
          .getElementsByTagName('th');
      var studentCols = foodElement[0].getElementsByTagName('td');
      List<DropdownMenuEntry<int>> dayWeekEntries = [];
      for (int index = 0; index < studentRows.length - 1; index++) {
        dayWeekEntries.add(DropdownMenuEntry(
            value: index, label: studentRows[index + 1].text));
      }

      const firstKitchenIndex = 0;

      // ignore: unused_local_variable
      const secondKitchenIndex = 7;

      // ignore: unused_local_variable
      const thirdKitchenIndex = 14;

      /// 각 식당별 학식 목록
      var studentFoodList = {
        firstKitchenIndex:
            studentCols[firstKitchenIndex + selectedDayWeek + 2]
                .innerHtml
                .replaceAll('<br>', '\n'),
        secondKitchenIndex:
          studentCols[secondKitchenIndex + selectedDayWeek + 2]
              .innerHtml
              .replaceAll('<br>', '\n')
      };
      String stampFoodList = '';
      if (foodElement.length >= 2) {
        var stampCols = foodElement[1].getElementsByTagName('td');
        stampFoodList =
            stampCols[selectedDayWeek + 1].innerHtml.replaceAll('<br>', '\n');
      }

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
              '학생식단 | ${studentCols[secondKitchenIndex].text.trim()} | ${studentCols[secondKitchenIndex + 1].text.trim()}',
              detail: Text(
                studentFoodList[secondKitchenIndex] ?? '알 수 없음',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            InfoCard(
              icon: Icons.food_bank_outlined,
              title:
                  '학생식단 | ${studentCols[firstKitchenIndex].text.trim()} | ${studentCols[firstKitchenIndex + 1].text.trim()}',
              detail: Text(
                studentFoodList[firstKitchenIndex] ?? '알 수 없음',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (foodElement.length >= 2)
              InfoCard(
                icon: Icons.food_bank_outlined,
                title:
                    '교직원식단 | ${foodElement[1].getElementsByTagName('td')[0].text.trim()}',
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
