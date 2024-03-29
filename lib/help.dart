import 'package:flutter/material.dart';

import 'styles/style_widget.dart';

/// 도움말 페이지이다. 각 메뉴에 대한 설명을 확인할 수 있는 페이지이다.
///
/// 메인 화면에서 도움말을 누른 경우 보여지는 페이지이며, 각 항목에 대한 설명은 [InfoCard]위젯을 통해 보여준다.
///
/// ## 같이보기
/// * [InfoCard]
class HelpPage extends StatelessWidget {
  /// 도움말 페이지이다. 각 메뉴에 대한 설명을 확인할 수 있는 페이지이다.
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('도움말'),
      ),
      body: ListView(
        children: const [
          InfoCard(
              icon: Icons.schedule_outlined,
              title: '학사 일정',
              detail: Text(
                '학교의 일정을 확인할 수 있습니다.',
                style: TextStyle(fontSize: 16.0),
              )),
          InfoCard(
              icon: Icons.date_range,
              title: '개설 강좌 조회',
              detail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '과목에 대한 정보를 확인할 수 있습니다. 강의자의 연락사항 정보는 로그인 시 확인이 가능합니다.\n교양 영역의 경우 학부를 교양으로 선택하면 고를 수 있습니다.\n',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              )),
          InfoCard(
              icon: Icons.food_bank_outlined,
              title: '학식 조회 (미리보기)',
              detail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '금주의 식단을 확인할 수 있습니다. 이 기능은 아직 불안정 할 수 있습니다.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              )),
          InfoCard(
              icon: Icons.notifications_none,
              title: '공지사항',
              detail: Text(
                '학교의 공지사항을 볼 수 있습니다.\n제목을 클릭하면 세부정보를 확인할 수 있습니다.',
                style: TextStyle(fontSize: 16.0),
              )),
          InfoCard(
              icon: Icons.star_outline,
              title: '즐겨찾는 과목',
              detail: Column(
                children: [
                  Text(
                    '개설 강좌 조회에서 즐겨찾기에 추가한 과목들만 확인할 수 있습니다.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              )),
          InfoCard(
              icon: Icons.settings_outlined,
              title: '설정',
              detail: Text(
                '로그인을 하거나 앱과 관련된 설정들을 변경할 수 있습니다.',
                style: TextStyle(fontSize: 16.0),
              )),
        ],
      ),
    );
  }
}
