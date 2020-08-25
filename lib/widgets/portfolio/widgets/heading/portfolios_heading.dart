import 'package:flutter/material.dart';
import 'package:sma/shared/styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/portfolio/folders_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/widgets/portfolio/widgets/modify_portfolio_folder.dart';

class PortfoliosHeadingSection extends StatelessWidget {

  void reload (context) {
    BlocProvider
        .of<PortfolioFoldersBloc>(context)
        .add(FetchPortfolioFoldersData());
  }

  void toggleEditing (BuildContext context, PortfolioFoldersState state) {
    if (state is PortfolioFoldersLoadedEditingState) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ModifyPortfolioFolderSection ('Add', PortfolioFolderModel(key: -1, exclude: false, name: '', order: 0))));
    } else {
      BlocProvider
        .of<PortfolioFoldersBloc>(context)
        .add(PortfolioFoldersEditingEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioFoldersBloc, PortfolioFoldersState> (
      builder: (BuildContext context, PortfolioFoldersState state) {
        bool _isEditing = (state is PortfolioFoldersLoadedEditingState) || (state is PortfolioFoldersEmpty);
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: _isEditing ? Icon(Icons.done) : Icon(FontAwesomeIcons.sync),
                    onTap: () => _isEditing ? BlocProvider.of<PortfolioFoldersBloc>(context).add(FetchPortfolioFoldersData()) : reload(context)
                  ),
                  Expanded(child: Text('Portfolios', style: kPortfolioHeaderTitle, textAlign: TextAlign.center)),
                  GestureDetector(
                    child: _isEditing ? Icon(FontAwesomeIcons.plus) : Icon(FontAwesomeIcons.edit),
                    onTap: () => toggleEditing(context, state)
                  ),
                ],
              ),
            ],
          )
        );
      }
    );
  }
}