import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/Settings.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:suwon_mate/Information.dart';
import 'package:suwon_mate/schedule.dart';

import 'openClass.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suwon Mate',
      home: MainPage(),
      routes: {
        '/schedule': (context) => SchedulePage(),
        '/oclass': (context) => OpenClass(),
        '/info': (context) => InfoPage(),
        '/settings': (context) => SettingPage(),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('수원 메이트'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SuwonButton(
                icon: Icons.schedule_outlined,
                buttonName: '학사 일정',
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
                onPressed: () => Navigator.of(context).pushNamed('/info'),
              ),
              SuwonButton(
                  icon: Icons.settings,
                  buttonName: '설정',
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/settings')),
            ],
          ),
        ));
  }
}

class SuwonButton extends StatelessWidget {
  IconData icon;
  String btnName;
  void Function() onPressed;
  SuwonButton({
    Key? key,
    required IconData icon,
    required String buttonName,
    required void Function() onPressed,
  })  : this.icon = icon,
        btnName = buttonName,
        this.onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              Padding(
                padding: EdgeInsets.all(2),
              ),
              Text(
                btnName,
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              minimumSize: MaterialStateProperty.all(Size(90, 40)),
              elevation: MaterialStateProperty.all(2.0),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              )))),
    );
  }
}
