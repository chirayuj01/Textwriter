import 'package:flutter/material.dart';
import 'texteditor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TextEditorPage(),
    );
  }
}
