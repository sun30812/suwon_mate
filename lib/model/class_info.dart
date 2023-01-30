import 'package:flutter/cupertino.dart';

/// 특정 강의에 대한 정보를 가지는 클래스이다.
///
/// 특정 강의에 대한 정보를 요구하는 위젯을 다루기 쉽도록 만들어진 클래스이다.
///
/// ## 같이보기
/// - [ClassDetailInfoCard]
@immutable
class ClassInfo {
  /// 과목 이름
  final String name;

  /// 강의에서 사용되는 언어
  final String? classLanguage;

  /// 과목 코드
  final String subjectCode;

  /// 해당 과목의 개설 년도
  final String openYear;

  /// 해당 과목 수강 시 얻을 수 있는 학점(간혹 자연수가 아닌 경우도 있기에 [String]으로 지정)
  final String point;

  /// 과목 종류
  final String? subjectKind;

  /// 강의실 위치
  final String? classLocation;

  /// 과목의 영역
  final String? region;

  /// 강의자의 성별
  final String? sex;

  /// 강의자의 계약 기간
  final String? promise;

  /// 강의자의 직책
  final String? hostGrade;

  /// 강의자 성함
  final String? hostName;

  /// 수업 방식
  final String? extra;

  /// 강의 대상 학부
  final String? guestDept;

  /// 강의 대상 학과
  final String? guestMjor;

  /// 강의 대상 학년
  final int? guestGrade;

  /// 특정 강의에 대한 정보를 가지는 클래스이다.
  ///
  ClassInfo(
      {required this.name,
      required this.classLanguage,
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

  /// FirebaseDatabase로부터 과목 정보를 불러올 때 사용하는 메서드이다.
  static List<ClassInfo> fromFirebaseDatabase(List jsonList) {
    return jsonList
        .map((subject) => ClassInfo.fromFirebaseJson(subject))
        .toList();
  }

  /// [ClassInfo]로 역직렬화 시 사용되는 메서드이다.(Firebase 전용)
  factory ClassInfo.fromFirebaseJson(Map json) {
    return ClassInfo(
        name: json['subjtNm'],
        classLanguage: json['lssnLangNm'],
        subjectCode: '${json['subjtCd']}-${json['diclNo']}',
        openYear: json['subjtEstbYear'],
        point: json['point'].toString(),
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

  /// [ClassInfo]로 역직렬화 시 사용되는 메서드이다.
  factory ClassInfo.fromJson(Map json) {
    return ClassInfo(
        name: json['subjtNm'],
        classLanguage: json['lssnLangNm'],
        subjectCode: json['subjectCode'],
        openYear: json['subjtEstbYear'],
        point: json['point'].toString(),
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

  /// [ClassInfo]를 직렬화 시 사용되는 메서드이다.
  Map<String, dynamic> toJson() => {
        'subjtNm': name,
        'lssnLangNm': classLanguage,
        'subjectCode': subjectCode,
        'subjtEstbYear': openYear,
        'point': point,
        'facDvnm': subjectKind,
        'timtSmryCn': classLocation,
        'cltTerrNm': region,
        'sexCdNm': sex,
        'hffcStatNm': promise,
        'clsfNm': hostGrade,
        'ltrPrfsNm': hostName,
        'capprTypeNm': extra,
        'estbDpmjNm': guestDept,
        'estbMjorNm': guestMjor,
        'trgtGrdeCd': guestGrade,
      };

  /// 같은 과목 코드인 경우 같은 과목으로 취급하기 위한 메서드이다.
  @override
  bool operator ==(covariant ClassInfo other) =>
      subjectCode == other.subjectCode;

  @override
  int get hashCode => subjectCode.hashCode;
}
