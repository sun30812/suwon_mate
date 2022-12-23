import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/model/class_info.dart';
import 'package:suwon_mate/styles/style_widget.dart';

class OpenClassInfo extends StatelessWidget {
  final ClassInfo classInfo;
  const OpenClassInfo({required this.classInfo, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classInfo.name),
      ),
      body: OpenClassInfoPage(
        classData: classInfo,
      ),
      floatingActionButton: FavoriteButton(
        depart: classInfo.guestDept ?? '공개 안됨',
        subjectCode: classInfo.subjectCode,
      ),
    );
  }
}

class OpenClassInfoPage extends StatefulWidget {
  final ClassInfo classData;
  const OpenClassInfoPage({required this.classData, Key? key})
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
            classInfo: widget.classData,
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
                  syncFavorite();
                });
              },
            );
          }
        }
      },
    );
  }
}
