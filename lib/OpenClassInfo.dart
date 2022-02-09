import 'package:flutter/material.dart';
import 'package:suwon_mate/styleWidget.dart';

class OpenClassInfo extends StatelessWidget {
  const OpenClassInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dynamic arg = ModalRoute.of(context)!.settings.arguments!;
    return Scaffold(
      appBar: AppBar(
        title: Text((arg['subjtNm'])),
      ),
      body: OpenClassInfoPage(classData: arg,),
      floatingActionButton: SuwonButton(icon: Icons.star_outline, buttonName: '즐겨찾기 추가', onPressed: null,),
    );
  }
}


class OpenClassInfoPage extends StatefulWidget {
  final dynamic classData;
  const OpenClassInfoPage({Key? key, required this.classData}) : super(key: key);

  @override
  _OpenClassInfoPageState createState() => _OpenClassInfoPageState();
}

class _OpenClassInfoPageState extends State<OpenClassInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('과목 코드: ${widget.classData['subjtCd']}-${widget.classData['diclNo']}'),
          Text('개설년도: ${widget.classData["subjtEstbYear"]}'),
          Text('학점: ${widget.classData["point"]}점'),
          Text('교과 종류: ${widget.classData["facDvnm"] ?? '공개 안됨'}'),
          Text('대상 학부: ${widget.classData["estbDpmjNm"] ?? '공개 안됨'}'),
          Text('대상 학과: ${widget.classData["estbMjorNm"] ?? '학부 전체'}'),
          Text('교수님 성함: ${widget.classData["stafNm"] ?? '공개 안됨'}'),
          Text('교수님 정보: ${widget.classData["clsfNm"] ?? '공개 안됨'}'),
          Text('계약 정보: ${widget.classData["hffcStatNm"] ?? '공개 안됨'}'),
          Text('수업 언어: ${widget.classData["lssnLangNm"] ?? '공개 안됨'}'),
          Text('영역(교양): ${widget.classData["cltTerrNm"] ?? '해당 없음'}'),
          Text('수업 방식: ${widget.classData["capprTypeNm"] ?? '공개 안됨'}'),
        ],
      ),
    );
  }
}


