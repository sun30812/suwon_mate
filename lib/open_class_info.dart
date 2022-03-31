import 'dart:convert';

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
        depart: arg['estbDpmjNm'],
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
            guestMjor: widget.classData["estbMjorNm"] ?? '학부 전체',
            guestGrade: (widget.classData["trgtGrdeCd"] ?? 0).toString() + '학년',
          ),
        ],
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final String _subjectCode;
  final String _depart;
  const FavoriteButton(
      {Key? key, required String depart, required String subjectCode})
      : _depart = depart,
        _subjectCode = subjectCode,
        super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isAddFavorite = false;
  bool _isFirst = true;
  bool _isGetFirst = true;
  List _favorites = [];

  Future getData() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();

    if (_isFirst) {
      if (_pref.containsKey('favoritesMap')) {
        _favorites = jsonDecode(_pref.getString('favoritesMap')!);
      }
      _isFirst = false;
    }

    for (var _favorite in _favorites) {
      if (_favorite.values.first.toString() == widget._subjectCode) {
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

  void syncFavorite() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setString('favoritesMap', jsonEncode(_favorites));
  }

  int? getFavoriteRemoveIndex(String code) {
    int _count = 0;
    for (Map _favorite in _favorites) {
      if (_favorite.values.first == code) {
        return _count;
      }
      _count++;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const SuwonButton(
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
                  Map _map = {widget._depart: widget._subjectCode};
                  _favorites.add(_map);
                });
                syncFavorite();
              },
            );
          } else {
            return SuwonButton(
              icon: Icons.star,
              buttonName: '즐겨찾기에서 제거',
              onPressed: () {
                setState(() {
                  int? _removeIndex =
                      getFavoriteRemoveIndex(widget._subjectCode);
                  if (_removeIndex != null) {
                    _favorites.removeAt(_removeIndex);
                  }
                  _isAddFavorite = false;
                });
                syncFavorite();
              },
            );
          }
        }
      },
    );
  }
}
