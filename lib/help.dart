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
                    '본인 전공을 고르시면 그에 맞는 과목이 나옵니다. 과목을 누르면 더욱 자세히 볼 수 있습니다.\n'
                    '아이콘으로 된 버튼은 누르고 있으면 설명이 나옵니다.\n'
                    '교양 영역의 경우 과를 교양으로 선택하면 고를 수 있습니다.\n',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    '주의사항: 학부 공용 과목은 학부를 선택해야 나옵니다.',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  )
                ],
              )),
          const CardInfo(
              icon: Icons.notifications_none,
              title: '공지사항',
              detail: Text(
                '학교의 공지사항을 볼 수 있습니다.\n제목을 클릭하면 세부정보가 나오며 '
                '첨부파일을 받기 위해 브라우저로 이동이 필요한 경우 브라우저로 이동 버튼을 누르면 됩니다.',
                style: TextStyle(fontSize: 16.0),
              )),
          CardInfo(
              icon: Icons.star_outline,
              title: '즐겨찾는 과목',
              detail: Column(
                children: const [
                  Text(
                    '개설 강좌 조회에서 즐겨찾기에 추가한 과목들만 확인할 수 있습니다.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              )),
          const CardInfo(
              icon: Icons.settings,
              title: '설정',
              detail: Text(
                '개설 강좌 조회시 처음에 표시할 학년이나 전공을 설정할 수 있습니다.\n'
                '다양한 설정들이 계속 추가될 예정입니다.\n'
                '\n데이터 절약 모드: 인터넷 연결이 필요한 대부분의 기능을 차단합니다.(DB업데이트, 공지사항, 학사일정)\n'
                'DB가 없는 경우에만 다운로드 하고 존재하는 경우 버전 확인도 진행하지 않습니다. 이 설정은 앱을 재시작 해야 완전히 적용됩니다.',
                style: TextStyle(fontSize: 16.0),
              )),
        ],
      ),
    );
  }
}
