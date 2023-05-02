import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/interfaces.dart';

mixin SettingsProvider {
  Future<String?> getValue(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }
}

/// 학생 정보를 설정하는 클래스
@immutable
class StudentInfoSetting {
  /// 현재 학부를 나타내는 변수이다.
  final String myDp = '컴퓨터학부';

  /// 현재 학과를 나타내는 변수이다.
  final String mySub = '학부 공통';

  /// 현재 학년을 나타내는 변수이다.
  final String grade = '1학년';
}

/// 기능 설정을 담당하는 클래스
@immutable
class FunctionSetting with SettingsProvider implements Savable {
  /// 데이터 절약 모드 활성화 여부
  final bool offline;

  /// 개설 강좌 조회 화면 하단 배너에 광고 표시 여부
  final bool bottomBanner;

  FunctionSetting({this.offline = false, this.bottomBanner = true});

  FunctionSetting copyWith({bool? offline, bool? bottomBanner}) =>
      FunctionSetting(
          offline: offline ?? this.offline,
          bottomBanner: bottomBanner ?? this.bottomBanner);

  factory FunctionSetting.fromJson(Map json) {
    return FunctionSetting(
        offline: json['offline'],
      bottomBanner: json['bottomBanner']
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'offline': offline,
    'bottomBanner': bottomBanner
      };
}
