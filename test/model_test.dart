import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:suwon_mate/model/class_info.dart';
import 'package:suwon_mate/model/contact.dart';
import 'package:suwon_mate/model/notice.dart';
import 'package:suwon_mate/model/settings.dart';

void main() {
  group('ClassInfo객체 테스트', () {
    test('객체가 정상적으로 생성되는지 테스트', () {
      const info = ClassInfo(
          name: 'sun30812',
          classLanguage: 'classLanguage',
          subjectCode: 'subjectCode',
          openYear: 'openYear',
          point: 'point',
          subjectKind: 'subjectKind',
          classLocation: 'classLocation',
          region: 'region',
          sex: 'sex',
          promise: 'promise',
          hostGrade: 'hostGrade',
          hostName: 'hostName',
          extra: 'extra',
          guestDept: 'guestDept',
          guestMjor: 'guestMjor',
          guestGrade: null);
      expect(info.name, 'sun30812');
    });
    test('객체 비교 시 과목 고유 번호를 기준으로 동일여부를 파악하는지', () {
      const info = ClassInfo(
          name: 'sun30812',
          classLanguage: 'classLanguage',
          subjectCode: 'A23',
          openYear: 'openYear',
          point: 'point',
          subjectKind: 'subjectKind',
          classLocation: 'classLocation',
          region: 'region',
          sex: 'sex',
          promise: 'promise',
          hostGrade: 'hostGrade',
          hostName: 'hostName',
          extra: 'extra',
          guestDept: 'guestDept',
          guestMjor: 'guestMjor',
          guestGrade: null);
      const info2 = ClassInfo(
          name: 'sun30812',
          classLanguage: 'classLanguage',
          subjectCode: 'A23',
          openYear: 'openYear',
          point: 'point',
          subjectKind: 'subjectKind',
          classLocation: 'classLocation',
          region: 'region',
          sex: 'sex',
          promise: 'promise',
          hostGrade: 'hostGrade',
          hostName: 'hostName',
          extra: 'extra',
          guestDept: 'guestDept',
          guestMjor: 'guestMjor',
          guestGrade: 3);
      expect(info, info2);
    });
    test('객체 역직렬화 테스트', () {
      const info = ClassInfo(
          name: 'sun30812',
          classLanguage: 'classLanguage',
          subjectCode: 'A23',
          openYear: 'openYear',
          point: 'point',
          subjectKind: 'subjectKind',
          classLocation: 'classLocation',
          region: 'region',
          sex: 'sex',
          promise: 'promise',
          hostGrade: 'hostGrade',
          hostName: 'hostName',
          extra: 'extra',
          guestDept: 'guestDept',
          guestMjor: 'guestMjor',
          guestGrade: null);
      var data = jsonEncode(info);
      var info2 = ClassInfo.fromJson(jsonDecode(data));
      expect(info, info2);
    });
  });
  group('Contact객체 테스트', () {
    test('객체가 정상적으로 생성되는지 테스트', () {
      const contact =
          Contact(email: 'sun30812@naver.com', phoneNumber: '010000000000');
      expect(contact.email, 'sun30812@naver.com');
    });
    test('객체 역직렬화 테스트', () {
      const contact =
          Contact(email: 'sun30812@naver.com', phoneNumber: '010000000000');
      var data = jsonEncode(contact);
      var contact2 = Contact.fromFirebaseDatabase(jsonDecode(data));
      expect(contact.phoneNumber, contact2.phoneNumber);
    });
  });
  group('Notice객체 테스트', () {
    test('객체가 정상적으로 생성되는지 테스트', () {
      const notice = Notice(title: 'testNotice', siteCode: 'default');
      expect(notice.siteCode, 'default');
    });
  });
  group('FunctionSettings객체 테스트', () {
    test('객체가 정상적으로 생성되는지 테스트', () {
      var settings = FunctionSetting();
      expect(settings.offline, false);
    });
    test('객체가 역직렬화 테스트', () {
      var settings = FunctionSetting();
      var data = jsonEncode(settings);
      var settings2 = FunctionSetting.fromJson(jsonDecode(data));
      expect(settings.offline, settings2.offline);
    });
    test('객체 copyWith 메서드 동작 여부 테스트', () {
      var settings = FunctionSetting();
      var settings2 = settings.copyWith(offline: true);
      expect(settings2.offline, true);
    });
  });
}
