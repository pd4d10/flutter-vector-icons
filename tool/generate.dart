import 'dart:io';
import 'dart:convert';
import 'package:dart_style/dart_style.dart';

var specialChars = ['new', 'sync', 'switch', 'try', 'null', 'class'];

String convert(String name, Map input) {
  var properties = input.entries.map((entry) {
    String key = entry.key.replaceAll('-', '_');
    if (specialChars.contains(key)) {
      key = key + '_icon';
    }

    if (key.startsWith(RegExp(r'\d'))) {
      key = 'icon_' + key;
    }

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

void main() {
  var names = [
    'AntDesign',
    'Entypo',
    'EvilIcons',
    'Feather',
    'FontAwesome',
    // 'FontAwesome5_Brands',
    // 'FontAwesome5_Regular',
    // 'FontAwesome5_Solid',
    'Foundation',
    'Ionicons',
    'MaterialCommunityIcons',
    // 'MaterialIcons',
    'Octicons',
    'SimpleLineIcons',
    'Zocial'
  ];

  names.forEach((name) {
    // glyphmaps are taken from:
    // https://github.com/oblador/react-native-vector-icons/tree/master/glyphmaps
    // need to manually copy these json files to ./glyphmaps dir
    // or change path below
    var content = File('./glyphmaps/$name.json').readAsStringSync();
    var input = json.decode(content);
    var result = convert(name, input);
    var fileName = toSnakeCase(name);

    File('./lib/$fileName.dart').writeAsStringSync(result);
    print('$fileName done');
  });

  // entry
  var exports = names.map((name) {
    var fileName = toSnakeCase(name);
    return "export '$fileName.dart';";
  }).join('\n');
  var result = '''library flutter_vector_icons;
$exports
''';
  File('./lib/flutter_vector_icons.dart')
      .writeAsStringSync(DartFormatter().format(result));
}
