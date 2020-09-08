import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/widgets/portfolio/widgets/heading/portfolio_heading.dart';
import 'package:sma/widgets/portfolio/widgets/content/portfolio_folder_section.dart';

class PortfolioFolder extends StatelessWidget {
  final PortfolioFolderModel folder;
   PortfolioFolder ({@required this.folder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column (
              children: [
                PortfolioHeadingSection(folder: folder),
                PortfolioFolderSection(folder: folder)
              ]
            ),
          )
        ),

        onRefresh: () async {  // Reload folders section.
          BlocProvider
            .of<TradesBloc>(context)
            .add(PickedPortfolio(folder.id));
        },
      ),
    );
  }
}