import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suwon_mate/controller/login_controller.dart';
import 'package:suwon_mate/model/class_info.dart';

import '../model/contact.dart';

/// 강좌에 대한 세부 정보를 보여주는 페이지이다.
///
/// 강좌에 대한 상세 정보를 카드 형태의 위젯들을 통해 보여준다.
/// [classInfo]로부터 강좌 정보를 받아서 [Card]를 통해 출력해준다.
class ClassDetailInfoCard extends StatelessWidget {
  /// 강의 정보에 관한 객체
  final ClassInfo classInfo;

  /// [classInfo]로부터 강의 정보를 받아 세부 정보를 화면에 출력해준다.
  const ClassDetailInfoCard({required this.classInfo, Key? key})
      : super(key: key);

  Future<Contact?>? getContact(String? department, String? name) async {
    if ((department == null) || (name == null)) {
      return null;
    }
    var database = FirebaseDatabase.instance.ref('contacts');
    var result = await database.child('$department/$name').once();
    return Contact.fromFirebaseDatabase(result.snapshot.value as Map);
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView(
        children: [
          InfoCard(
              icon: Icons.account_circle_outlined,
              title: '수업 대상자',
              detail: Text(
                '대상 학년: ${classInfo.guestGrade ?? '공개 안됨'}\n대상 학부: ${classInfo.guestDept ?? '공개 안됨'}\n'
                    '대상 학과: ${classInfo.guestMjor ?? '학부 공통'}',
                semanticsLabel:
                '대상 학년은 ${classInfo.guestGrade ?? '공개 안됨'} 이고 대상 학부는 ${classInfo.guestDept ?? '공개 안됨'} 이며 대상 학과는 ${classInfo.guestMjor ?? '학부 공통'} 입니다.',
                style: const TextStyle(fontSize: 17.0),
              )),
          InfoCard(
              icon: Icons.book_outlined,
              title: '과목 정보',
              detail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('과목 코드: ${classInfo.subjectCode}',
                          semanticsLabel:
                          '과목 코드는 ${classInfo.subjectCode} 입니다.',
                          style: const TextStyle(fontSize: 17.0)),
                      IconButton(
                          tooltip: '과목 코드 복사',
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: classInfo.subjectCode))
                                .then((value) => {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('과목 코드가 복사되었습니다.'),
                                duration: Duration(seconds: 1),
                              ))
                            });
                          },
                          icon: const Icon(Icons.copy)),
                    ],
                  ),
                  Text(
                    '개설년도: ${classInfo.openYear}\n교과 종류: ${classInfo.subjectKind}\n학점: ${classInfo.point}',
                    semanticsLabel:
                    '개설 년도는 ${classInfo.openYear}년 이고 교과 종류는 ${classInfo.subjectKind}이며 학점은 ${classInfo.point}점 입니다.',
                    style: const TextStyle(fontSize: 17.0),
                  ),
                ],
              )),
          InfoCard(
              icon: Icons.work_outline,
              title: '강의자 정보',
              detail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '성별: ${classInfo.sex ?? '공개 안됨'}',
                    semanticsLabel: '성별은 ${classInfo.sex ?? '공개 안됨'} 입니다.',
                    style: const TextStyle(fontSize: 17.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '성함: ${classInfo.hostName ?? '공개 안됨'}',
                        semanticsLabel:
                        '성함은 ${classInfo.hostName ?? '공개 안됨'} 입니다.',
                        style: const TextStyle(fontSize: 17.0),
                      ),
                      IconButton(
                        onPressed: () => Clipboard.setData(ClipboardData(
                            text: classInfo.hostName ?? '공개 안됨'))
                            .then((value) => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                            content: Text('강의자 이름이 복사되었습니다.')))),
                        icon: const Icon(Icons.copy),
                        tooltip: '강의자 이름 복사',
                      )
                    ],
                  ),
                  Text(
                    '직책: ${classInfo.hostGrade ?? '공개 안됨'}',
                    semanticsLabel:
                    '직책은 ${classInfo.hostGrade ?? '공개 안됨'} 입니다.',
                    style: const TextStyle(fontSize: 17.0),
                  ),
                ],
              )),
          if (FirebaseAuth.instance.currentUser != null) ...[
            FutureBuilder<Contact?>(
                future: getContact(classInfo.guestDept, classInfo.hostName),
                builder: (context, snapshot) {
                  return InfoCard(
                      icon: Icons.call_outlined,
                      title: '강의자 연락사항',
                      detail: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) ...[
                            const CircularProgressIndicator.adaptive()
                          ] else if (snapshot.hasError) ...[
                            Text(
                                '연락처 정보를 가져오는데 문제가 발생했습니다.(오류 내용: ${snapshot.error})')
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '이메일: ${snapshot.data?.email ?? '공개되지 않음'}',
                                  semanticsLabel:
                                  '이메일은 ${snapshot.data?.email ?? '공개되지 않은 상태'} 입니다.',
                                  style: const TextStyle(fontSize: 17.0),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (snapshot.data?.email == null) {
                                      return;
                                    }
                                    Clipboard.setData(ClipboardData(
                                            text: classInfo.hostName))
                                        .then((value) => ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(SnackBar(
                                                content: const Text(
                                                    '이메일 주소가 복사되었습니다.'),
                                                duration:
                                                    const Duration(seconds: 1),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)))));
                                  },
                                  icon: const Icon(Icons.copy),
                                  tooltip: '이메일 주소 복사',
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '전화번호: ${snapshot.data?.phoneNumber ?? '공개되지 않음'}',
                                  semanticsLabel:
                                  '전화번호는 ${snapshot.data?.phoneNumber ?? '공개되지 않은 상태'} 입니다.',
                                  style: const TextStyle(fontSize: 17.0),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (snapshot.data?.phoneNumber == null) {
                                      return;
                                    }
                                    Clipboard.setData(ClipboardData(
                                            text: classInfo.hostName))
                                        .then((value) => ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(SnackBar(
                                                content: const Text(
                                                    '전화번호가 복사되었습니다.'),
                                                duration:
                                                    const Duration(seconds: 1),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)))));
                                  },
                                  icon: const Icon(Icons.copy),
                                  tooltip: '전화번호 복사',
                                )
                              ],
                            ),
                          ]
                        ],
                      ));
                })
          ] else ...[
            InfoCard(
                icon: Icons.call_outlined,
                title: '강의자 연락사항',
                detail: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [Text('해당 정보를 확인하기 위해서는 로그인이 필요합니다.')]))
          ],
          InfoCard(
              icon: Icons.school_outlined,
              title: '수업 관련 사항',
              detail: Text(
                '수업 장소 및 요일: ${classInfo.classLocation ?? '공개 안됨'}\n교양 영역: ${classInfo.region ?? '해당 없음'}\n수업 언어: ${classInfo.classLanguage ?? '공개 안됨'}',
                style: const TextStyle(fontSize: 17.0),
                semanticsLabel:
                '수업 장소 및 요일은 ${classInfo.classLocation ?? '공개 안됨'} 이며, 교양 영역은 ${classInfo.region ?? '해당 없음'} 이며, 수업 언어는 ${classInfo.classLanguage ?? '공개 안됨'} 입니다.',
              )),
          InfoCard(
              icon: Icons.info_outline,
              title: '추가 정보',
              detail: Text(
                '강의자 계약 정보: ${classInfo.promise ?? '공개 안됨'}\n수업 방식: ${classInfo.extra ?? '공개 안됨'}',
                style: const TextStyle(fontSize: 17.0),
                semanticsLabel:
                '강의자는 계약 종류는 ${classInfo.promise ?? '공개 안됨'} 이며 ${classInfo.extra ?? '공개 안됨'} 의 수업 방식을 따릅니다.',
              ))
        ],
      ),
    );
  }
}

/// 데이터를 불러올 수 없을 시 출력되는 경고 메세지이다.
///
/// 어떠한 이유로 인해 데이터를 불러올 수 없는 경우 메세지가 표시된다.
/// 반환되는 오류 메세지는 [errorMessage]를 통해 전달하면 된다.
class DataLoadingError extends StatelessWidget {
  /// 오류 메세지. 보통 [FutureBuilder]에서 `snapshot`에서 오류 발생 시
  /// 반환하는 `error`를 여기에 할당한다.
  final dynamic errorMessage;

  const DataLoadingError({required this.errorMessage, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline),
        Text(
          '데이터를 불러올 수 없습니다.\n오류정보: $errorMessage',
          semanticsLabel: '오류로 인해 데이터를 불러올 수 없습니다.',
        )
      ],
    );
  }
}

/// 앱에서 큼지막한 아이콘을 쓰는 메뉴 버튼에 쓰이는 위젯이다. 정사각형 형태를 보인다.
///
class SuwonSquareButton extends StatefulWidget {
  /// 버튼의 활성화 여부를 지정한다.
  ///
  /// 버튼에 동작이 지정된 경우에도 어떠한 설정에 의해 사용을 막아야 할 경우가 존재한다.
  /// 그럴 때 해당 속성을 `false`로 지정하면 사용을 막는 것이 가능하다.
  final bool? isActivate;

  /// 버튼의 아이콘을 지정한다.
  final IconData icon;

  /// 버튼의 이름을 지정한다.
  final String btnName;

  /// 버튼을 누를 시 동작을 지정한다.
  final void Function()? onPressed;

  /// 아이콘이 큼지막한 정사각형 버튼이다.
  ///
  /// 버튼의 활성화 여부를 [isActivate]를 통해 지정할 수 있으며 지정하지 않을 시 `true`로 간주한다.
  /// 버튼의 아이콘이나 이름은 [icon], [btnName]을 통해 지정이 가능하다.
  /// 버튼을 누를 시 동작을 지정하기 위해서는 [onPressed]를 지정해야 한다.
  const SuwonSquareButton({
    Key? key,
    this.isActivate,
    required this.icon,
    required String buttonName,
    required this.onPressed,
  })  : btnName = buttonName,
        super(key: key);

  @override
  State<SuwonSquareButton> createState() => _SuwonSquareButtonState();
}

class _SuwonSquareButtonState extends State<SuwonSquareButton> {
  /// 버튼을 누를 시 동작
  ///
  /// 버튼에 동작이 지정된 경우 버튼을 누를 때 동작을 수행하도록 한다.
  /// ## 같이보기
  /// * [SuwonSquareButton]
  void Function()? buttonAction() {
    if (widget.isActivate != null) {
      if (widget.isActivate == false) {
        return null;
      }
    }
    return widget.onPressed;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(12.0),
            child: IconButton(
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                foregroundColor: colors.onPrimary,
                backgroundColor: colors.primary,
                disabledBackgroundColor: colors.onSurface.withOpacity(0.12),
                hoverColor: colors.onPrimary.withOpacity(0.08),
                focusColor: colors.onPrimary.withOpacity(0.12),
                highlightColor: colors.onPrimary.withOpacity(0.12),
              ),
              onPressed: buttonAction(),
              icon: Icon(widget.icon),
              iconSize: 60.0,
              padding: const EdgeInsets.all(22.0),
            )),
        Text(
          widget.btnName,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          semanticsLabel: widget.btnName,
        )
      ],
    );
  }
}

/// 카드형태의 위젯으로 공지사항이나 개설 강좌 조회 시 나타나는 위젯
///
class SimpleCard extends StatefulWidget {
  /// 카드의 제목으로 상단에 위치하고 굵게 표시됨
  final String title;
  final String? subTitle;
  final Widget content;
  final Function()? onPressed;

  const SimpleCard({required this.title,
    this.subTitle,
    required this.content,
    Key? key,
    this.onPressed})
      : super(key: key);

  @override
  State<SimpleCard> createState() => _SimpleCardState();
}

class _SimpleCardState extends State<SimpleCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12.0)),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: InkWell(
          onTap: widget.onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  semanticsLabel: widget.title,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                if (widget.subTitle != null)
                  Text(
                    widget.subTitle!,
                    semanticsLabel: widget.subTitle!,
                    style: const TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                widget.content
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 특정 정보를 출력할 때 사용되는 위젯
///
/// [icon]으로 지정된 아이콘과 함께 어떤 정보를 출력하는데 사용된다. 아이콘 오른쪽에는
/// [title]이 출력된다. 세부 내용은 [detail]에서 정할 수 있는데 [Widget]타입이기 때문에
/// 임의의 위젯을 출력하는 것이 가능하다.
class InfoCard extends StatefulWidget {
  /// 카드 상단에 나타나는 아이콘
  final IconData icon;

  /// 아이콘 오른쪽에 표시되는 카드 제목
  final String title;

  /// 카드 내용
  final Widget detail;

  /// 어떠한 정보를 출력할 때 사용되는 위젯
  ///
  /// [icon]으로 지정된 아이콘과 함께 어떤 정보를 출력하는데 사용된다. 아이콘 오른쪽에는
  /// [title]이 출력된다. 세부 내용은 [detail]에서 정할 수 있는데 [Widget]타입이기 때문에
  /// 임의의 위젯을 출력하는 것이 가능하다.
  const InfoCard({Key? key, required this.icon, required this.title, required this.detail})
      : super(key: key);

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12.0)),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  widget.title,
                  semanticsLabel: widget.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                leading: Icon(
                  widget.icon,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              widget.detail
            ],
          ),
        ),
      ),
    );
  }
}

/// 과목을 검색하는 검색 상자이다.
class SearchBar extends StatefulWidget {
  /// 검색 상자 내 입력값이 변경 시 수행할 작업
  final void Function(String)? _onChanged;

  /// [_acceptIcon]클릭 시 수행할 작업
  final void Function()? _onAcceptPressed;

  /// 검색 상자의 왼쪽에 표시되는 아이콘
  final IconData? _icon;

  /// 검색 상자의 오른쪽에 표시되는 아이콘
  final IconData? _acceptIcon;

  /// 과목 검색 시 사용되는 검색창으로 보통 상단에 위치해있다.
  /// 검색 버튼에 들어갈 아이콘을 지정하는 [acceptIcon]을 지정할 수 있고,
  /// [onAcceptPressed]를 통해 검색 버튼이 눌릴 시의 동작을 정의할 수 있다.
  /// 또한 검색창 왼쪽의 아이콘인 [icon]을 지정하는 것이 가능하며
  /// 텍스트를 수정할 때 마다 수행할 동작을 지정하는 경우 [onChanged]를 사용할 수 있다.
  const SearchBar({Key? key,
    IconData? acceptIcon,
    void Function()? onAcceptPressed,
    required TextEditingController controller,
    IconData? icon,
    void Function(String)? onChanged})
      : _onChanged = onChanged,
        _icon = icon,
        _acceptIcon = acceptIcon,
        _onAcceptPressed = onAcceptPressed,
        _controller = controller,
        super(key: key);

  final TextEditingController _controller;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black12,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(25.0)),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                onChanged: widget._onChanged,
                controller: widget._controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '입력하여 검색',
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Icon(widget._icon),
                  ),
                ),
              ),
            ),
            if (widget._acceptIcon != null)
              IconButton(
                  onPressed: widget._onAcceptPressed,
                  icon: Icon(widget._acceptIcon))
          ],
        ),
      ),
    );
  }
}

/// 알림창에 해당하는 위젯이다. 보통 어떤 동작을 수행할 시 경고를 띄울 목적으로 활용이 가능하다.
///
/// ## 예제
///
/// ```dart
/// TextButton(
///     onPressed: () async {
///       showDialog(
///           barrierDismissible: false,
///           context: context,
///           builder: (BuildContext context) => SuwonDialog(
///                 icon: Icons.error_outline,
///                 title: '경고',
///                 content: const Text('앱의 데이터를 모두 지웁니까?'),
///                 onPressed: () async {
///                   SharedPreferences _pref =
///                       await SharedPreferences.getInstance();
///                   _pref.remove('favoritesMap');
///                   Navigator.of(context).pop();
///                 },
///               ));
///     },
///     style: ButtonStyle(
///         overlayColor: MaterialStateProperty.all(
///             Colors.redAccent.withAlpha(30)),
///         foregroundColor:
///             MaterialStateProperty.all(Colors.redAccent)),
///     child: const Text(
///       '디버그: 앱의 모든 설정 데이터 지우기',
///     ))
///```
class SuwonDialog extends StatelessWidget {
  final IconData _icon;
  final String _title;
  final Widget _content;
  final bool _isDestructive;
  final void Function()? _onPressed;

  /// 알림창에 해당하는 위젯이다.
  const SuwonDialog({
    required IconData icon,
    required String title,
    required Widget content,
    bool isDestructive = false,
    void Function()? onPressed,
    Key? key,
  })  : _icon = icon,
        _title = title,
        _content = content,
        _isDestructive = isDestructive,
        _onPressed = onPressed,
        super(key: key);

  /// 간단한 알림창에 해당하는 위젯으로 기존 알림창과 달리 단순 내용을 출력한다.
  ///
  /// 현재 화면의 `context`를 [context]로 넘겨주어야 한다.
  ///
  /// 알림창의 아이콘은 [icon]을 통해 지정 가능하며, [title]로 제목을 지정하고
  /// 내용으로 출력하고픈 것을 [content]를 통해 지정하면 된다.
  static Widget simple({required BuildContext context,
    required IconData icon,
    required String title,
    required Widget content}) {
    return AlertDialog(
      title: Column(
        children: [
          Icon(icon),
          const Padding(padding: EdgeInsets.only(right: 10.0)),
          Text(title)
        ],
      ),
      content: content,
      scrollable: true,
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'))
      ],
    );
  }

  ButtonStyle _okButtonStyle() {
    if (_isDestructive) {
      return ButtonStyle(
          overlayColor:
          MaterialStateProperty.all(Colors.redAccent.withAlpha(30)),
          foregroundColor: MaterialStateProperty.all(Colors.redAccent));
    }
    return const ButtonStyle();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Icon(_icon),
          const Padding(padding: EdgeInsets.only(right: 10.0)),
          Text(_title)
        ],
      ),
      content: _content,
      scrollable: true,
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소')),
        TextButton(
          onPressed: _onPressed,
          style: _okButtonStyle(),
          child: const Text('확인'),
        ),
      ],
    );
  }
}

/// 간단한 내용을 띄울 수 있도록 만든 카드형태의 위젯이다.
///
/// 단순한 메세지를 띄우거나 경고 메세지를 띄울 때 사용이 가능한 위젯이다.
/// 아이콘과 메세지 를 띄우며 *필요 시* 색상을 지정할 수 있다.
class NotiCard extends StatelessWidget {
  /// 메세지 왼쪽에 띄울 아이콘
  final IconData? icon;

  /// 카드의 배경색(지정 안해도 됨)
  final Color? color;

  /// 전달할 메세지
  final String message;

  /// 간단한 내용을 띄울 수 있도록 만든 카드형태의 위젯이다.
  ///
  /// [icon]을 통해 아이콘 지정이 가능하며 아이콘 오른쪽에 나타낼 메세지는
  /// [message]로 지정하면 된다.
  /// *필요 시* 배경 색을 지정하고 싶은 경우 [color]를 통해 가능하다.
  const NotiCard({
    this.icon,
    this.color,
    required this.message,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon ?? Icons.warning_amber_outlined),
            const Padding(padding: EdgeInsets.only(right: 10.0)),
            Flexible(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

/// 플랫폼에서 지원하지 않는 동작의 경우 표시되는 페이지이다.
///
/// 만일 지원하지 않는 플랫폼의 경우 해당 플랫폼의 이름인 [platform]과 함께 지원되지 않는다는 화면을 표시한다.
class NotSupportInPlatform extends StatelessWidget {
  /// 플랫폼 이름을 명시하는 속성이다.
  final String _platform;

  /// 플랫폼에서 지원하지 않는 동작의 경우 표시되는 페이지이다.
  const NotSupportInPlatform(String platform, {
    Key? key,
  })  : _platform = platform,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_outlined,
              color: Colors.redAccent, size: 45.0),
          Text(
            '$_platform 플랫폼에서는 지원되지 않습니다.',
            semanticsLabel: '$_platform 플랫폼에서는 지원되지 않습니다.',
          )
        ],
      ),
    );
  }
}

/// 데이터 절약 모드가 활성화된 경우 접근을 제한하기 위해 사용되는 페이지이다.
class DataSaveAlert extends StatelessWidget {
  const DataSaveAlert({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.offline_bolt_outlined, size: 80.0),
          Text(
            '현재 데이터 절약 모드로 인해 이 페이지를 열 수 없습니다.',
            style: TextStyle(fontSize: 16.0),
          )
        ],
      ),
    );
  }
}

/// 설정 창 맨 상단에 존재하는 로그인 위젯이다.
///
/// 이메일 링크를 통한 로그인을 지원하는 위젯이며, 로그인이 필요할 시 이메일을 받아
/// 로그인을 위한 링크를 전송하고, 로그인 되어있을 시 사용자의 이메일을 출력한다.
class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> with WidgetsBindingObserver {
  var loginController = LoginController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const InfoCard(
          icon: Icons.browser_not_supported,
          title: '로그인',
          detail: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Web버전에서는 로그인을 지원하지 않습니다.'),
          ));
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator.adaptive();
        } else if (snapshot.hasError) {
          return InfoCard(
              icon: Icons.error_outline,
              title: '오류',
              detail: Text(snapshot.error.toString()));
        } else {
          if (FirebaseAuth.instance.currentUser != null) {
            return InfoCard(
                icon: Icons.login_outlined,
                title: '로그인',
                detail: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                            '로그인된 계정: ${FirebaseAuth.instance.currentUser!.email ?? '이메일 공개 안됨'}'),
                        TextButton(
                            onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('로그아웃'),
                                    content: const Text('로그아웃 하시겠습니까?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('취소')),
                                      TextButton(
                                          onPressed: () {
                                            FirebaseAuth.instance
                                                .signOut()
                                                .then((value) =>
                                                    Navigator.pop(context));
                                          },
                                          child: const Text('확인')),
                                    ],
                                  ),
                                ),
                            child: const Text('로그아웃'))
                      ],
                    ),
                  ),
                ));
          } else {
            return InfoCard(
                icon: Icons.login_outlined,
                title: '로그인',
                detail: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text('로그인을 하면 강의자의 이메일이나 전화번호를 확인할 수 있습니다.'),
                      TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('이메일로 로그인'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('수원대 포털 이메일 계정이 필요합니다.'),
                                    TextField(
                                      controller:
                                          loginController.emailController,
                                      decoration: const InputDecoration(
                                          filled: true, labelText: '포털 이메일'),
                                    )
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        loginController.onLogin(context);
                                      },
                                      child: const Text('로그인')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('취소'))
                                ],
                              ),
                            );
                          },
                          child: const Text('수원대 이메일로 로그인')),
                    ],
                  ),
                ));
          }
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!kIsWeb) {
      FirebaseDynamicLinks.instance.onLink.listen((event) async {
        final Uri deepLink = event.link;
        if (FirebaseAuth.instance.isSignInWithEmailLink(deepLink.toString())) {
          try {
            FirebaseAuth.instance
                .signInWithEmailLink(
                    email: loginController.emailController.text,
                    emailLink: deepLink.toString())
                .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: const Text('로그인 되었습니다.'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)))));
          } catch (e) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text('오류'),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('확인'))
                      ],
                    ));
          }
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}