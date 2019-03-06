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
      // Octicons
      // SimpleLineIcons
      // Zocial

      icon: Icon(MaterialCommunityIcons.star),
      onPressed: () {
        print('Star it');
      },
    );
  }
}
