import 'package:flutter/material.dart';
import 'style_widget.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도움말'),
      ),
      body: ListView(
        children: [
          const CardInfo(
              icon: Icons.schedule_outlined,
              title: '학사 일정',
              detail: Text(
                '학교의 일정을 확인할 수 있습니다.',
                style: TextStyle(fontSize: 16.0),
              )),
          CardInfo(
              icon: Icons.date_range,
              title: '개설 강좌 조회',
              detail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '학부와 전공을 선택하여 과목들을 확인할 수 있습니다.\n'
                    '과목을 클릭하면 해당 과목의 상세정보도 확인할 수 있습니다.\n교양 영역의 경우 학부를 교양으로 선택하면 고를 수 있습니다.\n',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              )),
          const CardInfo(
              icon: Icons.notifications_none,
              title: '공지사항',
              detail: Text(
                '학교의 공지사항을 볼 수 있습니다.\n제목을 클릭하면 세부정보를 확인할 수 있습니다.',
                style: TextStyle(fontSize: 16.0),
              )),
          CardInfo(
              icon: Icons.star_outline,
              title: '즐겨찾는 과목(베타)',
              detail: Column(
                children: const [
                  Text(
                    '개설 강좌 조회에서 즐겨찾기에 추가한 과목들만 확인할 수 있습니다.\n'
                    '현재 즐겨찾는 과목 페이지에서 즐겨찾기 제거 시 앱 메인화면으로 나갔다가 들어와야 정상적으로 반영됩니다.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              )),
          CardInfo(
              icon: Icons.favorite_outline_outlined,
              title: '광고 보기',
              detail: Column(
                children: const [
                  Text(
                    '광고배너가 달린 페이지 입니다. 광고 빼고는 아무 기능 없습니다.\n그래도 개발자에게는 도움이 됩니다:)',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              )),
          CardInfo(
              icon: Icons.settings,
              title: '설정',
              detail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '앱과 관련된 설정들을 할 수 있습니다.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.offline_bolt_outlined),
                            Padding(padding: EdgeInsets.only(right: 3.0)),
                            Text(
                              '데이터 절약모드',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        const Text(
                            '데이터를 절약하기 위해 DB 업데이트 확인이나 네트워크 연결이 필요한 공지사항, 학사 일정등의 기능을'
                            ' 비활성화 합니다.')
                      ],
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
