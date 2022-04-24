import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/donation/donation_page.dart';
import 'package:suwon_mate/help.dart';
import 'package:suwon_mate/information/info.dart';
import 'package:suwon_mate/information/info_detail.dart';
import 'package:suwon_mate/schedule.dart';
import 'package:suwon_mate/settings.dart';
import 'package:suwon_mate/subjects/favorite_subject.dart';
import 'package:suwon_mate/subjects/profesor_subjects.dart';
import 'package:suwon_mate/subjects/search.dart';
import 'firebase_options.dart';
import 'styles/style_widget.dart';
import 'subjects/open_class.dart';
import 'subjects/open_class_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData().copyWith(
        useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[300]!,
          appBarTheme:
              const AppBarTheme(color: Color.fromARGB(255, 0, 54, 112)),
          colorScheme: ThemeData().colorScheme.copyWith(
              secondary: const Color.fromARGB(255, 0, 54, 112),
              onSecondary: const Color.fromARGB(255, 0, 54, 112),
              primary: const Color.fromARGB(255, 0, 54, 112))),
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
        '/donation': (context) => const DonationPage(),
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
  List<BottomNavigationBarItem> shortcuts = const [
    BottomNavigationBarItem(icon: Icon(Icons.apps), label: '메인'),
    BottomNavigationBarItem(icon: Icon(Icons.schedule_outlined), label: '학사 일정', tooltip: '학사 일정'),
    BottomNavigationBarItem(icon: Icon(Icons.star_border_outlined), label: '즐겨찾기', tooltip: '즐겨찾는 과목(베타)'),
    BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined), label: '공지사항', tooltip: '학교 공지사항'),
    BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: '설정'),
  ];
  int _pageIndex = 0;
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
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.grey[300],
          items: shortcuts,
          currentIndex: _pageIndex,
          onTap: (value) => setState(() {
            _pageIndex = value;
          }),
        ),
        body: tabPageBody());
  }

  Widget tabPageBody() {
    switch(_pageIndex) {
      case 0:
        return FutureBuilder(
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
        );
      case 1:
        return const SchedulePage();
      case 2:
        return const FavoriteSubjectPage();
      case 3:
        return FutureBuilder(
          future: getSettings(),
            builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else if (snapshot.hasError) {
            return const DataLoadingError();
          } else {
            if ((snapshot.data as SharedPreferences).containsKey('settings')) {
              Map<String, dynamic> functionSetting = jsonDecode(
                  (snapshot.data as SharedPreferences)
                      .getString('settings')!);
              bool saveMode = functionSetting['offline'] ?? false;
              if (saveMode) {
                return const DatasaveAlert();
              } else {
                return const InfoPage();
              }
            }
            return const InfoPage();
          }
        });
      default:
        return const SettingPage();
    }
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
    // bool isActivated = true;
    // if (widget._preferences.containsKey('settings')) {
    //   setState(() {
    //     isActivated = !(jsonDecode((widget._preferences.getString('settings'))!)
    //         as Map)['offline'];
    //   });
    // }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const NotSupportPlatformMessage(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SuwonSquareButton(
                  icon: Icons.help_outline,
                  buttonName: '도움말',
                  onPressed: () => Navigator.of(context).pushNamed('/help'),
                ),
                SuwonSquareButton(
                  icon: Icons.date_range,
                  buttonName: '개설 강좌 조회',
                  onPressed: () => Navigator.of(context).pushNamed('/oclass'),
                ),
                SuwonSquareButton(
                    icon: Icons.favorite_border_outlined,
                    buttonName: '광고 보기',
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/donation')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
