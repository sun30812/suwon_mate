import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suwon_mate/controller/favorite_controller.dart';
import 'package:suwon_mate/model/class_info.dart';
import 'package:suwon_mate/styles/style_widget.dart';

/// 과목에 대한 세부정보를 표시하는 카드형태의 위젯들이 모여있는 페이지
///
/// [classInfo]을 매개변수로 가지는 생성자를 통해 해당 클래스의 객체를 생성할 수 있다.
class FluentOpenClassInfo extends StatelessWidget {
  /// 과목에 해당하는 변수이다.
  final ClassInfo classInfo;

  /// 과목에 대한 세부정보를 표시하는 페이지이다.
  ///
  /// [classInfo]를 통해 과목에 대한 일부 정보를 받아 [AppBar]에 과목 이름을 출력한다던가
  /// 즐겨찾기 버튼을 통해 수행되는 동작에서 요구하는 정보를 받는 역할을 한다.
  /// Fluent 디자인이 적용되어있다.
  ///
  /// ## 같이보기
  /// * [ClassInfo]
  /// * [ClassDetailInfoCard]
  ///
  const FluentOpenClassInfo({required this.classInfo, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(),
      content: ScaffoldPage(
        header: OpenClassHeader(classInfo: classInfo),
        content: OpenClassInfoPage(
          classData: classInfo,
        ),
      ),
    );
  }
}

class OpenClassHeader extends ConsumerWidget {
  const OpenClassHeader({
    Key? key,
    required this.classInfo,
  }) : super(key: key);

  final ClassInfo classInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<ClassInfo> favoriteClassList =
        ref.watch(favoriteControllerNotifierProvider);
    return PageHeader(
      title: Text(classInfo.name),
      commandBar: CommandBar(primaryItems: [
        CommandBarButton(
            icon: Icon(favoriteClassList.contains(classInfo)
                ? FluentIcons.favorite_star_fill
                : FluentIcons.favorite_star),
            label: Text(favoriteClassList.contains(classInfo)
                ? '즐겨찾기에서 제거'
                : '즐겨찾기에 추가'),
            onPressed: () {
              if (favoriteClassList.contains(classInfo)) {
                ref
                    .read(favoriteControllerNotifierProvider.notifier)
                    .removeSubject(classInfo.subjectCode);
              } else {
                ref
                    .read(favoriteControllerNotifierProvider.notifier)
                    .addSubject(classInfo);
              }
            })
      ]),
    );
  }
}

/// 과목에 대한 세부정보를 표시하는 페이지이다.
///
/// [classInfo]를 통해 과목에 대한 정보를 받아서 세부 정보를 화면에 표시해준다.
/// 과목 이름, 학점, 과목 코드등의 정보를 확인할 수 있는 카드 형태로 구성된 페이지가
/// 표시된다.
///
/// ## 같이보기
/// * [ClassInfo]
/// * [ClassDetailInfoCard]
///
class OpenClassInfoPage extends StatefulWidget {
  /// 과목 정보를 담고있는 속성
  final ClassInfo classData;

  /// [classData]로부터 과목 정보를 담아서 과목의 세부 정보를 나타낸다.
  const OpenClassInfoPage({required this.classData, Key? key})
      : super(key: key);

  @override
  State<OpenClassInfoPage> createState() => _OpenClassInfoPageState();
}

class _OpenClassInfoPageState extends State<OpenClassInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ClassDetailInfoCard(
            classInfo: widget.classData,
          ),
        ],
      ),
    );
  }
}
