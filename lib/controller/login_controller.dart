import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginController {
  TextEditingController get emailController => _emailController;

  static final _instance = LoginController._init();
  final _emailController = TextEditingController();

  /// 설정 창 맨 상단에 존재하는 로그인 위젯에 사용되는 컨트롤러이다.
  ///
  /// 로그인 위젯에서 필요한 기능들을 제공한다.
  factory LoginController() => _instance;

  LoginController._init();

  /// 로그인 버튼을 누를 시 수행하는 동작
  ///
  /// 로그인 버튼을 누를 때 이메일 링크를 전달하는 메서드이다.
  /// 만일 오류 발생 시 오류 메세지가 출력된다.
  ///
  /// ```dart
  /// var loginController = LoginController();
  /// TextButton(
  ///    onPressed: () {
  ///      loginController.onLogin(context);
  ///    },
  ///    child: const Text('로그인'))
  /// ```
  ///
  /// ## 같이 보기
  /// * [LoginWidget]
  void onLogin(BuildContext context) {
    context.pop();
    if (!_validateEmail()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('유효하지 않은 이메일입니다.'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0))));
      _emailController.clear();
      return;
    }
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [CircularProgressIndicator(),
            Text('  로그인 링크를 보내는 중..')
          ],
        ),
      ),
    );
    var acs = ActionCodeSettings(
        url: 'https://suwonmate00.page.link/Fc4u',
        handleCodeInApp: true,
        androidMinimumVersion: '12',
        androidInstallApp: true,
        androidPackageName: 'com.sn30.suwonuniv.info.suwon_mate');
    FirebaseAuth.instance
        .sendSignInLinkToEmail(
            email: _emailController.text, actionCodeSettings: acs)
        .catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('오류'),
          content: Text(error.toString()),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'))
          ],
        ),
      );
    }).then((value) {
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('로그인을 위한 이메일이 전송되었습니다.'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0))));
    });
  }

  bool _validateEmail() =>
      _emailController.text.isNotEmpty &&
      _emailController.text.endsWith('@suwon.ac.kr');
}
