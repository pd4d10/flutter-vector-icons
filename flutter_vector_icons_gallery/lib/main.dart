import 'dart:html' as html;
import 'package:flutter_web/material.dart';
import 'data.dart';

void main() => runApp(MyApp());

final title = 'Flutter Vector Icons Gallery';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Source Code',
            onPressed: () {
              html.window
                  .open('https://github.com/pd4d10/flutter-vector-icons', '');
            },
          )
        ],
      ),
      body: ListView(
        children: data.entries.map((e0) {
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Text(e0.key,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              ),
              Wrap(
                children: e0.value.entries.map((e1) {
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
      ),
    );
  }
}
