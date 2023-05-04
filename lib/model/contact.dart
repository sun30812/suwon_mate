import 'package:flutter/foundation.dart';
import 'package:suwon_mate/interfaces.dart';

/// 강의자에 대한 연락처 정보를 가지는 클래스이다.
///
/// 강의자의 이메일 주소와 휴대전화 번호를 담고 있다. 해당 정보는 수원대 소속 인원만
/// 접근이 가능하도록 인증 절차를 통해 **서버단에서 로그인 되었다 확인된 사용자에게** DB
/// 접근 권한이 부여된다.
///
@immutable
class Contact implements Savable {
  /// 강의자의 이메일 주소
  final String email;

  /// 강의자의 휴대전화 정보
  final String phoneNumber;

  const Contact({required this.email, required this.phoneNumber});

  /// [Contact]로 역직렬화 시 사용되는 메서드이다.(Firebase 전용)
  ///
  /// [json]으로 역직렬화가 필요한 값을 받아서 역직렬화를 시켜준다.
  factory Contact.fromFirebaseDatabase(Map json) =>
      Contact(email: json['email'], phoneNumber: json['mphone']);

  @override
  Map<String, dynamic> toJson() => {'email': email, 'mphone': phoneNumber};
}
