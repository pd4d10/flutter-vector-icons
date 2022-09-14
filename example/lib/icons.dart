import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data.dart';

class MyIcons extends StatelessWidget {
  final String? query;

  const MyIcons(this.query, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.entries.length,
      itemBuilder: (context, index) {
        var e0 = data.entries.toList()[index];
        var items = e0.value.entries
            .where((e1) => query == null || e1.key.contains(query!))
            .toList();

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(e0.key,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w500)),
            ),
            Wrap(
              children: items.map((e1) {
                return InkWell(
                  onTap: () async {
                    final text = '${e0.key}.${e1.key}';
                    await Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to Clipboard')));
                  },
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(20),
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
                          padding: const EdgeInsets.only(top: 10),
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
