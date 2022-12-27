import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suwon_mate/model/class_info.dart';

/// 강좌에 대한 세부 정보를 보여주는 페이지이다.
class ClassDetailInfoCard extends StatelessWidget {
  final ClassInfo classInfo;
  const ClassDetailInfoCard({required this.classInfo, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView(
        children: [
          InfoCard(
              icon: Icons.account_circle_outlined,
              title: '수업 대상자',
              detail: Text(
                '대상 학년: ${classInfo.guestGrade}\n대상 학부: ${classInfo.guestDept}\n'
                '대상 학과: ${classInfo.guestMjor}',
                semanticsLabel:
                    '대상 학년은 ${classInfo.guestGrade} 이고 대상 학부는 ${classInfo.guestDept} 이며 대상 학과는 ${classInfo.guestMjor} 입니다.',
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
                    '성별: ${classInfo.sex}',
                    semanticsLabel: '성별은 ${classInfo.sex}성 입니다.',
                    style: const TextStyle(fontSize: 17.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '성함: ${classInfo.hostName}',
                        semanticsLabel: '성함은 ${classInfo.hostName} 입니다.',
                        style: const TextStyle(fontSize: 17.0),
                      ),
                      IconButton(
                        onPressed: () => Clipboard.setData(ClipboardData(
                          text: classInfo.hostName
                        )).then((value) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('강의자 이름이 복사되었습니다.')))),
                        icon: const Icon(Icons.copy),
                        tooltip: '강의자 이름 복사',
                      )
                    ],
                  ),
                  Text(
                    '직책: ${classInfo.hostGrade}',
                    semanticsLabel: '직책은 ${classInfo.hostGrade} 입니다.',
                    style: const TextStyle(fontSize: 17.0),
                  ),
                ],
              )),
          InfoCard(
              icon: Icons.school_outlined,
              title: '수업 관련 사항',
              detail: Text(
                '수업 장소 및 요일: ${classInfo.classLocation}\n교양 영역: ${classInfo.region ?? '해당 없음'}\n수업 언어: ${classInfo.classLanguage}',
                style: const TextStyle(fontSize: 17.0),
                semanticsLabel:
                    '수업 장소 및 요일은 ${classInfo.classLocation} 이며, 교양 영역은 ${classInfo.region ?? '해당 없음'} 이며, 수업 언어는 ${classInfo.classLanguage} 입니다.',
              )),
          InfoCard(
              icon: Icons.info_outline,
              title: '추가 정보',
              detail: Text(
                '강의자 계약 정보: ${classInfo.promise}\n수업 방식: ${classInfo.extra}',
                style: const TextStyle(fontSize: 17.0),
                semanticsLabel:
                    '강의자는 계약 종류는 ${classInfo.promise} 이며 ${classInfo.extra} 의 수업 방식을 따릅니다.',
              ))
        ],
      ),
    );
  }
}

/// 데이터를 불러올 수 없을 시 출력되는 경고 메세지이다.
///
/// 어떠한 이유로 인해 데이터를 불러올 수 없는 경우 메세지가 표시된다.
class DataLoadingError extends StatelessWidget {
  const DataLoadingError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: const [
          Icon(Icons.error_outline),
          Text(
            '데이터를 불러올 수 없습니다.',
            semanticsLabel: '데이터를 불러올 수 없습니다.',
          )
        ],
      ),
    );
  }
}

/// 앱에서 큼지막한 아이콘을 쓰는 메뉴 버튼에 쓰이는 위젯이다. 정사각형 형태를 보인다.
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
  bool _isClicked = false;
  void Function()? buttonAction() {
    if (widget.isActivate != null) {
      if (widget.isActivate == false) {
        return null;
      }
    }
    return widget.onPressed;
  }

  /// 활성화 된 버튼일 경우 버튼을 누를 때 효과를 준다.
  Color smartColor() {
    if ((widget.isActivate ?? true) && (widget.onPressed != null)) {
      return Colors.grey[700]!;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapCancel: () => setState(() {
        _isClicked = false;
      }),
      onTapDown: (_) => setState(() {
        if (widget.isActivate ?? true) {
          _isClicked = !_isClicked;
        }
      }),
      onTapUp: (_) => setState(() {
        if (widget.isActivate ?? true) {
          _isClicked = !_isClicked;
        }
      }),
      onTap: () {
        if ((widget.onPressed != null) && (widget.isActivate ?? true)) {
          widget.onPressed!();
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: AnimatedContainer(
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: !_isClicked && (widget.isActivate ?? true)
                      ? [
                          BoxShadow(
                              offset: const Offset(3, 3),
                              blurRadius: 15,
                              spreadRadius: 0.5,
                              color: Colors.grey[500]!),
                          const BoxShadow(
                              offset: Offset(-3, -3),
                              blurRadius: 15,
                              spreadRadius: 0.5,
                              color: Colors.white)
                        ]
                      : null),
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    widget.icon,
                    size: 45.0,
                    color: smartColor(),
                  ),
                ]),
              ),
            ),
          ),
          Text(
            widget.btnName,
            semanticsLabel: widget.btnName,
            style: TextStyle(color: smartColor(), fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}

class SuwonButton extends StatefulWidget {
  final bool? isActivate;
  final IconData icon;
  final String btnName;
  final void Function()? onPressed;
  const SuwonButton({
    Key? key,
    this.isActivate,
    required this.icon,
    required String buttonName,
    required this.onPressed,
  })  : btnName = buttonName,
        super(key: key);

  @override
  State<SuwonButton> createState() => _SuwonButtonState();
}

class _SuwonButtonState extends State<SuwonButton> {
  bool _isClicked = false;
  void Function()? buttonAction() {
    if (widget.isActivate != null) {
      if (widget.isActivate == false) {
        return null;
      }
    }
    return widget.onPressed;
  }

  Color smartColor() {
    if ((widget.isActivate ?? true) && (widget.onPressed != null)) {
      return Colors.grey[800]!;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapCancel: () => setState(() {
        _isClicked = false;
      }),
      onTapDown: (_) => setState(() {
        if (widget.isActivate ?? true) {
          _isClicked = !_isClicked;
        }
      }),
      onTapUp: (_) => setState(() {
        if (widget.isActivate ?? true) {
          _isClicked = !_isClicked;
        }
      }),
      onTap: () {
        if ((widget.onPressed != null) && (widget.isActivate ?? true)) {
          widget.onPressed!();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AnimatedContainer(
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: !_isClicked && (widget.isActivate ?? true)
                  ? [
                      BoxShadow(
                          offset: const Offset(3, 3),
                          blurRadius: 15,
                          spreadRadius: 0.5,
                          color: Colors.grey[500]!),
                      const BoxShadow(
                          offset: Offset(-3, -3),
                          blurRadius: 15,
                          spreadRadius: 0.5,
                          color: Colors.white)
                    ]
                  : null),
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                widget.icon,
                color: smartColor(),
              ),
              const Padding(padding: EdgeInsets.only(right: 3.0)),
              Text(
                widget.btnName,
                semanticsLabel: widget.btnName,
                style:
                    TextStyle(color: smartColor(), fontWeight: FontWeight.bold),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

class SimpleCardButton extends StatefulWidget {
  final String title;
  final String? subTitle;
  final Widget content;
  final Function()? onPressed;

  const SimpleCardButton(
      {required this.title,
      this.subTitle,
      required this.content,
      Key? key,
      this.onPressed})
      : super(key: key);

  @override
  State<SimpleCardButton> createState() => _SimpleCardButtonState();
}

class _SimpleCardButtonState extends State<SimpleCardButton> {
  bool _isClicked = false;
  @override
  Widget build(BuildContext context) {
    Widget subTitleWidget(String? text) {
      if (text != null) {
        return Text(
          text,
          semanticsLabel: text,
          style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
        );
      } else {
        return Container();
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTapCancel: () => setState(() {
          if (widget.onPressed == null) {
            return;
          }
          _isClicked = false;
        }),
        onTapDown: (_) => setState(() {
          if (widget.onPressed == null) {
            return;
          }
          _isClicked = !_isClicked;
        }),
        onTapUp: (_) => setState(() {
          if (widget.onPressed == null) {
            return;
          }
          _isClicked = !_isClicked;
        }),
        onTap: () {
          if (widget.onPressed != null) {
            widget.onPressed!();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.grey[300],
              boxShadow: !_isClicked
                  ? [
                      BoxShadow(
                          offset: const Offset(3, 3),
                          blurRadius: 15,
                          spreadRadius: 0.5,
                          color: Colors.grey[500]!),
                      const BoxShadow(
                          offset: Offset(-3, -3),
                          blurRadius: 15,
                          spreadRadius: 0.5,
                          color: Colors.white)
                    ]
                  : null),
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
                subTitleWidget(widget.subTitle),
                widget.content
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 어떠한 정보를 출력할 떄 사용되는 위젯
///
/// [icon]으로 지정된 아이콘과 함께 어떤 정보를 출력하는데 사용된다. 아이콘 오른쪽에는
/// [title]이 출력된다. 세부 내용은 [detail]에서 정할 수 있는데 [Widget]타입이기 때문에
/// 글자를 출력할 수도 있고 임의의 위젯을 출력하는 것도 가능하다.
class InfoCard extends StatefulWidget {
  /// 카드 상단에 나타나는 아이콘
  final IconData icon;

  /// 아이콘 오른쪽에 표시되는 카드 제목
  final String title;

  /// 카드 내용
  final Widget detail;

  /// 어떠한 정보를 출력할 떄 사용되는 위젯
  ///
  /// [icon]으로 지정된 아이콘과 함께 어떤 정보를 출력하는데 사용된다. 아이콘 오른쪽에는
  /// [title]이 출력된다. 세부 내용은 [detail]에서 정할 수 있는데 [Widget]타입이기 때문에
  /// 글자를 출력할 수도 있고 임의의 위젯을 출력하는 것도 가능하다.
  const InfoCard(
      {Key? key, required this.icon, required this.title, required this.detail})
      : super(key: key);

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.grey[300],
            boxShadow: [
              BoxShadow(
                  offset: const Offset(3, 3),
                  blurRadius: 15,
                  spreadRadius: 0.5,
                  color: Colors.grey[500]!),
              const BoxShadow(
                  offset: Offset(-3, -3),
                  blurRadius: 25,
                  spreadRadius: 0.5,
                  color: Colors.white)
            ]),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(widget.icon),
                  const Padding(padding: EdgeInsets.only(right: 10.0)),
                  Text(
                    widget.title,
                    semanticsLabel: widget.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                ],
              ),
              const Divider(),
              widget.detail
            ],
          ),
        ),
      ),
    );
  }
}

/// 과목 검색 시 사용되는 검색창이다.
class SearchBar extends StatefulWidget {
  final void Function(String)? _onChanged;
  final void Function()? _onAcceptPressed;
  final IconData? _icon;
  final IconData? _acceptIcon;

  /// 과목 검색 시 사용되는 검색창으로 보통 상단에 위치해있다.
  /// 검색 버튼에 들어갈 아이콘을 지정하는 [acceptIcon]을 지정할 수 있고,
  /// [onAcceptPressed]를 통해 검색 버튼이 눌릴 시의 동작을 정의할 수 있다.
  /// 또한 검색창 왼쪽의 아이콘인 [icon]을 지정하는 것이 가능하며
  /// 텍스트를 수정할 때 마다 수행할 동작을 지정하는 경우 [onChanged]를 사용할 수 있다.
  const SearchBar(
      {Key? key,
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
                  hintText: "입력하여 검색",
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

  static Widget simple(
      {required BuildContext context,
      required IconData icon,
      required String title,
      required Widget content}) {
    return AlertDialog(
      title: Row(
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

  ButtonStyle okButtonStyle() {
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
      title: Row(
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
          onPressed: _onPressed,
          child: const Text('확인'),
          style: okButtonStyle(),
        ),
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'))
      ],
    );
  }
}

class NotiCard extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final String message;
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
  /// 플랫폼 이름을 명시하는 변수이다.
  final String _platform;

  /// 플랫폼에서 지원하지 않는 동작의 경우 표시되는 페이지이다.
  const NotSupportInPlatform(
    String platform, {
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

class NotSupportPlatformMessage extends StatelessWidget {
  const NotSupportPlatformMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return MaterialBanner(
          content: const Text(
            'Web 플랫폼의 경우 일부 기능이 동작하지 않습니다.',
            semanticsLabel: 'Web 플랫폼의 경우 일부 기능이 동작하지 않습니다.',
          ),
          actions: [
            TextButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => SuwonDialog.simple(
                        context: context,
                        icon: Icons.help_outline,
                        title: '안내',
                        content: const Text(
                          'Web 플랫폼에서는 [학사 일정]이나 [공지사항] 기능을 사용할 수 없습니다.',
                          semanticsLabel:
                              'Web 플랫폼에서는 [학사 일정]이나 [공지사항] 기능을 사용할 수 없습니다.',
                        ))),
                child: const Text(
                  '설명 보기',
                  semanticsLabel: '설명 보기',
                ))
          ]);
    }
    return Container();
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
