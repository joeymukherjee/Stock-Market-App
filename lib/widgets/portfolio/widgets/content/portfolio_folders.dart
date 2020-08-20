import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/widgets/widgets/empty_screen.dart';
import 'package:sma/widgets/widgets/loading_indicator.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/bloc/portfolio/folders_bloc.dart';
import 'package:sma/widgets/portfolio/widgets/content/portfolio_folder_card.dart';

class PortfolioFoldersSection extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioFoldersBloc, PortfolioFoldersState>(
      builder: (BuildContext context, PortfolioFoldersState state) {
        if (state is PortfolioFoldersInitial) {
          BlocProvider
          .of<PortfolioFoldersBloc>(context)
          .add(FetchPortfolioFoldersData());
        }

        if (state is PortfolioFoldersError) {
          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            child: EmptyScreen(message: state.message),
          );
        }

        if (state is PortfolioFoldersEmpty) {
          return Column(
            children: <Widget>[              
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 10,
                  horizontal: 4
                ),
                child: EmptyScreen(message: 'Looks like you don\'t have any saved portfolios.  Add one by clicking the "Add" icon above!'),
              ),
            ],
          );
        }

        if (state is PortfolioFoldersLoaded) {
          return Column(
            children: <Widget>[
              _buildFoldersSection(folders: state.folders)              
            ],
          );
        }

        if (state is PortfolioFoldersLoadedEditingState) {
          return Column(
            children: <Widget>[
              _buildFoldersSection(folders: state.folders)
            ],
          );
        }

        return Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height),
          child: LoadingIndicatorWidget(),
        );
      },
    );
  }
  
  Widget _buildFoldersSection({List<PortfolioFolderModel> folders}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: folders.length,
      itemBuilder: (BuildContext context, int index) {
        return PortfolioFolderCard(data: folders[index]);
      }
    );
  }
}