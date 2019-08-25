import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';

var reservedWords = ['new', 'sync', 'switch', 'try', 'null', 'class'];

var root = path.join(path.dirname(Platform.script.path), '..');

var fontNames = [
  'AntDesign',
  'Entypo',
  'EvilIcons',
  'Feather',
  'FontAwesome',
  'Fontisto',
  'Foundation',
  'Ionicons',
  'MaterialCommunityIcons',
  'MaterialIcons',
  'Octicons',
  'SimpleLineIcons',
  'Zocial'
];

var fa5FontNames = [
  'FontAwesome5_Brands',
  'FontAwesome5_Regular',
  'FontAwesome5_Solid'
];

String getAbsolutePath(String filePath) {
  return path.normalize(path.join(root, filePath));
}

// * Replace - with _
// * Language reserved words: new -> new_icon
// * Key starts with number: 500px -> icon_500px
String normalizeKey(String key) {
  key = key.replaceAll('-', '_');
  var _key = key;
  if (reservedWords.contains(key)) {
    key = key + '_icon';
  }
  if (key.startsWith(RegExp(r'\d'))) {
    key = 'icon_' + key;
  }
  if (key != _key) {
    print('[name conversion]: $_key -> $key');
  }
  return key;
}

// FontAwesome5_Brands -> brands
String getFa5FontMapKey(String name) {
  return name.split('_')[1].toLowerCase();
}

// FontAwesome5_Brands -> FontAwesome5Brands
String toClassName(String name) {
  return name.replaceAll('_', '');
}

// AntDesign -> ant_design
// FontAwesome5_Brands -> font_awesome_5_brands
String toFileName(String input) {
  return input
      .replaceAllMapped(RegExp(r'([A-Z0-9])'), (match) {
        var char = match.group(0);
        return '_$char';
      })
      .replaceAll('__', '_')
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
  // lib/flutter_vector_icons.dart
  var entryCode = 'library flutter_vector_icons;';
  for (var name in [...fontNames, ...fa5FontNames]) {
    var fileName = toFileName(name);
    entryCode += "export 'src/$fileName.dart';";
  }
  File(getAbsolutePath('flutter_vector_icons/lib/flutter_vector_icons.dart'))
      .writeAsStringSync(DartFormatter().format(entryCode));

  // lib/src/*.dart
  // fonts
  for (var name in fontNames) {
    var iconMap = json.decode(File(getAbsolutePath(
            'vendor/react-native-vector-icons/glyphmaps/$name.json'))
        .readAsStringSync()) as Map;

    var code = '''import 'package:flutter/widgets.dart'; class $name {''';
    for (var e in iconMap.entries) {
      var key = normalizeKey(e.key);
      var value = e.value;
      code +=
          'static const IconData $key = IconData($value, fontFamily: "$name", fontPackage: "flutter_vector_icons");';
    }
    code += '}';

    var fileName = toFileName(name);
    File(getAbsolutePath('flutter_vector_icons/lib/src/$fileName.dart'))
        .writeAsStringSync(DartFormatter().format(code));
    print('$name done');
  }

  // font awesome 5
  var fa5Meta = json.decode(File(getAbsolutePath(
          'vendor/react-native-vector-icons/glyphmaps/FontAwesome5Free_meta.json'))
      .readAsStringSync());
  var fa5GlyphMap = json.decode(File(getAbsolutePath(
          'vendor/react-native-vector-icons/glyphmaps/FontAwesome5Free.json'))
      .readAsStringSync());

  for (var name in fa5FontNames) {
    var className = toClassName(name);
    var code = '''import 'package:flutter/widgets.dart'; class $className {''';

    for (var key in fa5Meta[getFa5FontMapKey(name)]) {
      var nKey = normalizeKey(key);
      var codePoint = fa5GlyphMap[key];
      if (codePoint == null) {
        throw 'codePoint null: $name, $key';
      }
      code +=
          'static const IconData $nKey = IconData($codePoint, fontFamily: "$name", fontPackage: "flutter_vector_icons");';
    }
    code += '}';

    var fileName = toFileName(name);
    File(getAbsolutePath('flutter_vector_icons/lib/src/$fileName.dart'))
        .writeAsStringSync(DartFormatter().format(code));
    print('$name done');
  }
}

generateWebData() {
  // data.dart
  Map webData = {};
  for (var name in fontNames) {
    var glyphMap = json.decode(File(getAbsolutePath(
            'vendor/react-native-vector-icons/glyphmaps/$name.json'))
        .readAsStringSync()) as Map;
    var result = {};
    for (var e in glyphMap.entries) {
      result[normalizeKey(e.key)] = e.value;
    }
    webData[name] = result;
  }

  var fa5Meta = json.decode(File(getAbsolutePath(
          'vendor/react-native-vector-icons/glyphmaps/FontAwesome5Free_meta.json'))
      .readAsStringSync()) as Map;
  var fa5GlyphMap = json.decode(File(getAbsolutePath(
          'vendor/react-native-vector-icons/glyphmaps/FontAwesome5Free.json'))
      .readAsStringSync()) as Map;
  for (var name in fa5FontNames) {
    var result = {};
    for (var key in fa5Meta[getFa5FontMapKey(name)]) {
      result[normalizeKey(key)] = fa5GlyphMap[key];
    }
    webData[name] = result;
  }

  File(getAbsolutePath('flutter_vector_icons_gallery/lib/data.dart'))
      .writeAsStringSync(
          DartFormatter().format('var data =' + json.encode(webData) + ';'));

  // FontManifest.json
  var fontManifest = [...fontNames, ...fa5FontNames].map((name) {
    return {
      "family": name,
      "fonts": [
        {"asset": "fonts/$name.ttf"}
      ]
    };
  }).toList();
  File(getAbsolutePath(
          'flutter_vector_icons_gallery/web/assets/FontManifest.json'))
      .writeAsStringSync(json.encode(fontManifest));

  // pubspec.yaml
  var pubspecString = File(getAbsolutePath('flutter_vector_icons/pubspec.yaml'))
      .readAsStringSync();
  var l = pubspecString.split('''flutter:
  fonts:
''');
  l[1] = '';
  for (var item in fontManifest) {
    var family = item['family'];
    var asset = (item['fonts'] as List)[0]['asset'];
    l[1] += '    - family: $family\n';
    l[1] += '''      fonts:
        - asset: $asset
''';
  }

  File(getAbsolutePath('flutter_vector_icons/pubspec.yaml'))
      .writeAsStringSync(l.join('''flutter:
  fonts:
'''));
}

void main() {
  var vendorDir = './vendor';

  // Copy fonts
  runCommand(
      'cp ${path.join(vendorDir, 'react-native-vector-icons/Fonts/*')} ${path.join(root, 'flutter_vector_icons/fonts')}');

  generateFonts();
  generateWebData();
}
