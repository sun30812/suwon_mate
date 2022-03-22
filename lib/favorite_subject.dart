import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/style_widget.dart';

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
  late List _classList;
  late List<String> _favorites;
  late List _favoriteClassList;

  @override
  void initState() {
    super.initState();
    _classList = [];
    _favorites = [];
    _favoriteClassList = [];
  }

  FutureOr onGoBack(dynamic data) {
    setState(() {});
  }

  Future getData() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();

    _favorites = _pref.getStringList('favorites') ?? [];

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
    DatabaseReference ref = FirebaseDatabase.instance.ref('estbLectDtaiList');
    _pref.setString('db_ver', versionInfo["db_ver"]);
    return await ref.once();
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setString('class', jsonEncode(_classList));
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
              _classList = jsonDecode(snapshot.data);
            } else {
              DatabaseEvent _event = snapshot.data;
              _classList = _event.snapshot.value as List;
            }
            for (var favorite in _favorites) {
              for (var dat in _classList) {
                if ('${dat['subjtCd']}-${dat['diclNo']}' == favorite) {
                  _favoriteClassList.add(dat);
                }
              }
            }
            if (_favorites.isEmpty) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.star_border,
                    size: 50.0,
                  ),
                  Text('아직 즐겨찾기에 등록하신 과목이 없습니다. 추가해보세요'),
                ],
              ));
            } else {
              return ListView.builder(
                  itemCount: _favorites.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SimpleCardButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed('/oclass/info',
                                arguments: _favoriteClassList[index])
                            .then(onGoBack),
                        title: _favoriteClassList[index]["subjtNm"],
                        subTitle: _favoriteClassList[index]["ltrPrfsNm"] ??
                            "이름 공개 안됨",
                        content: Text((_favoriteClassList[index]["deptNm"] ??
                                "학부 전체 대상(전공 없음)") +
                            ", " +
                            _favoriteClassList[index]["facDvnm"] +
                            ', ' +
                            (_favoriteClassList[index]["timtSmryCn"] ??
                                "공개 안됨")));
                  });
            }
          }
        });
  }
}
