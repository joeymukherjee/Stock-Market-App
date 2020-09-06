import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/portfolio/folders_bloc.dart';

class SavePortfolioWidget extends StatelessWidget {
  SavePortfolioWidget();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PortfolioFoldersBloc, PortfolioFoldersState> (
      listener: (context, state) {
        if (state is PortfolioFolderSavedOkay) {
          Navigator.pop(context);
        }
      },
      child: IconButton(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        icon: Icon(Icons.done),
        onPressed: () => { BlocProvider.of<PortfolioFoldersBloc>(context).add(FinishedFolderEditing()) }
      )
    );
  }
}