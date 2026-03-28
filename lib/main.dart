import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_processor/provider.dart';
import './widget/display.dart';
import './widget/sidebar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ImportedImage(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(children: [Sidebar(), DisplayImg()]),
          ),
        ),
      ),
    );
  }
}
