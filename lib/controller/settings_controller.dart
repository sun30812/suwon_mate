import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/interfaces.dart';
import 'package:suwon_mate/model/settings.dart';

/// 설정값을 가져올 때 사용되는 `mixin`이다.
///
/// 설정값을 가져오거나 저장하는 동작을 할 때 사용되며 [isLoading]을 통해 현재 설정값을
/// 설정 값을 가져오는 중인지 판단할 수 있다.
mixin SettingsProvider {
  /// 설정값을 가져오는지 판단하는 변수로 작업이 완료될 시 `false`로 지정하면 된다.
  bool isLoading = true;

  Future<String?> getValue(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  void setValue(String key, Savable object) =>
      SharedPreferences.getInstance()
          .then((value) => value.setString(key, jsonEncode(object.toJson())));
}


class FunctionSettingControllerNotifier extends StateNotifier<FunctionSetting>
    with SettingsProvider {
  FunctionSettingControllerNotifier() : super(FunctionSetting()) {
    getValue('settings').then((value) {
      if (value != null) {
        state = FunctionSetting.fromJson(jsonDecode(value));
      }
    });
    isLoading = false;
  }

  void onOfflineSettingChanged(bool newValue) {
    state = state.copyWith(offline: newValue);
    setValue('settings', state);
  }

  void onBottomBannerSettingChanged(bool newValue) {
    state = state.copyWith(bottomBanner: newValue);
    setValue('settings', state);
  }
}

class StudentInfoSettingControllerNotifier
    extends StateNotifier<StudentInfoSetting> with SettingsProvider {
  StudentInfoSettingControllerNotifier(StudentInfoSetting state) : super(state);
}

final functionSettingControllerNotifierProvider =
    StateNotifierProvider<FunctionSettingControllerNotifier, FunctionSetting>(
        (ref) => FunctionSettingControllerNotifier());
