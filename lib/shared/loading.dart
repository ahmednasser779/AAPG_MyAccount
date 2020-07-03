import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red[50],
      child: Center(
        child: SpinKitChasingDots(
          color: Color(0xFF8B1122),
          size: 50,
        ),
      ),
    );
  }
}
