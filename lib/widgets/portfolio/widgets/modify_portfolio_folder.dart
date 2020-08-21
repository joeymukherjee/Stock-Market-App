
import 'package:flutter/material.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/widgets/widgets/base_list.dart';
import 'package:sma/widgets/portfolio/widgets/heading/modify_portfolio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/portfolio/folders_bloc.dart';
import 'package:sma/models/storage/portfolio_folders_storage.dart';

class ModifyPortfolioFolderSection extends StatefulWidget {
  final String _prefix;
  final PortfolioFolderModel _data;
  ModifyPortfolioFolderSection (this._prefix, this._data);

  @override
  _State createState() => _State();
}

class _State extends State<ModifyPortfolioFolderSection> {
  final int _order = 0;
  String _name = '';
  bool _exclude = false;

  void onPressedHandler(context)
  {
    print ("onPressed");
    print (_name);
      BlocProvider
      .of<PortfolioFoldersBloc>(context)
      .add(SaveFolder(storageModel: PortfolioFoldersStorageModel(name: _name, exclude: _exclude, order: _order)));
      Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return BaseList(
      children: [
        ModifyPortfolioHeadingSection(widget._prefix, onPressedHandler),
        TextFormField(
          initialValue: widget._data.name,
          decoration: InputDecoration (hintText: 'portfolio name', labelText: "Name *"),
          showCursor: true,
          onChanged: (String value) async {
            print (value);
            setState(() {
            _name = value;
            });
            print (_name);
          }),
        Row(
          children: [
            Text("Exclude from Total:"),
            Switch(value: widget._data.exclude, onChanged: (bool value) {
               setState(() {
                 _exclude = value;
                });
            }),
          ],
        ),
      ]
    );
  }
}