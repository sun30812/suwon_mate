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
                      Text('과목 코드: $subjectCode', style: const TextStyle(fontSize: 17.0)),
                      IconButton(
                        tooltip: '과목 코드 복사',
                          onPressed: () {
                        Clipboard.setData(ClipboardData(text: subjectCode))
                            .then((value) => {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('과목 코드가 복사되었습니다.'),
                                  duration: Duration(seconds: 1),)
                              )
                        });
                      }, icon: Icon(Icons.copy)),
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
              detail: Text(
                '성별: $sex\n성함: $hostName\n직책: $hostGrade',
                style: const TextStyle(fontSize: 17.0),
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
  IconData icon;
  String btnName;
  void Function()? onPressed;
  SuwonButton({
    Key? key,
    required IconData icon,
    required String buttonName,
    required void Function()? onPressed,
  })  : icon = icon,
        btnName = buttonName,
        onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
          onPressed: onPressed,
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

  static Widget Simplified({required String title, String? subTitle, required Widget content}) {
    Widget SubTitle(String? text) {
      if (text != null) {
        return Text(
          text,
          style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold),
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
                Padding(padding: EdgeInsets.only(right: 10.0)),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
              ],
            ),
            Divider(),
            detail
          ],
        ),
      ),
    );
  }
}
