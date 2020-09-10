import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/models/trade/trade_group.dart';
import 'package:sma/widgets/widgets/base_list.dart';
import 'package:sma/widgets/portfolio/widgets/heading/modify_portfolio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/portfolio/folders_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sma/helpers/import_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FilePickerButton extends StatefulWidget {
  final String portfolioId;

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
  _ModifyPortfolioFolderSectionState createState() => _ModifyPortfolioFolderSectionState();
}

class _ModifyPortfolioFolderSectionState extends State<ModifyPortfolioFolderSection> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  bool _exclude;
  bool _hideClosedPositions;
  SortOptions _sortOption;

  @override
  void initState () {
    super.initState();
    _name = widget._data.name;
    _exclude = widget._data.exclude;
    _hideClosedPositions = widget._data.hideClosedPositions;
    _sortOption = widget._data.defaultSortOption;
  }

  void onPressedHandler(context) {
    BlocProvider
      .of<PortfolioFoldersBloc>(context)
      .add(SaveFolder(
        model: PortfolioFolderModel(
        id: widget._data.id,
        userId: FirebaseAuth.instance.currentUser.uid,
        name: _name,
        exclude: _exclude,
        hideClosedPositions: _hideClosedPositions,
        defaultSortOption: _sortOption,
        order: widget._data.order,
        daily: widget._data.daily,
        overall: widget._data.overall)
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioFoldersBloc, PortfolioFoldersState> (
      builder: (BuildContext context, PortfolioFoldersState state) {
        if (state is PortfolioFolderValidate) {
            onPressedHandler (context);
        }
        return Form(
          key: _formKey,
          child: BaseList(
            children: [
              ModifyPortfolioHeadingSection(widget._prefix), //, onPressedHandler),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text ("Sort By:"),
                  DropdownButton (
                    value: _sortOption,
                    items: [
                      DropdownMenuItem (value: SortOptions.order, child: Text ('Order')),
                      DropdownMenuItem (value: SortOptions.ticker, child: Text ('Symbol')),
                      DropdownMenuItem (value: SortOptions.equity, child: Text ('Equity')),
                      DropdownMenuItem (value: SortOptions.dailyChange, child: Text ('Daily Change')),
                      DropdownMenuItem (value: SortOptions.dailyChangePercentage, child: Text ('Daily Change %')),
                      DropdownMenuItem (value: SortOptions.overallChange, child: Text ('Overall Change')),
                      DropdownMenuItem (value: SortOptions.overallChangePercentage, child: Text ('Overall Change %'))
                    ],
                    onChanged: (SortOptions newValue) {
                      setState (() {
                        _sortOption = newValue;
                      });
                    },
                  )
                ],
              ),
              FilePickerButton(portfolioId: widget._data.id)
            ]
          ),
        );
      }
    );
  }
}