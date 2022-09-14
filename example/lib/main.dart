import 'package:flutter/material.dart';
import 'package:flutter_vector_icons_gallery/icons.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyApp());

const title = 'Flutter Vector Icons Gallery';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

class _MySearchDelegate extends SearchDelegate<String?> {
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return MyIcons(query);
  }

  @override
  Widget buildResults(BuildContext context) {
    return MyIcons(query);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;
  final _delegate = _MySearchDelegate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title!),
        actions: <Widget>[
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              await showSearch<String?>(
                context: context,
                delegate: _delegate,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Source Code',
            onPressed: () {
              launchUrl(
                  Uri.parse('https://github.com/pd4d10/flutter-vector-icons'));
            },
          )
        ],
      ),
      body: const MyIcons(null),
    );
  }
}
