import 'package:flutter/foundation.dart';

@immutable
class Notice {
  /// 공지사항의 제목
  final String title;
  /// 공지사항의 고유 코드(사이트 이동 시 수원대학교 사이트에서 필요한 매개변수)
  final String siteCode;

  /// 공지사항을 위한 객체를 생성한다.
  ///
  /// [title]에 공지사항의 제목을 기입하고, [siteCode]에 수원대학교 사이트로
  /// 이동 시 제공되는 매개변수를 입력해야 한다.
  const Notice({required this.title, required this.siteCode});
}
