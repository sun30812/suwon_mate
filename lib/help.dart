import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:suwon_mate/styles/theme.dart';

import 'styles/style_widget.dart';

/// 도움말 페이지이다. 각 메뉴에 대한 설명을 확인할 수 있는 페이지이다.
///
/// 메인 화면에서 도움말을 누른 경우 보여지는 페이지이며, 각 항목에 대한 설명은 [InfoCard]위젯을 통해 보여준다.
/// Desktop 플랫폼일 때 디자인과 모바일 플랫폼일 때 디자인이 해당 파일에 다 작성되어있다.
///
/// ## 같이보기
/// * [InfoCard]
class HelpPage extends StatelessWidget {
  /// 도움말 페이지이다. 각 메뉴에 대한 설명을 확인할 수 있는 페이지이다.
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var helpCards = [
      InfoCard(
          icon: scheduleIcon(),
          title: '학사일정',
          detail: const Text(
            '학교의 일정을 확인할 수 있습니다.',
            style: TextStyle(fontSize: 16.0),
          )),
      InfoCard(
          icon: checkClassIcon(),
          title: '개설 강좌 조회',
          detail: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '과목에 대한 정보를 확인할 수 있습니다. 강의자의 연락사항 정보는 로그인 시 확인이 가능합니다.\n교양 영역의 경우 학부를 교양으로 선택하면 고를 수 있습니다.\n',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          )),
      InfoCard(
          icon: checkFoodIcon(),
          title: '학식 조회 (미리보기)',
          detail: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '금주의 식단을 확인할 수 있습니다. 이 기능은 아직 불안정 할 수 있습니다.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          )),
      InfoCard(
          icon: noticeIcon(),
          title: '공지사항',
          detail: const Text(
            '학교의 공지사항을 볼 수 있습니다.\n제목을 클릭하면 세부정보를 확인할 수 있습니다.',
            style: TextStyle(fontSize: 16.0),
          )),
      InfoCard(
          icon: favoriteSubjectIcon(),
          title: '즐겨찾는 과목',
          detail: const Column(
            children: [
              Text(
                '개설 강좌 조회에서 즐겨찾기에 추가한 과목들만 확인할 수 있습니다.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          )),
      InfoCard(
          icon: settingsIcon(),
          title: '설정',
          detail: const Text(
            '로그인을 하거나 앱과 관련된 설정들을 변경할 수 있습니다.',
            style: TextStyle(fontSize: 16.0),
          )),
    ];
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return fluent.ScaffoldPage(
        header: const fluent.PageHeader(
          title: Text('도움말'),
        ),
        content: Column(
          children: [
            if (!(Platform.isAndroid || Platform.isIOS))
              const fluent.InfoBar(
                  severity: fluent.InfoBarSeverity.warning,
                  isLong: true,
                  title: Text('일부 기능이 올바르게 동작하지 않을 수 있음'),
                  content: Text('''
현재 데스크톱 버전은 개발중 입니다. 디자인이 깨지거나, 느리게 동작하거나, 알 수 없는 오류가 발생하는 등 예기치 못한 일이 발생할 수 있습니다.
현재 버전의 프로그램은 개발 및 테스트용으로만 사용하기를 권장합니다.''')),
            Flexible(
              child: fluent.GridView(
                gridDelegate: fluent.SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width ~/ 300),
                children: helpCards,
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('도움말'),
      ),
      body: ListView(
        children: helpCards,
      ),
    );
  }
}
