import 'package:firebase_database/firebase_database.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/controller/settings_controller.dart';
import 'package:suwon_mate/styles/style_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class StudentInfoSettingWidget extends StatefulWidget {
  const StudentInfoSettingWidget({Key? key}) : super(key: key);

  @override
  State<StudentInfoSettingWidget> createState() =>
      _StudentInfoSettingWidgetState();
}

class _StudentInfoSettingWidgetState extends State<StudentInfoSettingWidget> {
  /// 현재 학부를 나타내는 변수이다.
  late String _myDepartment;

  /// 현재 학과를 나타내는 변수이다.
  late String _myMajor;

  /// 현재 학년을 나타내는 변수이다.
  late String _grade;

  /// 학부에 관한 `DropdownMenuEntry`리스트
  List<ComboBoxItem<String>> departmentDropdownList = [];

  /// 학부의 전공에 관한 `DropdownMenuEntry`리스트
  List<ComboBoxItem<String>> majorDropdownList = [];

  var getDepartment = FirebaseDatabase.instance.ref('departments').once();

  /// 학년 정보에 관한 `ComboBoxItem`리스트
  final List<ComboBoxItem<String>> gradeList = [
    const ComboBoxItem<String>(value: '1학년', child: Text('1학년')),
    const ComboBoxItem<String>(value: '2학년', child: Text('2학년')),
    const ComboBoxItem<String>(value: '3학년', child: Text('3학년')),
    const ComboBoxItem<String>(value: '4학년', child: Text('4학년')),
  ];

  /// 앱 버전 확인을 위해 사용되는 변수
  late PackageInfo packageInfo;

  /// 현재 앱의 설정 값을 가져오는 메서드이다.
  Future<SharedPreferences> getSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref;
  }

  @override
  void initState() {
    super.initState();
    getSettings().then((pref) {
      _myDepartment = pref.getString('myDept') ?? '컴퓨터학부';
      _myMajor = pref.getString('mySubject') ?? '학부 공통';
      _grade = pref.getString('myGrade') ?? '1학년';
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DatabaseEvent>(
      future: getDepartment,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const InfoCard(
              icon: FluentIcons.school_data_sync_logo,
              title: '학생 정보',
              detail: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProgressBar(),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('개설 강좌메뉴에서 기본으로 보여질 학부 및 학년을 선택합니다.'),
                    ),
                  ]));
        } else if (snapshot.hasError) {
          return DataLoadingError(errorMessage: snapshot.error);
        } else {
          var data = snapshot.data?.snapshot.value as Map;
          departmentDropdownList.clear();
          for (var department in data.keys) {
            departmentDropdownList.add(ComboBoxItem(
                value: department.toString(),
                child: Text(department.toString())));
          }
          majorDropdownList.clear();
          majorDropdownList.add(const ComboBoxItem(
            value: '학부 공통',
            child: Text('학부 공통'),
          ));
          for (var major in data[_myDepartment]) {
            majorDropdownList.add(ComboBoxItem(
                value: major.toString(), child: Text(major.toString())));
          }
          return InfoCard(
              icon: FluentIcons.org,
              title: '학생 정보',
              detail: Center(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('개설 강좌메뉴에서 기본으로 보여질 학부 및 학년을 선택합니다.'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ComboBox<String>(
                          items: departmentDropdownList,
                          onChanged: (String? value) {
                            setState(() {
                              _myDepartment = value!;
                              _myMajor = '학부 공통';
                              majorDropdownList.clear();
                              majorDropdownList.add(const ComboBoxItem(
                                value: '학부 공통',
                                child: Text('학부 공통'),
                              ));
                              for (var major in data[_myDepartment]) {
                                majorDropdownList.add(ComboBoxItem(
                                    value: major.toString(),
                                    child: Text(major.toString())));
                              }
                            });
                          },
                          placeholder: const Text('기본 학부'),
                          value: _myDepartment),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ComboBox<String>(
                              items: majorDropdownList,
                              placeholder: const Text('기본 전공'),
                              onChanged: (String? value) {
                                setState(() {
                                  _myMajor = value!;
                                });
                              },
                              value: _myMajor),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ComboBox<String>(
                              items: gradeList,
                              onChanged: (value) {
                                setState(() {
                                  _grade = value!;
                                });
                              },
                              value: _grade),
                        ),
                      ],
                    ),
                  ],
                ),
              ));
        }
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('myDept', _myDepartment);
    pref.setString('mySubject', _myMajor);
    pref.setString('myGrade', _grade);
  }
}

class FunctionSettingWidget extends ConsumerWidget {
  const FunctionSettingWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var functionSetting = ref.watch(functionSettingControllerNotifierProvider);
    if (ref
        .read(functionSettingControllerNotifierProvider.notifier)
        .isLoading) {
      return const InfoCard(
          icon: FluentIcons.settings,
          title: '기능 설정',
          detail: Center(
            child: ProgressRing(),
          ));
    } else {
      return InfoCard(
          icon: FluentIcons.settings,
          title: '기능 설정',
          detail: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('각 항목을 클릭하면 설명을 볼 수 있습니다.'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Icon(FluentIcons.plug_disconnected),
                        ),
                        Text('데이터 절약 모드'),
                      ],
                    ),
                    ToggleSwitch(
                        checked: functionSetting.offline,
                        onChanged: (newValue) {
                          ref
                              .read(functionSettingControllerNotifierProvider
                                  .notifier)
                              .onOfflineSettingChanged(newValue);
                        }),
                  ],
                ),
              ),
            ],
          ));
    }
  }
}

class FluentSettingsPage extends StatelessWidget {
  const FluentSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('설정'),
      ),
      content: GridView(
        shrinkWrap: true,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        children: [
          const LoginWidget(),
          const StudentInfoSettingWidget(),
          const FunctionSettingWidget(),
          InfoCard(
            icon: FluentIcons.reset,
            title: '초기화 메뉴',
            detail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Button(
                    onPressed: () async {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) => SuwonDialog(
                              icon: FluentIcons.reset,
                              title: '전체 데이터를 초기화 할까요?',
                              content: const Text(
                                  '학생 정보를 포함한 앱의 모든 데이터를 초기화합니다. 계속하시겠습니까?(이 작업은 되돌릴 수 없습니다.)'),
                              isDestructive: true,
                              onPressed: () {
                                SharedPreferences.getInstance()
                                    .then((value) => value.clear());
                                Navigator.of(context).pop();
                              }));
                    },
                    style: ButtonStyle(
                      backgroundColor: ButtonState.all(Colors.red),
                    ),
                    child: const Text(
                      '전체 데이터 초기화',
                    )),
                Button(
                    onPressed: () async {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return SuwonDialog(
                              icon: FluentIcons.update_restore,
                              title: 'DB 데이터를 다시 받을까요?',
                              content: const Text(
                                  '서버에서 최신 DB의 데이터를 다시 받습니다. 계속하시겠습니까?'),
                              onPressed: () {
                                SharedPreferences.getInstance()
                                    .then((value) => value.remove('db_ver'));
                                Navigator.of(context).pop();
                              },
                            );
                          });
                    },
                    child: const Text(
                      'DB 데이터 다시 받기',
                    )),
              ],
            ),
          ),
          InfoCard(
              icon: FluentIcons.help,
              title: '문의하기',
              detail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      '문제가 있는 부분이나 기능 제안은 이메일로 보내셔도 좋고 깃허브에 issue를 열어도 됩니다.'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(FluentIcons.mail),
                        const Padding(padding: EdgeInsets.only(right: 8.0)),
                        HyperlinkButton(
                            onPressed: (() async {
                              await launchUrlString(
                                  'mailto:orgsun30812+suwon_mate_github@gmail.com');
                            }),
                            child: const Text('이메일 보내기')),
                      ],
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
