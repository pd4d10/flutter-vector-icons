import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';

final reservedWords = ['new', 'sync', 'switch', 'try', 'null', 'class'];
final fontNames = ['AntDesign', 'Entypo', 'EvilIcons', 'Feather', 'FontAwesome', 'Fontisto', 'Foundation', 'Ionicons', 'MaterialCommunityIcons', 'MaterialIcons', 'Octicons', 'SimpleLineIcons', 'Zocial'];
final fa5FontNames = ['FontAwesome5_Brands', 'FontAwesome5_Regular', 'FontAwesome5_Solid'];
final root = path.join(path.dirname(Platform.isWindows ? Platform.script.path.replaceFirst('/', '') : Platform.script.path), '..');
final dartFormatter = DartFormatter();

String getAbsolutePath(String filePath) => path.normalize(path.join(root, filePath));

// * Replace - with _
// * Language reserved words: new -> new_icon
// * Key starts with number: 500px -> icon_500px
String normalizeKey(String key) {
  key = key.replaceAll('-', '_');
  final _key = key;

  if (reservedWords.contains(key)) key = key + '_icon';
  if (key.startsWith(RegExp(r'\d'))) key = 'icon_' + key;
  if (key != _key) print('[name conversion]: $_key -> $key');

  return key;
}

// FontAwesome5_Brands -> brands
String getFa5FontMapKey(String name) => name.split('_')[1].toLowerCase();

// FontAwesome5_Brands -> FontAwesome5Brands
String toClassName(String name) => name.replaceAll('_', '');

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
  final bashCommand = Platform.isWindows ? 'cmd' : '/bin/bash';
  final res = Process.runSync(bashCommand, ['-c', command], workingDirectory: workingDirectory);

  print(res.stdout);
  print(res.stderr);
}

generateFonts() {
  // lib/flutter_vector_icons.dart
  final sourceCode = StringBuffer('library flutter_vector_icons;');
  final valuesContent = StringBuffer();

  for (var fontName in [...fontNames, ...fa5FontNames]) sourceCode.write("export 'src/${toFileName(fontName)}.dart';");

  File(getAbsolutePath('lib/flutter_vector_icons.dart')).writeAsStringSync(dartFormatter.format(sourceCode.toString()));

  // lib/src/*.dart
  // fonts

  for (final fontName in fontNames) {
    final fileName = toFileName(fontName);
    final iconMap = json.decode(File(getAbsolutePath('vendor/react-native-vector-icons/glyphmaps/$fontName.json')).readAsStringSync()) as Map;

    sourceCode.clear();
    valuesContent.clear();
    sourceCode.write("import 'package:flutter/widgets.dart'; class $fontName {");
    valuesContent.write('static const values = {');

    for (var entry in iconMap.entries) {
      final identifier = normalizeKey(entry.key);
      final codePoint = entry.value;

      sourceCode.write('static const IconData $identifier = IconData($codePoint, fontFamily: "$fontName", fontPackage: "flutter_vector_icons");');
      valuesContent.write('"$identifier":$identifier,');
    }

    sourceCode.write(valuesContent);
    sourceCode.write('};}');

    File(getAbsolutePath('lib/src/$fileName.dart')).writeAsStringSync(dartFormatter.format(sourceCode.toString()));

    print('$fontName done');
  }

  // font awesome 5
  final fa5Meta = json.decode(File(getAbsolutePath('vendor/react-native-vector-icons/glyphmaps/FontAwesome5Free_meta.json')).readAsStringSync());
  final fa5GlyphMap = json.decode(File(getAbsolutePath('vendor/react-native-vector-icons/glyphmaps/FontAwesome5Free.json')).readAsStringSync());

  for (var fontName in fa5FontNames) {
    final fileName = toFileName(fontName);
    final className = toClassName(fontName);

    valuesContent.clear();
    sourceCode.clear();
    sourceCode.write("import 'package:flutter/widgets.dart'; class $className {");
    valuesContent.write('static const values = {');

    for (final key in fa5Meta[getFa5FontMapKey(fontName)]) {
      final identifier = normalizeKey(key);
      final codePoint = fa5GlyphMap[key];

      if (codePoint == null) throw 'codePoint null: $fontName, $key';

      sourceCode.write('static const IconData $identifier = IconData($codePoint, fontFamily: "$fontName", fontPackage: "flutter_vector_icons");');
      valuesContent.write('"$identifier":$identifier,');
    }

    sourceCode.write(valuesContent);
    sourceCode.write('};}');

    File(getAbsolutePath('lib/src/$fileName.dart')).writeAsStringSync(dartFormatter.format(sourceCode.toString()));

    print('$fontName done');
  }
}

generateWebData() {
  // data.dart
  final webData = {};

  for (final name in fontNames) {
    final glyphMap = json.decode(File(getAbsolutePath('vendor/react-native-vector-icons/glyphmaps/$name.json')).readAsStringSync()) as Map;
    final result = {};

    for (final e in glyphMap.entries) result[normalizeKey(e.key)] = e.value;

    webData[name] = result;
  }

  final fa5Meta = json.decode(File(getAbsolutePath('vendor/react-native-vector-icons/glyphmaps/FontAwesome5Free_meta.json')).readAsStringSync()) as Map;
  final fa5GlyphMap = json.decode(File(getAbsolutePath('vendor/react-native-vector-icons/glyphmaps/FontAwesome5Free.json')).readAsStringSync()) as Map;

  for (final name in fa5FontNames) {
    final result = {};

    for (final key in fa5Meta[getFa5FontMapKey(name)]) result[normalizeKey(key)] = fa5GlyphMap[key];

    webData[name] = result;
  }

  File(getAbsolutePath('example/lib/data.dart')).writeAsStringSync(dartFormatter.format('var data =${json.encode(webData)};'));

  // FontManifest.json
  final fontManifest = [...fontNames, ...fa5FontNames]
      .map((name) => {
            "family": name,
            "fonts": [
              {"asset": "fonts/$name.ttf"}
            ]
          })
      .toList();

  // pubspec.yaml
  final pubspecString = File(getAbsolutePath('pubspec.yaml')).readAsStringSync();
  final pubspecContent = StringBuffer(pubspecString.replaceFirst(RegExp('flutter:.*\r?\n.*fonts:(\r|\n|.)*'), ''));

  pubspecContent.writeln('flutter:');
  pubspecContent.writeln('  fonts:');

  for (final item in fontManifest) {
    final family = item['family'];
    final asset = (item['fonts'] as List)[0]['asset'];

    pubspecContent.writeln('    - family: $family');
    pubspecContent.writeln('      fonts:');
    pubspecContent.writeln('        - asset: $asset');
  }

  File(getAbsolutePath('pubspec.yaml')).writeAsStringSync(pubspecContent.toString());
}

void main() {
  final vendorDir = './vendor';

  // Copy fonts
  runCommand('cp ${path.join(vendorDir, 'react-native-vector-icons/Fonts/*')} ${path.join(root, 'fonts')}');

  generateFonts();
  generateWebData();
}
