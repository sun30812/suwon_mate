import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/model/class_info.dart';

/// 즐겨찾는 과목 관련 동작을 제어하는 컨트롤러이다.
///
/// 즐겨찾는 과목에 대한 제어가 필요한 경우 [favoriteControllerNotifierProvider]
/// 을 통해 접근하여 과목 제거 및 추가작업을 수행한다.
/// 즐겨찾는 과목 메뉴에 처음 접근 시 기기 내 [SharedPreferences]에 접근하여 정보를 불러오기 때문에 로딩이 발생할 수 있다.
/// 이 시간동안 앱이 정지된 것으로 보이는데, 그 대신 로딩 창을 띄우고 싶은 경우 [isLoading]속성를 통해 로딩 여부에 따라 로딩 창을
/// 띄우는 것이 가능하다.
///
/// ## 같이보기
/// * [SharedPreferences]
/// * [StateNotifier]
///
class FavoriteControllerNotifier extends StateNotifier<List<ClassInfo>> {
  /// [SharedPreferences]로부터 정보를 불러오는 중임을 나타내주는 속성이다.
  ///
  /// 데이터를 로딩 중 로딩 바를 표시하려면 해당 속성를 사용하면 된다.
  bool isLoading = true;

  FavoriteControllerNotifier() : super([]) {
    SharedPreferences.getInstance().then((value) {
      List result =
          jsonDecode((value.getString('favoriteSubjectList')) ?? '[]');
      state = result.map((e) => ClassInfo.fromJson(e)).toList();
      isLoading = false;
    });
  }

  void _sync() => SharedPreferences.getInstance().then(
      (value) => value.setString('favoriteSubjectList', jsonEncode(state)));

  /// 즐겨찾는 과목 목록에서 과목을 제거할 때 사용되는 메서드이다.
  ///
  /// 즐겨찾는 과목 리스트에서 [subjectCode]에 해당되는 과목 발견 시, 해당 과목을 제거한다.
  /// [StateNotifierProvider]를 통해 정상적으로 접근한 경우 UI상에 자동으로 변경 사항이 적용된다.
  /// 또한 기기 내 [SharedPreferences]에 즐겨찾는 과목 목록을 업데이트 해준다.
  void removeSubject(String subjectCode) {
    state = [
      for (final item in state)
        if (item.subjectCode != subjectCode) item,
    ];
    _sync();
  }

  /// 즐겨찾는 과목 목록에서 과목을 추가할 때 사용되는 메서드이다.
  ///
  /// 즐겨찾는 과목 리스트에 [classInfo]를 추가하다.
  /// [StateNotifierProvider]를 통해 정상적으로 접근한 경우 UI상에 자동으로 변경 사항이 적용된다.
  /// 또한 기기 내 [SharedPreferences]에 즐겨찾는 과목 목록을 업데이트 해준다.
  void addSubject(ClassInfo classInfo) {
    state = [...state, classInfo];
    _sync();
  }
}

/// 즐겨찾는 과목의 컨트롤러에 접근하기 위한 변수이다.
///
/// ## 사용 예제
/// ```dart
/// List<ClassInfo> classInfo = ref.watch(favoriteControllerNotifierProvider);
/// print('등록된 과목의 수는 ${classInfo.length}개 입니다.');
/// ```
final favoriteControllerNotifierProvider =
    StateNotifierProvider<FavoriteControllerNotifier, List<ClassInfo>>(
        (ref) => FavoriteControllerNotifier());
