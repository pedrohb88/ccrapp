import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final bool fullScreen;

  Loader({this.fullScreen = false}) : assert(fullScreen != null);

  @override
  Widget build(BuildContext context) {
    if (fullScreen) {

      return AbsorbPointer(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withAlpha(100),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    } else {

      return CircularProgressIndicator();
    }
  }
}
