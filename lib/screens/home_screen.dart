import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nav")),
      body: Center(child: Text('Dashboard')),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            Text('Dashboard'),
            ExpansionTile(
              title: Text("User management"),
              children: <Widget>[
                Text("Users"),
                Text("Add user"),
                Text("Migrate users")
              ],
            ),
            ExpansionTile(
              title: Text("Remittance management"),
              children: <Widget>[
                Text("Add remittance"),
                Text("Trace remittance"),
                Text("Remittance history"),
                Text("Search remittances"),
                Text("Online remittance requests")
              ],
            )
          ],
        ),
      ),
    );
  }
}
