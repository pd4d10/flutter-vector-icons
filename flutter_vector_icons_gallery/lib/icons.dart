import 'package:flutter_web/material.dart';
import 'data.dart';

class MyIcons extends StatelessWidget {
  final String query;

  MyIcons(this.query);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.entries.length,
      itemBuilder: (context, index) {
        var e0 = data.entries.toList()[index];
        var items = e0.value.entries
            .where((e1) => query == null || e1.key.contains(query))
            .toList();

        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(e0.key,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            ),
            Wrap(
              children: items.map((e1) {
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
      },
    );
  }
}
