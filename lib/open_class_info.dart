import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/style_widget.dart';

class OpenClassInfo extends StatelessWidget {
  const OpenClassInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dynamic arg = ModalRoute.of(context)!.settings.arguments!;
    return Scaffold(
      appBar: AppBar(
        title: Text((arg['subjtNm'])),
      ),
      body: OpenClassInfoPage(
        classData: arg,
      ),
      floatingActionButton: FavoriteButton(
        subjectCode: '${arg['subjtCd']}-${arg['diclNo']}',
      ),
    );
  }
}

class OpenClassInfoPage extends StatefulWidget {
  final dynamic classData;
  const OpenClassInfoPage({Key? key, required this.classData})
      : super(key: key);

  @override
  _OpenClassInfoPageState createState() => _OpenClassInfoPageState();
}

class _OpenClassInfoPageState extends State<OpenClassInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ClassDetailInfoCard(
            classLang: widget.classData["lssnLangNm"] ?? '해당 없음',
            subjectCode:
                '${widget.classData['subjtCd']}-${widget.classData['diclNo']}',
            openYear: widget.classData["subjtEstbYear"],
            point: widget.classData["point"].toString(),
            subjectKind: widget.classData["facDvnm"] ?? '공개 안됨',
            classLocation: widget.classData["timtSmryCn"] ?? '공개 안됨',
            region: widget.classData["cltTerrNm"] ?? '해당 없음',
            sex: widget.classData["sexCdNm"] ?? '공개 안됨',
            promise: widget.classData["hffcStatNm"] ?? '공개 안됨',
            hostGrade: widget.classData["clsfNm"] ?? '공개 안됨',
            hostName: widget.classData["ltrPrfsNm"] ?? '공개 안됨',
            extra: widget.classData["capprTypeNm"] ?? '공개 안됨',
            guestDept: widget.classData["estbDpmjNm"] ?? '공개 안됨',
            guestGrade: (widget.classData["trgtGrdeCd"] ?? 0).toString() + '학년',
          ),
        ],
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final String _subjectCode;
  const FavoriteButton({Key? key, required String subjectCode})
      : _subjectCode = subjectCode,
        super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isAddFavorite = false;
  bool _isFirst = true;
  bool _isGetFirst = true;
  late List<String> _favorites;

  Future getData() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();

    if (_isFirst) {
      _favorites = _pref.getStringList('favorites') ?? [];
      _isFirst = false;
    }

    for (var _favorite in _favorites) {
      if (_favorite == widget._subjectCode) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _favorites = [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SuwonButton(
            icon: Icons.star_outline,
            buttonName: '즐겨찾기 추가',
            onPressed: null,
          );
        } else {
          if (_isGetFirst) {
            _isAddFavorite = snapshot.data as bool;
            _isGetFirst = false;
          }
          if (!_isAddFavorite) {
            return SuwonButton(
              icon: Icons.star_outline,
              buttonName: '즐겨찾기 추가',
              onPressed: () {
                setState(() {
                  _isAddFavorite = true;
                  _favorites.add(widget._subjectCode);
                });
              },
            );
          } else {
            return SuwonButton(
              icon: Icons.star,
              buttonName: '즐겨찾기에서 제거',
              onPressed: () {
                setState(() {
                  _isAddFavorite = false;
                });
              },
            );
          }
        }
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setStringList('favorites', _favorites);
  }
}
