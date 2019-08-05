import 'package:flutter_web/material.dart';
import 'data.dart';

class MyIcons extends StatelessWidget {
  final String query;

  MyIcons(this.query);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: data.entries.map((e0) {
        return Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text(e0.key,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            ),
            Wrap(
              children: e0.value.entries
                  .where((e1) => query == null || e1.key.contains(query))
                  .map((e1) {
                return Container(
                  width: 160,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Icon(IconData(e1.value, fontFamily: e0.key), size: 32),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(e1.key),
                      )
                    ],
                  ),
                );
              }).toList(),
            )
          ],
        );
      }).toList(),
    );
  }
}
