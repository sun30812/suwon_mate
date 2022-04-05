import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClassDetailInfoCard extends StatelessWidget {
  final String subjectCode,
      openYear,
      subjectKind,
      hostName,
      hostGrade,
      classLocation,
      region,
      classLang,
      promise,
      extra,
      point,
      sex,
      guestGrade,
      guestDept;
  const ClassDetailInfoCard(
      {Key? key,
      required this.subjectCode,
      required this.openYear,
      required this.subjectKind,
      required this.hostName,
      required this.hostGrade,
      required this.classLocation,
      required this.region,
      required this.classLang,
      required this.promise,
      required this.point,
      required this.extra,
      required this.sex,
      required this.guestGrade,
      required this.guestDept})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView(
        children: [
          CardInfo(
              icon: Icons.account_circle_outlined,
              title: '수업 대상자',
              detail: Text(
                '대상 학년: $guestGrade\n대상 학부/전공: $guestDept',
                style: const TextStyle(fontSize: 17.0),
              )),
          CardInfo(
              icon: Icons.book_outlined,
              title: '과목 정보',
              detail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('과목 코드: $subjectCode',
                          style: const TextStyle(fontSize: 17.0)),
                      IconButton(
                          tooltip: '과목 코드 복사',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: subjectCode))
                                .then((value) => {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('과목 코드가 복사되었습니다.'),
                                        duration: Duration(seconds: 1),
                                      ))
                                    });
                          },
                          icon: const Icon(Icons.copy)),
                    ],
                  ),
                  Text(
                    '개설년도: $openYear\n교과 종류: $subjectKind\n학점: $point',
                    style: const TextStyle(fontSize: 17.0),
                  ),
                ],
              )),
          CardInfo(
              icon: Icons.work_outline,
              title: '강의자 정보',
              detail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '성별: $sex',
                    style: const TextStyle(fontSize: 17.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '성함: $hostName',
                        style: const TextStyle(fontSize: 17.0),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed('/professor', arguments: hostName),
                        icon: const Icon(Icons.search),
                        tooltip: '해당 강의자가 강의하는 모든 과목을 검색합니다.',
                      )
                    ],
                  ),
                  Text(
                    '직책: $hostGrade',
                    style: const TextStyle(fontSize: 17.0),
                  ),
                ],
              )),
          CardInfo(
              icon: Icons.school_outlined,
              title: '수업 관련 사항',
              detail: Text(
                '수업 장소 및 요일: $classLocation\n교양 영역: $region\n수업 언어: $classLang',
                style: const TextStyle(fontSize: 17.0),
              )),
          CardInfo(
              icon: Icons.info_outline,
              title: '추가 정보',
              detail: Text(
                '강의자 계약 정보: $promise\n수업 방식: $extra\n수업 언어: $classLang',
                style: const TextStyle(fontSize: 17.0),
              ))
        ],
      ),
    );
  }
}

class DataLoadingError extends StatelessWidget {
  const DataLoadingError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: const [Icon(Icons.error_outline), Text('데이터를 불러올 수 없습니다.')],
      ),
    );
  }
}

class SuwonButton extends StatelessWidget {
  final bool? isActivate;
  final IconData icon;
  final String btnName;
  final void Function()? onPressed;
  const SuwonButton({
    Key? key,
    this.isActivate,
    required this.icon,
    required String buttonName,
    required this.onPressed,
  })  : btnName = buttonName,
        super(key: key);
  void Function()? buttonAction() {
    if (isActivate != null) {
      if (isActivate == false) {
        return null;
      }
    }
    return onPressed;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
          onPressed: buttonAction(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const Padding(
                padding: EdgeInsets.all(2),
              ),
              Text(
                btnName,
                style: const TextStyle(fontSize: 18.0),
              ),
            ],
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              minimumSize: MaterialStateProperty.all(const Size(90, 40)),
              elevation: MaterialStateProperty.all(2.0),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              )))),
    );
  }
}

class CardInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget detail;
  const CardInfo(
      {Key? key, required this.icon, required this.title, required this.detail})
      : super(key: key);

  static Widget simplified(
      {required String title, String? subTitle, required Widget content}) {
    Widget subTitleWidget(String? text) {
      if (text != null) {
        return Text(
          text,
          style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
        );
      } else {
        return Container();
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            subTitleWidget(subTitle),
            content
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const Padding(padding: EdgeInsets.only(right: 10.0)),
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
              ],
            ),
            const Divider(),
            detail
          ],
        ),
      ),
    );
  }
}

class InputBar extends StatefulWidget {
  final void Function(String)? _onChanged;
  final IconData? _icon;
  const InputBar(
      {Key? key,
      required TextEditingController controller,
      IconData? icon,
      void Function(String)? onChanged})
      : _onChanged = onChanged,
        _icon = icon,
        _controller = controller,
        super(key: key);

  final TextEditingController _controller;

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black12,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(25.0)),
        child: TextField(
          onChanged: widget._onChanged,
          controller: widget._controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "입력하여 검색",
            icon: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Icon(widget._icon),
            ),
          ),
        ),
      ),
    );
  }
}

class SuwonDialog extends StatelessWidget {
  final IconData _icon;
  final String _title;
  final Widget _content;
  final bool _isDestructive;
  final void Function()? _onPressed;
  const SuwonDialog({
    required IconData icon,
    required String title,
    required Widget content,
    bool isDestructive = false,
    void Function()? onPressed,
    Key? key,
  })  : _icon = icon,
        _title = title,
        _content = content,
        _isDestructive = isDestructive,
        _onPressed = onPressed,
        super(key: key);

  static Widget simple(
      {required BuildContext context,
      required IconData icon,
      required String title,
      required Widget content}) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(icon),
          const Padding(padding: EdgeInsets.only(right: 10.0)),
          Text(title)
        ],
      ),
      content: content,
      scrollable: true,
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'))
      ],
    );
  }

  ButtonStyle okButtonStyle() {
    if (_isDestructive) {
      return ButtonStyle(
          overlayColor:
              MaterialStateProperty.all(Colors.redAccent.withAlpha(30)),
          foregroundColor: MaterialStateProperty.all(Colors.redAccent));
    }
    return const ButtonStyle();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(_icon),
          const Padding(padding: EdgeInsets.only(right: 10.0)),
          Text(_title)
        ],
      ),
      content: _content,
      scrollable: true,
      actions: [
        TextButton(
          onPressed: _onPressed,
          child: const Text('확인'),
          style: okButtonStyle(),
        ),
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'))
      ],
    );
  }
}

class NotiCard extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final String message;
  const NotiCard({
    this.icon,
    this.color,
    required this.message,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon ?? Icons.warning_amber_outlined),
            const Padding(padding: EdgeInsets.only(right: 10.0)),
            Flexible(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class NotSupportInPlatform extends StatelessWidget {
  final String _platform;
  const NotSupportInPlatform(
    String platform, {
    Key? key,
  })  : _platform = platform,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline),
          Text('$_platform 플랫폼에서는 지원되지 않습니다.')
        ],
      ),
    );
  }
}

class NotSupportPlatformMessage extends StatelessWidget {
  const NotSupportPlatformMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return MaterialBanner(
          content: const Text('Web 플랫폼의 경우 일부 기능이 동작하지 않습니다.'),
          actions: [
            TextButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => SuwonDialog.simple(
                        context: context,
                        icon: Icons.help_outline,
                        title: '안내',
                        content: const Text(
                            'Web 플랫폼에서는 [학사 일정]이나 [공지사항] 기능을 사용할 수 없습니다.'))),
                child: const Text('설명 보기'))
          ]);
    } else if (Platform.isWindows || Platform.isLinux) {
      return MaterialBanner(
          content: const Text('Windows/Linux 플랫폼의 경우 일부 기능이 동작하지 않습니다.'),
          actions: [
            TextButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => SuwonDialog.simple(
                        context: context,
                        icon: Icons.help_outline,
                        title: '안내',
                        content: const Text(
                            'Windows/Linux 플랫폼에서는 [개설 강좌 조회]나 [즐겨찾는 과목] 기능을 아직 사용할 수 없습니다.'))),
                child: const Text('설명 보기'))
          ]);
    }
    return Container();
  }
}
