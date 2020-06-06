import 'package:Flutter_Chat_Application/home.dart';
import 'package:flutter/material.dart';

import 'const.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Demo',
      theme: ThemeData(
        primaryColor: themeColor,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,

    );
  }
}
