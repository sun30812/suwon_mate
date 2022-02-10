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
          ClassDetailInfoCard(classLang:  widget.classData["lssnLangNm"] ?? '해당 없음',
              subjectCode: '${widget.classData['subjtCd']}-${widget.classData['diclNo']}',
            openYear: widget.classData["subjtEstbYear"], point: widget.classData["point"].toString(),
            subjectKind: widget.classData["facDvnm"] ?? '공개 안됨', classLocation: widget.classData["timtSmryCn"] ?? '학부 전체',
            region: widget.classData["cltTerrNm"] ?? '해당 없음', sex: widget.classData["sexCdNm"] ?? '공개 안됨',
            promise: widget.classData["hffcStatNm"] ?? '공개 안됨', hostGrade: widget.classData["clsfNm"] ?? '공개 안됨',
            hostName: widget.classData["ltrPrfsNm"] ?? '공개 안됨', extra: widget.classData["capprTypeNm"] ?? '공개 안됨',
            guestDept: widget.classData["estbDpmjNm"] ?? '공개 안됨', guestGrade: (widget.classData["trgtGrdeCd"] ?? 0).toString() +'학년',
            guestMajor: widget.classData["deptNm"] ?? '학부 전체'
          ),
        ],
      ),
    );
  }
}


