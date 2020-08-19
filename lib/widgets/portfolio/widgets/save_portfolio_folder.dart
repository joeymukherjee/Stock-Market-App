import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/portfolio/folder_bloc.dart';
import 'package:sma/models/storage/portfolio_folder_storage.dart';

class SavePortfolioWidget extends StatefulWidget {

  final String name;
  final bool exclude;
  final PortfolioFolderStorageModel storageModel;

  SavePortfolioWidget({
    @required this.name,
    @required this.exclude,
    @required this.storageModel
  });

  @override
  _SavePortfolioWidgetState createState() => _SavePortfolioWidgetState();
}

class _SavePortfolioWidgetState extends State<SavePortfolioWidget> {

  bool exclude;
  String name;
  
  @override
  void initState() {
    this.exclude = this.widget.exclude;
    this.name = this.name; 
    super.initState();
  }

  @override
  void dispose() {
    this.exclude = null;
    this.name = null;

    super.dispose();
  }

  void changeState({bool exclude, String name}) {
    setState(() {
      this.exclude = exclude;
      this.name = name;
    });
  }

  void onPressedHandler() {

print (name);
print (this.widget.name);
      changeState(name: this.widget.name, exclude: this.widget.exclude);

      BlocProvider
      .of<PortfolioFolderBloc>(context)
      .add(SaveFolder(storageModel: this.widget.storageModel));
      Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      icon: Icon(Icons.done), 
      onPressed: () => onPressedHandler()
    );
  }
}