import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClassDetailInfoCard extends StatelessWidget {
  String subjectCode,
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
      guestMajor,
      guestDept;
  ClassDetailInfoCard(
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
      required String guestMajor,
      required String guestDept})
      : this.subjectCode = subjectCode,
        this.openYear = openYear,
        this.subjectKind = subjectKind,
        this.hostName = hostName,
        this.hostGrade = hostGrade,
        this.classLocation = classLocation,
        this.region = region,
        this.classLang = classLang,
        this.promise = promise,
        this.extra = extra,
        this.sex = sex,
        this.point = point,
        this.guestGrade = guestGrade,
        this.guestMajor = guestMajor,
        this.guestDept = guestDept,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.account_circle_outlined),
                    Text(
                      '수업 대상자',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0),
                    )
                  ],
                ),
                Text(
                  '대상 학년: $guestGrade',
                  style: const TextStyle(fontSize: 17.0),
                ),
                Text(
                  '대상 학부: $guestDept',
                  style: const TextStyle(fontSize: 17.0),
                ),
                Text(
                  '대상 전공: $guestMajor',
                  style: const TextStyle(fontSize: 17.0),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.book_outlined),
                        Text(
                          '과목 정보',
                          style:
                              TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0),
                        ),

                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: subjectCode)).then((value) =>
                          {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('과목 코드가 복사되었습니다.'),
                              duration: Duration(seconds: 1),
                            ))
                          });
                        }, icon: const Icon(Icons.copy))
                  ],
                ),
                Text(
                  '과목 코드: $subjectCode',
                  style: const TextStyle(fontSize: 17.0),
                ),
                Text(
                  '개설년도: $openYear',
                  style: const TextStyle(fontSize: 17.0),
                ),
                Text(
                  '교과 종류: $subjectKind',
                  style: const TextStyle(fontSize: 17.0),
                ),
                Text(
                  '학점: $point',
                  style: const TextStyle(fontSize: 17.0),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.work_outline),
                    Text(
                      '강의자 정보',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0),
                    )
                  ],
                ),
                Text(
                  '성별: $sex',
                  style: const TextStyle(fontSize: 17.0),
                ),
                Text(
                  '성함: $hostName',
                  style: const TextStyle(fontSize: 17.0),
                ),
                Text(
                  '직책: $hostGrade',
                  style: const TextStyle(fontSize: 17.0),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.school_outlined),
                    Text(
                      '수업 관련 사항',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0),
                    )
                  ],
                ),
                Text(
                  '수업 장소 및 요일: $classLocation',
                  style: const TextStyle(fontSize: 17.0),
                ),
                Text(
                  '교양 영역: $region',
                  style: const TextStyle(fontSize: 17.0),
                ),
                Text(
                  '수업 언어: $classLang',
                  style: const TextStyle(fontSize: 17.0),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.info_outline),
                    Text(
                      '추가 정보',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0),
                    )
                  ],
                ),
                Text(
                  '강의자 계약 정보: $promise',
                  style: const TextStyle(fontSize: 17.0),
                ),
                Text(
                  '수업 방식: $extra',
                  style: const TextStyle(fontSize: 17.0),
                ),
              ],
            ),
          ),
        )
      ],
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
  })  : this.icon = icon,
        btnName = buttonName,
        this.onPressed = onPressed,
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
