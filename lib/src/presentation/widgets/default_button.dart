import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  String text;
  Function onPressed;
  Color color;

  DefaultButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 55,
      // margin: EdgeInsets.only(left: 25, right: 25, top: 15),
      child: ElevatedButton(
        onPressed: () {
          onPressed();
        },
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
