import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/widgets/widgets/base_list.dart';
import 'package:sma/widgets/portfolio/widgets/heading/modify_portfolio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/portfolio/folders_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sma/helpers/import_helper.dart';

class FilePickerButton extends StatefulWidget {
  final int portfolioId;

  FilePickerButton ({@required this.portfolioId});

  _FilePickerButtonState createState() => new _FilePickerButtonState();
}

class _FilePickerButtonState extends State<FilePickerButton> {
  String _fileName;
  String _path;
  Map<String, String> _paths;
  bool _loadingPath = false;

  @override
  void initState() {
    super.initState();
  }

  void _openFile() async {
    final File file = await FilePicker.getFile();
    if (file != null) {
      var csvReader = ReadRobinhoodCSV (context: context, file: file, portfolioId: widget.portfolioId);
      csvReader.getAllTradesFromFile (file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RaisedButton(
              onPressed: () async => _openFile(),
              child: new Text("Import CSV"),
            ),
        Builder(
          builder: (BuildContext context) => _loadingPath
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: const CircularProgressIndicator())
              : _path != null || _paths != null
                  ? new Container(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      height: MediaQuery.of(context).size.height * 0.50,
                      child: new Scrollbar(
                          child: new ListView.separated(
                        itemCount: _paths != null && _paths.isNotEmpty
                            ? _paths.length
                            : 1,
                        itemBuilder: (BuildContext context, int index) {
                          final bool isMultiPath =
                              _paths != null && _paths.isNotEmpty;
                          final String name = 'File $index: ' +
                              (isMultiPath
                                  ? _paths.keys.toList()[index]
                                  : _fileName ?? '...');
                          final path = isMultiPath
                              ? _paths.values.toList()[index].toString()
                              : _path;

                          return new ListTile(
                            title: new Text(
                              name,
                            ),
                            subtitle: new Text(path),
                          );
                        },
                        separatorBuilder:
                            (BuildContext context, int index) =>
                                new Divider(),
                      )),
                    )
                  : new Container()
        )
      ],
    );
  }
}

class ModifyPortfolioFolderSection extends StatefulWidget {
  final String _prefix;
  final PortfolioFolderModel _data;
  ModifyPortfolioFolderSection (this._prefix, this._data);

  @override
  _State createState() => _State();
}

class _State extends State<ModifyPortfolioFolderSection> {
  String _name;
  bool _exclude;
  bool _hideClosedPositions;

  @override
  void initState () {
    super.initState();
    _name = widget._data.name;
    _exclude = widget._data.exclude;
    _hideClosedPositions = widget._data.hideClosedPositions;
  }

  void onPressedHandler(context)
  {
      BlocProvider
      .of<PortfolioFoldersBloc>(context)
      .add(SaveFolder(model: PortfolioFolderModel(key: widget._data.key, name: _name, exclude: _exclude, hideClosedPositions: _hideClosedPositions, order: widget._data.order, daily: widget._data.daily, overall: widget._data.overall)));
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
            setState(() {
              _name = value;
            });
          }),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Exclude from Total:"),
            Switch.adaptive(value: _exclude,
              onChanged: (bool value) {
               setState(() {
                 _exclude = value;
                });
            }),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Hide Closed Positions:"),
            Switch.adaptive(value: _hideClosedPositions,
              onChanged: (bool value) {
               setState(() {
                 _hideClosedPositions = value;
                });
            }),
          ],
        ),
        widget._data.key != -1 ? FilePickerButton(portfolioId: widget._data.key) : Container (), // TODO - only allow import on edit?
      ]
    );
  }
}