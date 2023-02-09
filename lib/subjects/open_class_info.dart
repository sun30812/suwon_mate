import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suwon_mate/model/class_info.dart';
import 'package:suwon_mate/styles/style_widget.dart';
import '../controller/favorite_controller.dart';

/// 과목에 대한 세부정보를 표시하는 카드형태의 위젯들이 모여있는 페이지
///
/// [classInfo]을 매개변수로 가지는 생성자를 통해 해당 클래스의 객체를 생성할 수 있다.
class OpenClassInfo extends StatelessWidget {
  /// 과목에 해당하는 변수이다.
  final ClassInfo classInfo;

  /// 과목에 대한 세부정보를 표시하는 페이지이다.
  ///
  /// [classInfo]를 통해 과목에 대한 일부 정보를 받아 [AppBar]에 과목 이름을 출력한다던가
  /// 즐겨찾기 버튼을 통해 수행되는 동작에서 요구하는 정보를 받는 역할을 한다.
  ///
  /// ## 같이보기
  /// * [ClassInfo]
  /// * [ClassDetailInfoCard]
  ///
  const OpenClassInfo({required this.classInfo, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classInfo.name),
      ),
      body: OpenClassInfoPage(
        classData: classInfo,
      ),
      floatingActionButton: FavoriteButton(
        classData: classInfo,
      ),
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

/// 즐겨찾기 버튼에 해당하는 위젯이다.
///
/// 즐겨찾기 등록 여부에 따라 다른 디자인을 제공하고 어떤 문제로 인해 즐겨찾기 기능을 사용할 수 없을 때
/// 누를 수 없도록 하는 등의 기능을 제공한다.
class FavoriteButton extends ConsumerWidget {
  /// 과목에 대한 정보를 가진 속성
  final ClassInfo _classData;

  /// 과목 세부정보 페이지에서 우하단에 위치한 즐겨찾기 등록 버튼이다.
  ///
  /// [classData]를 통해 과목에 대한 정보를 받아서 즐겨찾기 리스트에 현재 표시중인 과목을 추가하는
  /// 등의 작업을 가능하게 한다.
  const FavoriteButton({Key? key, required ClassInfo classData})
      : _classData = classData,
        super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<ClassInfo> classInfo = ref.watch(favoriteControllerNotifierProvider);
    return SuwonButton(
      icon: classInfo.contains(_classData) ? Icons.star : Icons.star_outline,
      buttonName: classInfo.contains(_classData) ? '즐겨찾기에서 제거' : '즐겨찾기 추가',
      onPressed: () {
        if (classInfo.contains(_classData)) {
          ref
              .read(favoriteControllerNotifierProvider.notifier)
              .removeSubject(_classData.subjectCode);
        } else {
          ref
              .read(favoriteControllerNotifierProvider.notifier)
              .addSubject(_classData);
        }
      },
    );
  }
}
