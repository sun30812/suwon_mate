import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/information/info_detail.dart';
import 'package:suwon_mate/subjects/search.dart';
import 'package:suwon_mate/settings.dart';
import 'package:suwon_mate/subjects/favorite_subject.dart';
import 'package:suwon_mate/help.dart';
import 'package:suwon_mate/subjects/profesor_subjects.dart';
import 'subjects/open_class_info.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:suwon_mate/information/info.dart';
import 'package:suwon_mate/schedule.dart';
import 'styles/style_widget.dart';
import 'subjects/open_class.dart';

bool isSupportPlatform = kIsWeb || (!Platform.isWindows && !Platform.isLinux);
void main() async {
  if (!isSupportPlatform) {
    runApp(const App());
  } else {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    runApp(const App());
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '수원 메이트',
      home: const MainPage(),
      routes: {
        '/schedule': (context) => const SchedulePage(),
        '/oclass': (context) => const OpenClass(),
        '/oclass/search': (context) => const SearchPage(),
        '/oclass/info': (context) => const OpenClassInfo(),
        '/professor': (context) => const ProfessorSubjectsPage(),
        '/info': (context) => const InfoPage(),
        '/info/detail': (context) => const InfoDetailPage(),
        '/favorite': (context) => const FavoriteSubjectPage(),
        '/settings': (context) => const SettingPage(),
        '/help': (context) => const HelpPage()
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<SharedPreferences> getSettings() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('수원 메이트'),
        ),
        body: FutureBuilder(
          future: getSettings(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            } else if (snapshot.hasError) {
              return const DataLoadingError();
            } else {
              return MainMenu(preferences: snapshot.data as SharedPreferences);
            }
          },
        ));
  }
}

class MainMenu extends StatefulWidget {
  final SharedPreferences _preferences;
  const MainMenu({
    Key? key,
    required SharedPreferences preferences,
  })  : _preferences = preferences,
        super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  void migrationCheck() {
    if (widget._preferences.containsKey('mySub')) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                children: const [Icon(Icons.warning_amber_rounded), Text('경고')],
              ),
              content: const Text(
                  'DB의 구조가 새롭게 변경되었습니다. 따라서 즐겨찾기 항목을 제외한 나머지 데이터들의 초기화가 필요합니다.\n'
                  '계속하시겠습니까?'),
              actions: [
                TextButton(
                    onPressed: () => SystemNavigator.pop(animated: true),
                    child: const Text('무시(앱 종료)')),
                TextButton(
                    onPressed: (() async {
                      SharedPreferences _pref =
                          await SharedPreferences.getInstance();
                      _pref.remove('mySub');
                      _pref.remove('myDp');
                      _pref.remove('class');
                      _pref.remove('version');
                      Navigator.pop(context);
                    }),
                    child: const Text('확인')),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isActivated = true;
    if (widget._preferences.containsKey('settings')) {
      setState(() {
        isActivated = !(jsonDecode((widget._preferences.getString('settings'))!)
            as Map)['offline'];
      });
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: isSupportPlatform
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            const NotSupportPlatformMessage(),
            Column(
              children: [
                SuwonButton(
                  icon: Icons.help_outline,
                  buttonName: '도움말',
                  onPressed: () => Navigator.of(context).pushNamed('/help'),
                ),
                SuwonButton(
                  icon: Icons.schedule_outlined,
                  buttonName: '학사 일정',
                  isActivate: isActivated && !kIsWeb,
                  onPressed: () => Navigator.of(context).pushNamed('/schedule'),
                ),
                // TODO: 전화번호 찾기 기능은 구상중이며 사라질 수 있습니다.
                // const SuwonButton(
                //     icon: Icons.call_outlined,
                //     buttonName: '전화번호 찾기',
                //     onPressed: null),
                SuwonButton(
                  isActivate: isSupportPlatform,
                  icon: Icons.date_range,
                  buttonName: '개설 강좌 조회',
                  onPressed: () {
                    migrationCheck();
                    Navigator.of(context).pushNamed('/oclass');
                  },
                ),
                SuwonButton(
                  icon: Icons.notifications_none,
                  buttonName: '공지사항',
                  isActivate: isActivated && !kIsWeb,
                  onPressed: () => Navigator.of(context).pushNamed('/info'),
                ),
                SuwonButton(
                    isActivate: isSupportPlatform,
                    icon: Icons.star_outline,
                    buttonName: '즐겨찾는 과목(베타)',
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/favorite')),
                SuwonButton(
                    icon: Icons.settings,
                    buttonName: '설정',
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/settings')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
