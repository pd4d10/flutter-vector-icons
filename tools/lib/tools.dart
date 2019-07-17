import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';

var reservedWords = ['new', 'sync', 'switch', 'try', 'null', 'class'];

var root = path.join(path.dirname(Platform.script.path), '../..');

String getAbsolutePath(String filePath) {
  return path.normalize(path.join(root, filePath));
}

// * Replace - with _
// * Language reserved words: new -> new_icon
// * Key starts with number: 500px -> icon_500px
String getKey(String key) {
  key = key.replaceAll('-', '_');
  if (reservedWords.contains(key)) {
    key = key + '_icon';
  }
  if (key.startsWith(RegExp(r'\d'))) {
    key = 'icon_' + key;
  }
  return key;
}

// AntDesign -> ant_design
String toSnakeCase(String input) {
  return input
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) {
        var char = match.group(0);
        return '_$char';
      })
      .substring(1)
      .toLowerCase();
}

runCommand(String command, {String workingDirectory}) {
  var res = Process.runSync('/bin/bash', ['-c', command],
      workingDirectory: workingDirectory);
  print(res.stdout);
  print(res.stderr);
}

generateFonts() {
  var fontNames = [
    'AntDesign',
    'Entypo',
    'EvilIcons',
    'Feather',
    'FontAwesome',
    // 'FontAwesome5_Brands',
    // 'FontAwesome5_Regular',
    // 'FontAwesome5_Solid',
    'Fontisto',
    'Foundation',
    'Ionicons',
    'MaterialCommunityIcons',
    'MaterialIcons',
    'Octicons',
    'SimpleLineIcons',
    'Zocial'
  ];

  // lib/flutter_vector_icons.dart
  var entryCode = 'library flutter_vector_icons;';
  for (var name in fontNames) {
    var fileName = toSnakeCase(name);
    entryCode += "export 'src/$fileName.dart';";
  }
  File(getAbsolutePath('flutter_vector_icons/lib/flutter_vector_icons.dart'))
      .writeAsStringSync(DartFormatter().format(entryCode));

  // lib/src/*.dart
  for (var name in fontNames) {
    var fileName = toSnakeCase(name);
    var iconMap = json.decode(
        File(getAbsolutePath('tools/glyphmaps/$name.json'))
            .readAsStringSync()) as Map;

    var code = '''import 'package:flutter/widgets.dart'; class $name {''';
    for (var e in iconMap.entries) {
      var key = getKey(e.key);
      var value = e.value;
      code +=
          'static const IconData $key = IconData($value, fontFamily: "$name", fontPackage: "flutter_vector_icons");';
    }
    code += '}';

    File(getAbsolutePath('flutter_vector_icons/lib/src/$fileName.dart'))
        .writeAsStringSync(DartFormatter().format(code));
    print('$name done');
  }

  // web project
  Map webData = {};
  List fontManifest = [];
  for (var name in fontNames) {
    var content =
        File(getAbsolutePath('tools/glyphmaps/$name.json')).readAsStringSync();

    Map input = json.decode(content);
    webData[name] = Map.fromEntries(
        input.entries.map((entry) => MapEntry(getKey(entry.key), entry.value)));
    fontManifest.add({
      "family": name,
      "fonts": [
        {"asset": "fonts/$name.ttf"}
      ]
    });
  }

  File(getAbsolutePath('flutter_vector_icons_gallery/lib/data.dart'))
      .writeAsStringSync(
          DartFormatter().format('var data =' + json.encode(webData) + ';'));
  File(getAbsolutePath(
          'flutter_vector_icons_gallery/web/assets/FontManifest.json'))
      .writeAsStringSync(json.encode(fontManifest));
}

void main() {
  // Clone repo
  var tmpDir = '/tmp';

  runCommand(
      'git clone https://github.com/oblador/react-native-vector-icons.git',
      workingDirectory: tmpDir);
  runCommand('git pull origin master',
      workingDirectory: path.join(tmpDir, 'react-native-vector-icons'));
  // Copy fonts
  runCommand(
      'cp ${path.join(tmpDir, 'react-native-vector-icons/Fonts/*')} ${path.join(root, 'flutter_vector_icons/fonts')}');
  // Copy glyphmaps
  runCommand(
      'cp -r ${path.join(tmpDir, 'react-native-vector-icons/glyphmaps')} ${path.join(root, 'tools')}');

  generateFonts();
}
