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
                    '개설 강좌 목록을 가져오지만 학교 서버가 아닌 자체 서버에서 받아오기 때문에 항상 최신이 아닙니다.\n'
                        '설정 메뉴에서 언제 업데이트된 DB인지 확인 가능합니다.\n'
                    '강좌목록은 클릭이 가능하며, 아이콘으로 된 버튼은 누르고 있으면 설명이 나옵니다.\n'
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
              title: '즐겨찾는 과목(베타)',
              detail: Column(
                children: const [
                  Text(
                    '개설 강좌 조회에서 즐겨찾기에 추가한 과목들만 확인할 수 있습니다.\n'
                        '현재 즐겨찾기 삭제 시 앱 메인화면으로 나갔다가 들어와야 정상적으로 반영됩니다.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              )),
          CardInfo(
              icon: Icons.favorite_outline_outlined,
              title: '기부하기',
              detail: Column(
                children: const [
                  Text(
                    '광고배너가 달린 페이지 입니다. 광고 빼고는 아무 기능 없습니다.',
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
