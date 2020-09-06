import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/models/trade/trade_group.dart';
import 'package:sma/widgets/widgets/loading_indicator.dart';
import 'package:sma/widgets/widgets/empty_screen.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';
import 'package:sma/widgets/portfolio/widgets/content/porfolio_folder_stocks_card.dart';

class PortfolioFolderSection extends StatelessWidget {
  final String portfolioId;
  final String portfolioName;

  PortfolioFolderSection ({@required this.portfolioName, @required this.portfolioId});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradesBloc, TradesState>(
      builder: (BuildContext context, TradesState state) {
        if (state is TradesSavedOkay) {
          BlocProvider
            .of<TradesBloc>(context)
            .add(PickedPortfolio(portfolioId));
        }
        if (state is TradesEmpty) {
          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 10,
                  horizontal: 4
                ),
                child: EmptyScreen(message: 'Looks like you don\'t have any transactions on $portfolioName.  Add one by clicking the "Add" icon above!'),
              ),
            ],
          );
        }
        if (state is TradesFailure) {
          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            child: EmptyScreen(message: state.message),
          );
        }
        if (state is TradeGroupsLoadedEditing) {
          return Expanded(
            child: _buildFolderSection(tradeGroups: state.tradeGroups)
          );
        }
        if (state is TradeGroupsLoadSuccess) {
          return Expanded(
            child: _buildFolderSection(tradeGroups: state.tradeGroups)
          );
        }
        return Expanded(
          child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: LoadingIndicatorWidget(),
            ),
        );
      }
    );
  }

  Widget _buildFolderSection({List<TradeGroup> tradeGroups}) {
    return ListView.builder(
      key: const PageStorageKey("stocks"),  // allows folder to remember position!
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: tradeGroups.length,
      itemBuilder: (BuildContext context, int index) {
        return PortfolioFolderStocksCard (tradeGroup: tradeGroups[index]);
      }
    );
  }
}