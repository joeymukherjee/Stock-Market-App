import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';
import 'package:sma/widgets/portfolio/widgets/heading/portfolio_heading.dart';
import 'package:sma/widgets/portfolio/widgets/content/portfolio_folder_section.dart';

class PortfolioFolder extends StatelessWidget {
  final int portfolioId;
  final String portfolioName;

  PortfolioFolder ({@required this.portfolioName, @required this.portfolioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
        child: SafeArea(
          child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              PortfolioHeadingSection(portfolioName: portfolioName, portfolioId: portfolioId),
              PortfolioFolderSection(portfolioName: portfolioName, portfolioId: portfolioId)
            ]
          )
        ),

        onRefresh: () async {  // Reload folders section.
          BlocProvider
            .of<TradesBloc>(context)
            .add(PickedPortfolio(portfolioId));
        },
      ),
    );
  }
}