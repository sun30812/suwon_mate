import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/styles/style_widget.dart';

class FavoriteSubjectPage extends StatelessWidget {
  const FavoriteSubjectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FavoriteListView(),
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

  Future<void> getFavoriteData() async {
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
      }
    }
    setState(() {

    });
  }

  Future getData() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();

    if (_pref.containsKey('favoritesMap')) {
      _favorites = jsonDecode(_pref.getString('favoritesMap')!);
    }

    if (_pref.containsKey('favorites')) {
      _migrateFavorites = _pref.getStringList('favorites')!;
    }

    if (_pref.containsKey('class')) {
      _isSaved = true;
      return _pref.getString('class');
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
    // _pref.setString('class', jsonEncode(_orgClassList));
    _pref.remove('favorites');
  }

  @override
  Widget build(BuildContext context) {
    return mainScreen();
  }

  FutureOr refresh(Object? dat) async {
    await getData();
    setState(()  {
    });
  }

  Widget mainScreen() {
    if (!_isSaved) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 50.0,
              ),
              Text('?????? ???????????? ????????? ???????????? ?????? ?????? ???????????? ??? ????????????.'),
            ],
          ));
    }
    return FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Center(child: CircularProgressIndicator.adaptive()),
                Text('DB ?????? ?????? ??? ?????? ???')
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
                  const Text('?????? ??????????????? ???????????? ????????? ????????????.\n'
                      '??????????????? ???????????? ??????????????????.'),
                  SuwonButton(
                      icon: Icons.date_range,
                      buttonName: '?????? ?????? ??????',
                      onPressed: () => Navigator.pushNamed(context, '/oclass')
                          .then((value) => refresh(value)))
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
              return RefreshIndicator(
                onRefresh: (getFavoriteData),
                child: ListView.builder(
                    itemCount: _favorites.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SimpleCardButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed('/oclass/info',
                                  arguments: _favoriteClassList[index])
                          .then((value) => refresh(value))
                          ,
                          title: _favoriteClassList[index]["subjtNm"],
                          subTitle: _favoriteClassList[index]["ltrPrfsNm"] ??
                              "?????? ?????? ??????",
                          content: Text((_favoriteClassList[index]["deptNm"] ??
                                  "?????? ?????? ??????(?????? ??????)") +
                              ", " +
                              _favoriteClassList[index]["facDvnm"] +
                              ', ' +
                              (_favoriteClassList[index]["timtSmryCn"] ??
                                  "?????? ??????")));
                    }),
              );
            }
          }
        });
  }
}
