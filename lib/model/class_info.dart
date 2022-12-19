/// 특정 강의에 대한 정보를 가지는 클래스이다.
///
/// 특정 강의에 대한 정보를 요구하는 위젯을 다루기 쉽도록 만들어진 클래스이다.
///
/// ## 같이보기
/// - [ClassDetailInfoCard]
class ClassInfo {
  /// 강의에서 사용되는 언어
  final String classLanguage;

  /// 과목 코드
  final String subjectCode;

  /// 해당 과목의 개설 년도
  final String openYear;

  /// 해당 과목 수강 시 얻을 수 있는 학점
  final int point;

  /// 과목 종류
  final String subjectKind;

  /// 강의실 위치
  final String classLocation;

  /// 과목의 영역
  final String region;

  /// 강의자의 성별
  final String sex;

  /// 강의자의 계약 기간
  final String promise;

  /// 강의자의 직책
  final String hostGrade;

  /// 강의자 성함
  final String hostName;

  /// 수업 방식
  final String extra;

  /// 강의 대상 학부
  final String guestDept;

  /// 강의 대상 학과
  final String guestMjor;

  /// 강의 대상 학년
  final int guestGrade;

  /// 특정 강의에 대한 정보를 가지는 클래스이다.
  ///
  ClassInfo(
      {required this.classLanguage,
      required this.subjectCode,
      required this.openYear,
      required this.point,
      required this.subjectKind,
      required this.classLocation,
      required this.region,
      required this.sex,
      required this.promise,
      required this.hostGrade,
      required this.hostName,
      required this.extra,
      required this.guestDept,
      required this.guestMjor,
      required this.guestGrade});

  /// [ClassInfo]로 역직렬화 시 사용되는 메서드이다.
  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
        classLanguage: json['lssnLangNm'],
        subjectCode: '${json['subjtCd']}${json['diclNo']}',
        openYear: json['subjtEstbYear'],
        point: json['point'],
        subjectKind: json['facDvnm'],
        classLocation: json['timtSmryCn'],
        region: json['cltTerrNm'],
        sex: json['sexCdNm'],
        promise: json['hffcStatNm'],
        hostGrade: json['clsfNm'],
        hostName: json['ltrPrfsNm'],
        extra: json['capprTypeNm'],
        guestDept: json['estbDpmjNm'],
        guestMjor: json['estbMjorNm'],
        guestGrade: json['trgtGrdeCd']);
  }
}
