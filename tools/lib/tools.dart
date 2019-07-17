import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';

var reservedWords = ['new', 'sync', 'switch', 'try', 'null', 'class'];

var root = path.join(path.dirname(Platform.script.path), '../..');

String readFileSync(String filePath) {
  return File(path.normalize(path.join(root, filePath))).readAsStringSync();
}

writeFileSync(String filePath, String contents) {
  File(path.normalize(path.join(root, filePath))).writeAsStringSync(contents);
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

String convert(String name, Map input) {
  var properties = input.entries.map((entry) {
    var key = getKey(entry.key);
    var value = entry.value;
    return 'static const IconData $key = IconData($value, fontFamily: "$name", fontPackage: "flutter_vector_icons");';
  }).join('\n');

  var code = '''import 'package:flutter/widgets.dart';

class $name {
  $properties
}
''';

  return DartFormatter().format(code);
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

void main() {
  // Clone repo
  var tmpDir = '/tmp';

  runCommand(
      'git clone https://github.com/oblador/react-native-vector-icons.git',
      workingDirectory: tmpDir);
  runCommand('git pull origin master',
      workingDirectory: path.join(tmpDir, 'react-native-vector-icons'));
  runCommand(
      'cp ${path.join(tmpDir, 'react-native-vector-icons/Fonts/*')} ${path.join(root, 'flutter_vector_icons/fonts')}');
  runCommand(
      'cp -r ${path.join(tmpDir, 'react-native-vector-icons/glyphmaps')} ${path.join(root, 'tools')}');

  var names = [
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

  names.forEach((name) {
    var content = readFileSync('tools/glyphmaps/$name.json');
    var input = json.decode(content);
    var result = convert(name, input);
    var fileName = toSnakeCase(name);

    writeFileSync('flutter_vector_icons/lib/src/$fileName.dart', result);
    print('$fileName done');
  });

  // entry
  var exports = names.map((name) {
    var fileName = toSnakeCase(name);
    return "export 'src/$fileName.dart';";
  }).join('\n');
  var result = '''library flutter_vector_icons;
$exports
''';
  writeFileSync('flutter_vector_icons/lib/flutter_vector_icons.dart',
      DartFormatter().format(result));

  // web project
  Map webData = {};
  List fontManifest = [];
  names.forEach((name) {
    var content = readFileSync('tools/glyphmaps/$name.json');

    Map input = json.decode(content);
    webData[name] = Map.fromEntries(
        input.entries.map((entry) => MapEntry(getKey(entry.key), entry.value)));
    fontManifest.add({
      "family": name,
      "fonts": [
        {"asset": "fonts/$name.ttf"}
      ]
    });
  });

  var content = 'var data =' + json.encode(webData) + ';';
  writeFileSync('flutter_vector_icons_gallery/lib/data.dart',
      DartFormatter().format(content));

  writeFileSync('flutter_vector_icons_gallery/web/assets/FontManifest.json',
      json.encode(fontManifest));
}
