import 'package:flutter/material.dart';
import 'styles/style_widget.dart';

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
          const CardInfo(
              icon: Icons.settings_outlined,
              title: '설정',
              detail: Text(
                '앱과 관련된 설정들을 변경할 수 있습니다.',
                style: TextStyle(fontSize: 16.0),
              )),
        ],
      ),
    );
  }
}
