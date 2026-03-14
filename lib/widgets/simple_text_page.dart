import 'package:flutter/material.dart';

class SimpleTextPage extends StatelessWidget {
  final String text;

  const SimpleTextPage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text));
  }
}
