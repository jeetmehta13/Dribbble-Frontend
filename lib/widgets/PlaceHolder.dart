import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PlaceHolder extends StatelessWidget {
  final String message;
  PlaceHolder(this.message);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 150.0),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Image(
                image: AssetImage('lib/assets/dribbble-logo.png'),
                height: 120,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.black, fontSize: 20.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}