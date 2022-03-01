import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/Settings.dart';
import 'package:suwon_mate/favoriteSubject.dart';
import 'package:suwon_mate/help.dart';
import 'OpenClassInfo.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:suwon_mate/Information.dart';
import 'package:suwon_mate/schedule.dart';
import 'styleWidget.dart';
import 'openClass.dart';

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
      title: '수원 메이트',
      home: MainPage(),
      routes: {
        '/schedule': (context) => SchedulePage(),
        '/oclass': (context) => OpenClass(),
        '/oclass/info': (context) => OpenClassInfo(),
        '/info': (context) => InfoPage(),
        '/favorite': (context) => FavoriteSubjectPage(),
        '/settings': (context) => SettingPage(),
        '/help': (context) => HelpPage()
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

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
              return Text('Error');
            } else {
              return MainMenu(preferences: snapshot.data as SharedPreferences);
            }
          },
        ));
  }
}

class MainMenu extends StatefulWidget {
  SharedPreferences _preferences;
  MainMenu({
    Key? key,
    required SharedPreferences preferences,
  })  : _preferences = preferences,
        super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SuwonButton(
            icon: Icons.help_outline,
            buttonName: '도움말',
            onPressed: () => Navigator.of(context).pushNamed('/help'),
          ),
          SuwonButton(
            icon: Icons.schedule_outlined,
            buttonName: '학사 일정',
            isActivate: isActivated,
            onPressed: () => Navigator.of(context).pushNamed('/schedule'),
          ),
          SuwonButton(
            icon: Icons.date_range,
            buttonName: '개설 강좌 조회',
            onPressed: () => Navigator.of(context).pushNamed('/oclass'),
          ),
          SuwonButton(
            icon: Icons.notifications_none,
            buttonName: '공지사항',
            isActivate: isActivated,
            onPressed: () => Navigator.of(context).pushNamed('/info'),
          ),
          SuwonButton(
              icon: Icons.star_outline,
              buttonName: '즐겨찾는 과목(베타)',
              onPressed: () => Navigator.of(context).pushNamed('/favorite')),
          SuwonButton(
              icon: Icons.settings,
              buttonName: '설정',
              onPressed: () => Navigator.of(context).pushNamed('/settings')),
        ],
      ),
    );
  }
}
