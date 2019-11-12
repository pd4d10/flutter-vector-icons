import 'dart:html' as html; // FIXME:
import 'package:flutter/material.dart';
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
                return InkWell(
                  onTap: () async {
                    final text = e0.key + '.' + e1.key;
                    await html.window.navigator.clipboard.writeText(text);
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Copied to Clipboard')));
                  },
                  child: Container(
                    width: 160,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          IconData(
                            e1.value,
                            fontFamily: e0.key,
                            fontPackage: 'flutter_vector_icons',
                          ),
                          size: 32,
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(e1.key),
                        )
                      ],
                    ),
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
