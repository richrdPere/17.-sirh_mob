import 'package:flutter/material.dart';

class RolesItem extends StatelessWidget {
  // Role role;
  String role;

  RolesItem(this.role, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          child: FadeInImage(
            image: NetworkImage(
              'https://firebasestorage.googleapis.com/v0/b/patrullajes-serenazgo-cusco.firebasestorage.app/o/admin%20png.png?alt=media&token=6209f6ce-dc38-4a99-bcf6-ba90f726a7db',
            ),
            fit: BoxFit.contain,
            fadeInDuration: Duration(milliseconds: 1),
            placeholder: AssetImage('assets/img/no-image.png'),
          ),
        ),
        Text('Admin', style: TextStyle(fontSize: 15, color: Colors.black)),
      ],
    );
  }
}
