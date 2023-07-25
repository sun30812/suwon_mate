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
