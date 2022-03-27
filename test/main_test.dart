import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suwon_mate/main.dart';
import 'package:suwon_mate/open_class_info.dart';
import 'package:suwon_mate/style_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    Map<String, dynamic> functionSetting = {'offline': true};
    SharedPreferences.setMockInitialValues({
      'mySubject': '전체',
      'settings': jsonEncode(functionSetting),
      'db_ver': 'test_db',
      'class': '[{"컴퓨터학부":[{"clsfNm" : "학부생","deptNm" : '
          '"컴퓨터학부","diclNo" : "000","estbDpmjNm" : "SW개발학과","facDvnm" : "전선",'
          '"lssnLangNm" : "한국어","ltrPrfsNm" : "sun30812","point" : 10,"subjtCd" :"30812",'
          '"subjtEstbYear" : "2022","subjtNm" : "자유로운 Flutter 개발(비대면)","trgtGrdeCd" : 1}]}]',
    });
  });
  group('Main Page Test', () {
    testWidgets('Test widgets', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.text('수원 메이트'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(SuwonButton), findsNWidgets(7));
    });
  });
  group('Help Page Test', () {
    testWidgets('Test Widgets', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(find.text('도움말'));
      await tester.pumpAndSettle();
      expect(find.byType(CardInfo), findsNWidgets(6));
    });
  });
  group('Open Class Page Test', () {
    testWidgets('Test Widgets', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(find.text('개설 강좌 조회'));
      await tester.pumpAndSettle();
      expect(find.byType(SimpleCardButton), findsOneWidget);
      expect(find.text('sun30812'), findsOneWidget);
      await tester.tap(find.byType(SimpleCardButton));
      await tester.pumpAndSettle();
      expect(find.text('자유로운 Flutter 개발(비대면)'), findsOneWidget);
    });
    testWidgets('Click widget to view detail page', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(find.text('개설 강좌 조회'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SimpleCardButton));
      await tester.pumpAndSettle();
      expect(find.byType(CardInfo, skipOffstage: false), findsNWidgets(5));
      expect(find.text('자유로운 Flutter 개발(비대면)'), findsOneWidget);
    });
    testWidgets('Search subject', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(find.text('개설 강좌 조회'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('검색'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(InputBar), 'sun30');
      await tester.pumpAndSettle();
      expect(find.byType(SimpleCardButton), findsWidgets);
    });
    testWidgets('Search subject with code', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(find.text('개설 강좌 조회'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('검색'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.manage_search_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('subject_code_field')), '30812');
      await tester.pumpAndSettle();
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      expect(find.text('자유로운 Flutter 개발(비대면)'), findsWidgets);
      expect(find.byType(SimpleCardButton), findsOneWidget);
    });
    testWidgets('Search subject with full code', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(find.text('개설 강좌 조회'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('검색'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.manage_search_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('subject_code_field')), '30812-000');
      await tester.pumpAndSettle();
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      expect(find.byType(ClassDetailInfoCard), findsOneWidget);
    });
  });
  group('Favorite Subject Page', () {
    testWidgets('Add/Remove favorite Test', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(find.text('개설 강좌 조회'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SimpleCardButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FavoriteButton));
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('즐겨찾는 과목'));
      await tester.pumpAndSettle();
      expect(find.byType(SimpleCardButton), findsOneWidget);
      expect(find.text('자유로운 Flutter 개발(비대면)'), findsOneWidget);
      await tester.tap(find.text('자유로운 Flutter 개발(비대면)'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FavoriteButton));
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('즐겨찾는 과목'));
      await tester.pumpAndSettle();
      expect(find.byType(SimpleCardButton), findsNothing);
    });
  });
}
