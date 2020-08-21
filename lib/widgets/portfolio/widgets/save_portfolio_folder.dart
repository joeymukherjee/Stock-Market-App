import 'package:flutter/material.dart';

class SavePortfolioWidget extends StatelessWidget {
  final Function (BuildContext) _callback;
  SavePortfolioWidget(this._callback);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      icon: Icon(Icons.done), 
      onPressed: () => _callback(context)
    );
  }
}