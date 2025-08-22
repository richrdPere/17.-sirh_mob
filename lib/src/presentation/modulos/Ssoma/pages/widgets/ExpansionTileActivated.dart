import 'package:flutter/material.dart';

class ExpansionTileActivated extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expansión lateral")),
      body: ListView(
        children: [
          ExpansionTile(
            leading: Icon(Icons.warning, color: Colors.orange),
            title: Text("Peligros"),
            trailing: Icon(Icons.arrow_right),
            children: [
              ListTile(title: Text("Registrar peligro")),
              ListTile(title: Text("Ver lista de peligros")),
            ],
          ),
        ],
      ),
    );
  }
}
