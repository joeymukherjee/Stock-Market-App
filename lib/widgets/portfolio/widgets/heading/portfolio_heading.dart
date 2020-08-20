import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/portfolio/folder_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PortfolioHeadingSection extends StatelessWidget {

  static const kPortfolioHeaderTitle = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold
  );

  void reload (context) {
    BlocProvider
        .of<PortfolioFolderBloc>(context)
        .add(FetchPortfolioFolderData());
  } // TODO - figure out how to reload this folders list

  void toggleEditing (BuildContext context, PortfolioFolderState state) {
    if (state is PortfolioFolderLoadedEditingState) {
      BlocProvider
        .of<PortfolioFolderBloc>(context)
        .add(FetchPortfolioFolderData());
    } else {
      BlocProvider
        .of<PortfolioFolderBloc>(context)
        .add(PortfolioFolderEditingEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioFolderBloc, PortfolioFolderState> (
      builder: (BuildContext context, PortfolioFolderState state) {
        bool _isEditing = (state is PortfolioFolderLoadedEditingState);
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