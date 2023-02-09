import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:suwon_mate/controller/favorite_controller.dart';
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
class FavoriteListView extends ConsumerWidget {
  const FavoriteListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<ClassInfo> classInfo = ref.watch(favoriteControllerNotifierProvider);
    if (ref.read(favoriteControllerNotifierProvider.notifier).isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator.adaptive(),
            Text('즐겨찾는 과목 정보 확인 중...')
          ],
        ),
      );
    } else if (classInfo.isEmpty) {
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
        itemCount: classInfo.length,
        itemBuilder: (BuildContext context, int index) {
          return SimpleCard(
            onPressed: () =>
                context.push('/oclass/info', extra: classInfo[index]),
            title: classInfo[index].name,
            subTitle: classInfo[index].hostName ?? "이름 공개 안됨",
            // content: Text((classInfo[index].guestMjor ?? '학부 전체 대상') +
            //     ", " +
            //     (classInfo[index].subjectKind ?? '공개 안됨') +
            //     ', ' +
            //     (classInfo[index].classLocation ?? "공개 안됨")),
            content: Text(
                '${classInfo[index].guestMjor ?? '학부 전체 대상'}, ${classInfo[index].subjectKind ?? '공개 안됨'}, ${classInfo[index].classLocation ?? '공개 안됨'}'),
          );
        });
  }
}
