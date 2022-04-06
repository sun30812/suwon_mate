import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/styles/style_widget.dart';

class FavoriteSubjectPage extends StatelessWidget {
  const FavoriteSubjectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾는 과목'),
      ),
      body: const FavoriteListView(),
    );
  }
}

class FavoriteListView extends StatefulWidget {
  const FavoriteListView({Key? key}) : super(key: key);

  @override
  _FavoriteListViewState createState() => _FavoriteListViewState();
}

class _FavoriteListViewState extends State<FavoriteListView> {
  bool _isSaved = false;
  late List _orgClassList;
  late Map _classList;
  late List _favorites;
  late List _favoriteClassList;
  List<String> _migrateFavorites = [];

  @override
  void initState() {
    super.initState();
    _orgClassList = [];
    _classList = {};
    _favorites = [];
    _favoriteClassList = [];
  }

  FutureOr onGoBack(dynamic data) {
    setState(() {});
  }

  Future getData() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();

    if (_pref.containsKey('favoritesMap')) {
      _favorites = jsonDecode(_pref.getString('favoritesMap')!);
    }

    if (_pref.containsKey('favorites')) {
      _migrateFavorites = _pref.getStringList('favorites')!;
    }

    if (_pref.containsKey('settings')) {
      if (_pref.containsKey('class') &&
          (jsonDecode(_pref.getString('settings')!))['offline']) {
        _isSaved = true;
        return _pref.getString('class');
      }
    }

    DatabaseReference version = FirebaseDatabase.instance.ref('version');
    Map versionInfo = (await version.once()).snapshot.value as Map;
    if ((_pref.getString('db_ver')) == versionInfo["db_ver"]) {
      _isSaved = true;
      return _pref.getString('class');
    }
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('estbLectDtaiList_test');
    _pref.setString('db_ver', versionInfo["db_ver"]);
    return ref.once();
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setString('class', jsonEncode(_orgClassList));
    _pref.remove('favorites');
  }

  @override
  Widget build(BuildContext context) {
    return mainScreen();
  }

  Widget mainScreen() {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux)) {
      return const NotSupportInPlatform('Windows나 Linux');
    }
    return FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Center(child: CircularProgressIndicator.adaptive()),
                Text('DB 버전 확인 및 갱신 중')
              ],
            );
          } else if (snapshot.hasError) {
            return const DataLoadingError();
          } else {
            if (_isSaved) {
              _orgClassList = jsonDecode(snapshot.data) as List;
              _classList = _orgClassList[0];
            } else {
              DatabaseEvent _event = snapshot.data;
              _orgClassList = (_event.snapshot.value as List);
              _classList = _orgClassList[0];
            }

            if (_migrateFavorites.isNotEmpty) {
              for (Map dat in _classList.values.first) {
                for (String _code in _migrateFavorites) {
                  if ('${dat['subjtCd']}-${dat['diclNo']}' == _code) {
                    _favorites.add({dat['estbDpmjNm']: _code});
                  }
                }
              }
            }

            if (_favorites.isEmpty) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star_border,
                    size: 50.0,
                  ),
                  const Text('아직 즐겨찾기에 등록하신 과목이 없습니다.\n'
                      '개설강좌를 조회하여 추가해보세요.'),
                  SuwonButton(
                      icon: Icons.date_range,
                      buttonName: '개설 강좌 조회',
                      onPressed: () => Navigator.pushNamed(context, '/oclass'))
                ],
              ));
            } else {
              for (Map favorite in _favorites) {
                for (var dat in _classList[favorite.keys.first]) {
                  if ('${dat['subjtCd']}-${dat['diclNo']}' ==
                      favorite.values.first) {
                    _favoriteClassList.add(dat);
                  }
                }
              }
              return ListView.builder(
                  itemCount: _favorites.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed('/oclass/info',
                                arguments: _favoriteClassList[index])
                            .then(onGoBack);
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _favoriteClassList[index]["subjtNm"],
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _favoriteClassList[index]["ltrPrfsNm"] ??
                                    "이름 공개 안됨",
                                style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text((_favoriteClassList[index]["deptNm"] ??
                                      "학부 전체 대상(전공 없음)") +
                                  ", " +
                                  _favoriteClassList[index]["facDvnm"] +
                                  ', ' +
                                  (_favoriteClassList[index]["timtSmryCn"] ??
                                      "공개 안됨")),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
          }
        });
  }
}
