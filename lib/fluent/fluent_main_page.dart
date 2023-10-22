import 'package:fluent_ui/fluent_ui.dart';
import 'package:suwon_mate/fluent/fluent_schedule.dart';
import 'package:suwon_mate/fluent/fluent_settings.dart';
import 'package:suwon_mate/food/fluent_food_info.dart';
import 'package:suwon_mate/help.dart';
import 'package:suwon_mate/information/fluent_notice_page.dart';
import 'package:suwon_mate/subjects/favorite_subject.dart';
import 'package:suwon_mate/subjects/fluent/fluent_open_class.dart';

class FluentMainPage extends StatefulWidget {
  final String appTitle;

  const FluentMainPage({required this.appTitle, Key? key}) : super(key: key);

  @override
  State<FluentMainPage> createState() => _FluentMainPageState();
}

class _FluentMainPageState extends State<FluentMainPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
          title: Text(widget.appTitle), automaticallyImplyLeading: false),
      pane: NavigationPane(
          selected: index,
          onChanged: (newValue) => setState(() {
                index = newValue;
              }),
          size: const NavigationPaneSize(openMinWidth: 130, openMaxWidth: 200),
          items: [
            PaneItem(
                icon: const Icon(FluentIcons.help),
                title: const Text('도움말'),
                body: const HelpPage()),
            PaneItemSeparator(),
            PaneItemHeader(header: const Text('학교 정보')),
            PaneItem(
                icon: const Icon(FluentIcons.schedule_event_action),
                title: const Text('학사일정'),
                body: const FluentSchedulePage()),
            PaneItem(
                icon: const Icon(FluentIcons.info),
                title: const Text('공지사항'),
                body: const FluentNoticePage()),
            PaneItem(
                icon: const Icon(FluentIcons.diet_plan_notebook),
                title: const Text('학식조회'),
                body: const FluentFoodInfoPage()),
            PaneItemSeparator(),
            PaneItem(
                icon: const Icon(FluentIcons.favorite_star),
                title: const Text('즐겨찾는 과목'),
                body: const FavoriteSubjectPage()),
            PaneItem(
                icon: const Icon(FluentIcons.date_time),
                title: const Text('개설 강좌 조회'),
                body: FluentOpenClass(
                  myDept: '컴퓨터학부',
                  myMajor: '컴퓨터SW',
                  myGrade: '4학년',
                  settingsData: {'offline': false},
                  quickMode: false,
                )),
            PaneItem(
                icon: const Icon(FluentIcons.settings),
                title: const Text('설정'),
                body: const FluentSettingsPage()),
          ]),
    );
  }
}
