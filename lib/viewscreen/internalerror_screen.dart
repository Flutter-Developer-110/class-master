import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InternalErrorScreen extends StatelessWidget {
  static const routeName ='/internalErrorScreen';

  late final String message;

  InternalErrorScreen(this.message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Internal Errot'),
      ),
      body: Text(
        'Internal Error has occured\n Re-launch the app\n$message',
        style: TextStyle(
          fontSize:18.0,
          color: Colors.red,
        ),
      ),
    );
  }
}
