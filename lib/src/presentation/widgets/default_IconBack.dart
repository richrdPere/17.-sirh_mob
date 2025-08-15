import 'package:flutter/material.dart';
// Router
import 'package:go_router/go_router.dart';


class DefaultIconBack extends StatelessWidget {
  double left;
  double top;

  DefaultIconBack({super.key, required this.left, required this.top});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(left: left, top: top),
      child: IconButton(
        onPressed: () {
          // Navigator.pop(context);
          context.go('/login');
        },
        icon: Icon(Icons.arrow_back_ios, size: 40, color: Colors.white),
      ),
    );
  }
}
