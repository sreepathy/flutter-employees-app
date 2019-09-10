import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      child: Center(
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(10),
          color: Colors.white70,
          child: Container(
            height: 70,
            width: 70,
            padding: EdgeInsets.all(17),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
