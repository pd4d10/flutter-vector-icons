# flutter_vector_icons

[![pub](https://img.shields.io/pub/v/flutter_vector_icons.svg)](https://pub.dev/packages/flutter_vector_icons)
[![gallery](https://github.com/pd4d10/flutter-vector-icons/workflows/gallery/badge.svg)](https://pd4d10.github.io/flutter-vector-icons/)

Customizable Icons for Flutter. Port of [react-native-vector-icons](https://github.com/oblador/react-native-vector-icons).

Preview icons with the gallery: https://pd4d10.github.io/flutter-vector-icons/

## Installation

Add `flutter_vector_icons` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages)

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return IconButton(
      // Variable name is the same as font name:
      //
      // AntDesign
      // Entypo
      // EvilIcons
      // Feather
      // FontAwesome
      // Foundation
      // Ionicons
      // MaterialCommunityIcons
      // MaterialIcons
      // Octicons
      // SimpleLineIcons
      // Zocial
      // FontAwesome5Brands
      // FontAwesome5Regular
      // FontAwesome5Solid

      icon: Icon(MaterialCommunityIcons.star),
      onPressed: () {
        print('Star it');
      },
    );
  }
}
```

## Version Correspondence

| flutter-vector-icons | react-native-vector-icons |
| -------------------- | ------------------------- |
| 2.x                  | 9.x                       |
| 1.x                  | 8.x                       |

8.x

## Development

```sh
cd tool
npm install
node index.js
```

## Credits

- [react-native-vector-icons](https://github.com/oblador/react-native-vector-icons)

## License

MIT
