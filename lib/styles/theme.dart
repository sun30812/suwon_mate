import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

/// 앱 하단의 네비게이션 바의 테마 정의이다.
///
/// 앱 하단부에 위치한 네비게이션 바의 색상을 정의한다.
///
/// ```dart
/// ThemeData(
///     useMaterial3: true,
///     colorSchemeSeed: suwonColorSeed,
///     navigationBarTheme: suwonNavigationTheme,
///   )
/// ```
var suwonNavigationTheme = const NavigationBarThemeData().copyWith(
    surfaceTintColor: suwonNavy,
    indicatorColor: suwonNavy,
    iconTheme: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const IconThemeData(color: suwonDeepYellow);
      }
      return null;
    }));

/// 수원대학교의 로고색상 중 하나인 SUWON NAVY이다.
///
/// 참고:
///
/// [수원대학교 UI](https://www.suwon.ac.kr/index.html?menuno=619)
const suwonNavy = Color.fromARGB(255, 0, 54, 112);

/// 수원대학교의 로고색상 중 하나인 SUWON DEEP YELLOW이다.
///
/// 참고:
///
/// [수원대학교 UI](https://www.suwon.ac.kr/index.html?menuno=619)
const suwonDeepYellow = Color.fromARGB(255, 233, 184, 0);

/// 학사일정 아이콘
IconData scheduleIcon() {
  if (!(Platform.isAndroid || Platform.isIOS)) {
    return FluentIcons.schedule_event_action;
  }
  return Icons.schedule_outlined;
}

/// 개설강좌 조회 아이콘
IconData checkClassIcon() {
  if (!(Platform.isAndroid || Platform.isIOS)) {
    return FluentIcons.date_time;
  }
  return Icons.date_range;
}

/// 학식조회 아이콘
IconData checkFoodIcon() {
  if (!(Platform.isAndroid || Platform.isIOS)) {
    return FluentIcons.diet_plan_notebook;
  }
  return Icons.food_bank_outlined;
}

/// 공지사항 아이콘
IconData noticeIcon() {
  if (!(Platform.isAndroid || Platform.isIOS)) {
    return FluentIcons.info;
  }
  return Icons.notifications_none;
}

/// 즐겨찾는 과목 아이콘
IconData favoriteSubjectIcon() {
  if (!(Platform.isAndroid || Platform.isIOS)) {
    return FluentIcons.favorite_star;
  }
  return Icons.star_outline;
}

/// 설정 아이콘
IconData settingsIcon() {
  if (!(Platform.isAndroid || Platform.isIOS)) {
    return FluentIcons.settings;
  }
  return Icons.settings_outlined;
}