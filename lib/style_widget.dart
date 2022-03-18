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
      required String subjectCode,
      required String openYear,
      required String subjectKind,
      required String hostName,
      required String hostGrade,
      required String classLocation,
      required String region,
      required String classLang,
      required String promise,
      required String point,
      required String extra,
      required String sex,
      required String guestGrade,
      required String guestDept})
      : subjectCode = subjectCode,
        openYear = openYear,
        subjectKind = subjectKind,
        hostName = hostName,
        hostGrade = hostGrade,
        classLocation = classLocation,
        region = region,
        classLang = classLang,
        promise = promise,
        extra = extra,
        sex = sex,
        point = point,
        guestGrade = guestGrade,
        guestDept = guestDept,
        super(key: key);

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
  bool? isActivate;
  IconData icon;
  String btnName;
  void Function()? onPressed;
  SuwonButton({
    Key? key,
    bool? isActivate,
    required IconData icon,
    required String buttonName,
    required void Function()? onPressed,
  })  : isActivate = isActivate,
        icon = icon,
        btnName = buttonName,
        onPressed = onPressed,
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
  IconData icon;
  String title;
  Widget detail;
  CardInfo(
      {Key? key,
      required IconData icon,
      required String title,
      required Widget detail})
      : icon = icon,
        title = title,
        detail = detail,
        super(key: key);

  static Widget Simplified(
      {required String title, String? subTitle, required Widget content}) {
    Widget SubTitle(String? text) {
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
            SubTitle(subTitle),
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
  final void Function()? _onPressed;
  const SuwonDialog({
    required IconData icon,
    required String title,
    required Widget content,
    void Function()? onPressed,
    Key? key,
  })  : _icon = icon,
        _title = title,
        _content = content,
        _onPressed = onPressed,
        super(key: key);

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
        ),
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'))
      ],
    );
  }
}

class NotiCard extends StatelessWidget {
  IconData? _icon = Icons.warning_amber_outlined;
  Color? _color = Colors.white;
  final String _mesage;
  NotiCard({
    IconData? icon,
    Color? color,
    required String message,
    Key? key,
  })  : _mesage = message,
        _icon = icon,
        _color = color,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(_icon),
            const Padding(padding: EdgeInsets.only(right: 10.0)),
            Flexible(child: Text(_mesage)),
          ],
        ),
      ),
    );
  }
}
