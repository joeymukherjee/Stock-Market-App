import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/portfolio/folders_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PortfolioHeadingSection extends StatelessWidget {

  static const kPortfolioHeaderTitle = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold
  );

  void reload (context) {
    BlocProvider
        .of<PortfolioFoldersBloc>(context)
        .add(FetchPortfolioFoldersData());
  } // TODO - figure out how to reload this folders list

  void toggleEditing (BuildContext context, PortfolioFoldersState state) {
    if (state is PortfolioFoldersLoadedEditingState) {
      BlocProvider
        .of<PortfolioFoldersBloc>(context)
        .add(FetchPortfolioFoldersData());
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
                    child: _isEditing ? Icon(FontAwesomeIcons.plus) : Icon(FontAwesomeIcons.sync),
                    onTap: () => _isEditing ? Navigator.pushNamed(context, '/add_portfolio_folder') : reload(context)
                  ),
                  Expanded(child: Text('Portfolios', style: PortfolioHeadingSection.kPortfolioHeaderTitle, textAlign: TextAlign.center)),
                  GestureDetector(
                    child: _isEditing ? Icon(Icons.done) : Icon(FontAwesomeIcons.edit),
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