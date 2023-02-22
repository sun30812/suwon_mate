import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/help.dart';
import 'package:suwon_mate/information/notice_detail_page.dart';
import 'package:suwon_mate/information/notice_page.dart';
import 'package:suwon_mate/model/class_info.dart';
import 'package:suwon_mate/model/notice.dart';
import 'package:suwon_mate/schedule.dart';
import 'package:suwon_mate/settings.dart';
import 'package:suwon_mate/subjects/favorite_subject.dart';
import 'package:suwon_mate/subjects/search.dart';

import 'firebase_options.dart';
import 'styles/style_widget.dart';
import 'subjects/open_class.dart';
import 'subjects/open_class_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: App()));
}

/// 앱에서 사용되는 페이지들을 정의하고 앱 기본 디자인이나 테마를 정의하는 부분이다.
class App extends ConsumerWidget {
  App({Key? key}) : super(key: key);

  /// 앱의 각 페이지를 나타낸다.
  ///
  /// 앱의 각 페이지를 정의해서 페이지 이동을 가능하게 한다.
  ///
  /// ## 같이보기
  /// * [GoRoute]
  /// * [GoRouter]
  final _routes = GoRouter(routes: <RouteBase>[
    GoRoute(
        path: '/',
        builder: (context, state) => const MainPage(),
        routes: <RouteBase>[
          GoRoute(
            path: 'schedule',
            builder: (context, state) => const SchedulePage(),
          ),
          GoRoute(
              path: 'notice',
              builder: (context, state) => const NoticePage(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'detail',
                  builder: (context, state) =>
                      NoticeDetailPage(notice: state.extra as Notice),
                )
              ]),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingPage(),
          ),
          GoRoute(path: 'help', builder: (context, state) => const HelpPage())
        ]),
    GoRoute(
        path: '/oclass',
        builder: (context, state) {
          final params = state.extra as List;
          return OpenClass(
            myDept: params[0],
            myMajor: params[1],
            myGrade: params[2],
            settingsData: params[3] != null
                ? jsonDecode(params[3]) as Map<String, dynamic>
                : {
                    'offline': false,
                    'liveSearch': true,
                    'liveSearchCount': 0.0
                  },
            quickMode: params[4] ?? false,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'search',
            builder: (context, state) {
              final List params = state.extra as List;
              return SearchPage(
                  classList: params[0],
                  liveSearch: params[1]['liveSearch'] ?? true,
                  liveSearchCount: params[1]['liveSearchCount'] ?? 0.0);
            },
          ),
          GoRoute(
            path: 'info',
            builder: (context, state) => OpenClassInfo(
              classInfo: state.extra as ClassInfo,
            ),
          ),
        ])
  ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
        theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color.fromARGB(255, 0, 54, 112),
            navigationBarTheme: const NavigationBarThemeData().copyWith(
              backgroundColor: const Color.fromARGB(255, 0, 54, 112),
              surfaceTintColor: const Color.fromARGB(255, 0, 54, 112),
              indicatorColor: const Color.fromARGB(255, 0, 54, 112),
              iconTheme: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const IconThemeData(color: Color.fromARGB(255, 233, 184, 0));
                }
              })
            ),),
        title: '수원 메이트',
        routerConfig: _routes);
  }
}

/// 앱을 실행할 때 제일 먼저 나타나는 페이지이다.
class MainPage extends StatefulWidget {
  /// 앱을 실행할 때 제일 먼저 나타나는 페이지이다.
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// 앱 하단에 표시되는 버튼
  List<Widget> shortcuts = const [
    NavigationDestination(
        icon: Icon(Icons.apps_outlined), label: '메인', tooltip: '메인'),
    NavigationDestination(
        icon: Icon(Icons.schedule_outlined), label: '학사 일정', tooltip: '학사 일정'),
    NavigationDestination(
        icon: Icon(Icons.star_border_outlined),
        selectedIcon: Icon(Icons.star),
        label: '즐겨찾기',
        tooltip: '즐겨찾는 과목'),
    NavigationDestination(
        icon: Icon(Icons.notifications_none_outlined),
        selectedIcon: Icon(Icons.notifications),
        label: '공지사항',
        tooltip: '학교 공지사항'),
  ];

  /// 앱 하단의 몇번째 버튼이 눌렸는지에 대한 정보를 가진 변수
  int _pageIndex = 0;

  /// 설정 저장소로부터 설정값을 가져오는 메서드이다. 앱 설정에 대한 값을 불러올 때 사용된다.
  Future<SharedPreferences> getSettings() async {
    var remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setDefaults(const {"quick_mode": false});
    await remoteConfig.fetchAndActivate();
    return SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('수원 메이트${kIsWeb ? ' (Web버전)' : ''}'),
          actions: [
            IconButton(
                onPressed: () async {
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  pref.clear();
                },
                icon: const Icon(Icons.clear_all))
          ],
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.grey[300],
          destinations: shortcuts,
          selectedIndex: _pageIndex,
          onDestinationSelected: (value) => setState(() {
            _pageIndex = value;
          }),
        ),
        body: tabPageBody());
  }

  /// 앱에 위차한 하단 탭에서 각 항목을 클릭할 때 이동할 페이지를 정의한다.
  ///
  /// 클래스의 [_pageIndex]속성를 통해 현재 어느 탭을 선택했는지 판단해서 적절한 페이지를 반환한다.
  Widget tabPageBody() {
    switch (_pageIndex) {
      case 0:
        return FutureBuilder(
          future: getSettings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (snapshot.hasError) {
              return DataLoadingError(
                errorMessage: snapshot.error,
              );
            } else {
              return MainMenu(preferences: snapshot.data as SharedPreferences);
            }
          },
        );
      case 1:
        return const SchedulePage();
      case 2:
        return const FavoriteSubjectPage();
      default:
        return FutureBuilder(
            future: getSettings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              } else if (snapshot.hasError) {
                return DataLoadingError(
                  errorMessage: snapshot.error,
                );
              } else {
                if ((snapshot.data as SharedPreferences)
                    .containsKey('settings')) {
                  Map<String, dynamic> functionSetting = jsonDecode(
                      (snapshot.data as SharedPreferences)
                          .getString('settings')!);
                  bool saveMode = functionSetting['offline'] ?? false;
                  if (saveMode) {
                    return const DataSaveAlert();
                  } else {
                    return const NoticePage();
                  }
                }
                return const NoticePage();
              }
            });
    }
  }
}

/// 앱 하단의 메인을 누른 경우 나타나는 메인 화면이다.
///
/// 도움말과 개설 강좌 조회 등이 포함된 메인 화면을 나타낸다.
class MainMenu extends StatefulWidget {
  /// 앱에서 필요한 설정값에 관한 속성
  final SharedPreferences _preferences;

  /// 앱 하단의 메인을 누른 경우 나타나는 메인 화면
  ///
  /// [preferences]에 앱의 [SharedPreferences]저장소를 지정해서 앱 설정을 불러올 수 있도록 해야한다.
  const MainMenu({
    Key? key,
    required SharedPreferences preferences,
  })  : _preferences = preferences,
        super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  /// 이전 버전의 수원 메이트 앱에서 업데이트 한 경우 DB정보를 갱신할 필요가 있다.
  /// 그 여부를 판단하기 위해 만든 메서드이다.
  ///
  /// 현재 저장된 DB의 구조가 이전버전과 호환되어서 현재 버전에서 사용할 수 없는 경우를 감지한다.
  /// 감지된 경우에는 안내창을 띄우고 현재 버전에 맞는 DB로 재구성한다.
  void migrationCheck() {
    if (widget._preferences.containsKey('mySub') ||
        widget._preferences.containsKey('class') ||
        widget._preferences.containsKey('favoritesMap')) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                children: const [Icon(Icons.warning_amber_rounded), Text('경고')],
              ),
              content:
                  const Text('DB의 구조가 새롭게 변경되었습니다. 이 앱의 모든 데이터들의 초기화가 필요합니다.\n'
                      '계속하시겠습니까?'),
              actions: [
                TextButton(
                    onPressed: () => SystemNavigator.pop(animated: true),
                    child: const Text('무시(앱 종료)')),
                TextButton(
                    onPressed: (() async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      pref.clear();
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    }),
                    child: const Text('확인')),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SuwonSquareButton(
                  icon: Icons.help_outline,
                  buttonName: '도움말',
                  onPressed: () => context.push('/help'),
                ),
                if (FirebaseRemoteConfig.instance.getBool('quick_mode')) ...[
                  SuwonSquareButton(
                    icon: Icons.date_range,
                    buttonName: '빠른 개설 강좌 조회',
                    onPressed: () async {
                      migrationCheck();
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      if (mounted) {
                        context.push('/oclass', extra: [
                          '컴퓨터학부',
                          '전체',
                          '1학년',
                          pref.getString('settings'),
                          true
                        ]);
                      }
                    },
                  ),
                ] else ...[
                  SuwonSquareButton(
                    icon: Icons.date_range,
                    buttonName: '개설 강좌 조회',
                    onPressed: () async {
                      migrationCheck();
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      if (mounted) {
                        context.push('/oclass', extra: [
                          pref.getString('myDept') ?? '컴퓨터학부',
                          pref.getString('mySubject') ?? '학부 공통',
                          pref.getString('myGrade') ?? '1학년',
                          pref.getString('settings'),
                          false
                        ]);
                      }
                    },
                  ),
                ],
                SuwonSquareButton(
                  icon: Icons.settings_outlined,
                  buttonName: '설정',
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
