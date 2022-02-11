import 'package:flutter/material.dart';
import 'styleWidget.dart';

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
          CardInfo(
              icon: Icons.schedule_outlined,
              title: '학사 일정',
              detail: const Text(
                '학교의 일정을 확인할 수 있습니다.',
                style: TextStyle(fontSize: 16.0),
              )),
          CardInfo(
              icon: Icons.date_range,
              title: '개설 강좌 조회',
              detail: const Text(
                '본인 전공을 고르시면 그에 맞는 과목이 나옵니다. 과목을 누르면 더욱 자세히 볼 수 있습니다.\n'
                '주의사항: 학부 공용 과목은 학부를 선택해야 나옵니다.',
                style: TextStyle(fontSize: 16.0),
              )),
          CardInfo(
              icon: Icons.notifications_none,
              title: '공지사항',
              detail: const Text(
                '학교의 공지사항을 볼 수 있습니다.',
                style: TextStyle(fontSize: 16.0),
              )),
          CardInfo(
              icon: Icons.star_outline,
              title: '즐겨찾는 과목(베타)',
              detail: Column(
                children: [
                  Card(
                    color: Colors.amber,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_outlined),
                          Text('주의: 이 기능은 베타상태입니다.')
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    '개설 강좌 조회에서 즐겨찾기에 추가한 과목들만 확인할 수 있습니다.\n'
                        '베타 상태에서는 즐겨찾는 과목메뉴에 들어가서 즐겨찾기를 해제한 경우 즐겨찾기 목록에 '
                        '과목이 여전히 남아 있습니다. \n완전히 메인 화면으로 나갔다가 오면 사라집니다.',
                    style: TextStyle(fontSize: 16.0),
                  ),

                ],
              )),
          CardInfo(
              icon: Icons.settings,
              title: '설정',
              detail: const Text(
                '개설 강좌 조회시 처음에 표시할 학년이나 전공을 설정할 수 있습니다.\n'
                    '다양한 설정들이 계속 추가될 예정입니다.',
                style: TextStyle(fontSize: 16.0),
              )),
        ],
      ),
    );
  }
}
