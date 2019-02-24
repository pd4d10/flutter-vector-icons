# flutter_vector_icons

[![pub](https://img.shields.io/pub/v/flutter_vector_icons.svg)](https://pub.dartlang.org/packages/flutter_vector_icons)

Flutter version of [react-native-vector-icons](https://github.com/oblador/react-native-vector-icons)

## Bundled Icon Sets

[Browse all](https://oblador.github.io/react-native-vector-icons/).

* [`AntDesign`](https://ant.design/) by AntFinance (**297** icons)
* [`Entypo`](http://entypo.com) by Daniel Bruce (**411** icons) 
* [`EvilIcons`](http://evil-icons.io) by Alexander Madyankin & Roman Shamin (v1.10.1, **70** icons) 
* [`Feather`](http://feathericons.com) by Cole Bemis & Contributors (v4.7.0, **266** icons) 
* [`FontAwesome`](http://fortawesome.github.io/Font-Awesome/icons/) by Dave Gandy (v4.7.0, **675** icons)
* [`Foundation`](http://zurb.com/playground/foundation-icon-fonts-3) by ZURB, Inc. (v3.0, **283** icons)
* [`Ionicons`](https://ionicons.com/) by Ben Sperry (v4.2.4, **696** icons)
- [`MaterialCommunityIcons`](https://materialdesignicons.com/) by MaterialDesignIcons.com (v3.4.93, **3494** icons)
- [`Octicons`](http://octicons.github.com) by Github, Inc. (v8.4.1, **184** icons)
* [`Zocial`](http://zocial.smcllns.com/) by Sam Collins (v1.0, **100** icons)
* [`SimpleLineIcons`](https://simplelineicons.github.io/) by Sabbir & Contributors (v2.4.1, **189** icons)

## Installation

Add `flutter_vector_icons` as a dependency in your pubspec.yaml file.

## Usage

```dart
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return IconButton(
      ///
      /// Variable name is the same as font name
      ///
      icon: Icon(MaterialCommunityIcons.star),

      onPressed: () {
        print('Star it');
      }
     );
  }
}
```

## Development

1. Copy [font files](https://github.com/oblador/react-native-vector-icons/tree/master/Fonts) to `fonts` directory
2. Copy [glyphmaps json files](https://github.com/oblador/react-native-vector-icons/tree/master/glyphmaps) to `glyphmaps` directory
3. run `dart tool/generate.dart`

## License

MIT
