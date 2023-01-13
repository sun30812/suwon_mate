import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/model/class_info.dart';
import 'package:suwon_mate/styles/style_widget.dart';

/// 즐겨찾는 과목을 볼 수 있는 페이지이다.
class FavoriteSubjectPage extends StatelessWidget {
  const FavoriteSubjectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FavoriteListView(),
    );
  }
}

/// 즐겨찾는 과목 페이지로 이동 시 보이는 화면이다.
///
/// 만일 개설강좌 조회를 한 번도 하지 않은 경우 즐겨찾는 과목에 필요한 일부 설정 값이 없기 때문에 올바르게 동작하지 않는다.
/// 이 경우 개설강좌 조회를 들어가지 않으면 이용이 불가하다는 내용을 출력하는 역할도 한다.
class FavoriteListView extends StatefulWidget {
  const FavoriteListView({Key? key}) : super(key: key);

  @override
  _FavoriteListViewState createState() => _FavoriteListViewState();
}

class _FavoriteListViewState extends State<FavoriteListView> {
  /// [SharedPreferences]로부터 즐겨찾기 과목 리스트를 가져오는 메서드이다.
  Future<List<ClassInfo>?> getData() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    List result = jsonDecode((_pref.getString('favoriteSubjectList')) ?? '[]');
    return result.map((e) => ClassInfo.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ClassInfo>?>(
        future: getData(),
        builder:
            (BuildContext context, AsyncSnapshot<List<ClassInfo>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Center(child: CircularProgressIndicator.adaptive()),
                Text('과목 정보 불러오는 중...')
              ],
            );
          } else if (snapshot.hasError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DataLoadingError(
                  errorMessage: snapshot.error,
                ),
              ],
            );
          } else {
            if (snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.disabled_by_default_outlined),
                    Text('즐겨찾기된 과목이 없습니다.'),
                    Text('개설 강좌 조회에서 즐겨찾기를 추가해보세요')
                  ],
                ),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return SimpleCardButton(
                    onPressed: () => context.push('/oclass/info',
                        extra: snapshot.data![index]),
                    title: snapshot.data![index].name,
                    subTitle: snapshot.data![index].hostName ?? "이름 공개 안됨",
                    content: Text(
                        (snapshot.data![index].guestMjor ?? "학부 전체 대상") +
                            ", " +
                            (snapshot.data![index].subjectKind ?? '공개 안됨') +
                            ', ' +
                            (snapshot.data![index].classLocation ?? "공개 안됨")),
                  );
                });
          }
        });
  }

  /// [RefreshIndicator]로 인해 새로고침 되는 경우 사용되는 메서드이다.
  ///
  /// 여러 설정 값이나 즐겨찾기 한 과목들을 다시 불러오는 작업을 수행한다.
  FutureOr refresh(Object? dat) async {
    await getData();
    setState(() {});
  }
}
