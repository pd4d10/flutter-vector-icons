# flutter_vector_icons

[![pub](https://img.shields.io/pub/v/flutter_vector_icons.svg)](https://pub.dartlang.org/packages/flutter_vector_icons)

Flutter version of [react-native-vector-icons](https://github.com/oblador/react-native-vector-icons)

[Browse all bundled icon sets](https://oblador.github.io/react-native-vector-icons/)

## Installation

Add `flutter_vector_icons` as a dependency in your pubspec.yaml file.

## Usage

```dart
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return IconButton(
      // Variable name is the same as font name
      icon: Icon(MaterialCommunityIcons.star),
      onPressed: () {
        print('Star it');
      }
     );
  }
}
```

## Development

1. Copy glyphmaps json files to `glyphmaps` dir
2. run `dart tool/generate.dart`

## License

MIT
