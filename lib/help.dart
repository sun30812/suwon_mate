import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('도움말'),
      ),
      body: Center(
        child:
          Card(
            child: Column(
              children: [
                Text('개설 강좌 안내', style: TextStyle(fontWeight: FontWeight.bold),),
                Divider(),
                Text('본인 전공을 고르시면 그에 맞는 과목이 나옵니다. 과목을 누르면 더욱 자세히 볼 수 있습니다.\n'
                    '주의사항: 학부 공용 과목은 학부를 선택해야 나옵니다.')
              ],
            ),
          )
      ),
    );
  }
}
