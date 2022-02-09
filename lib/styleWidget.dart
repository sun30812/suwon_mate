import 'package:flutter/material.dart';

class SuwonButton extends StatelessWidget {
  IconData icon;
  String btnName;
  void Function()? onPressed;
  SuwonButton({
    Key? key,
    required IconData icon,
    required String buttonName,
    required void Function()? onPressed,
  })  : this.icon = icon,
        btnName = buttonName,
        this.onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              Padding(
                padding: EdgeInsets.all(2),
              ),
              Text(
                btnName,
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              minimumSize: MaterialStateProperty.all(Size(90, 40)),
              elevation: MaterialStateProperty.all(2.0),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              )))),
    );
  }
}