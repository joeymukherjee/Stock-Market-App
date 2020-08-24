import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/models/trade/trade.dart';
import 'package:sma/widgets/widgets/loading_indicator.dart';
import 'package:sma/widgets/widgets/empty_screen.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';

class PortfolioFolderSection extends StatelessWidget {
  final int portfolioId;
  final String portfolioName;

  PortfolioFolderSection ({@required this.portfolioName, @required this.portfolioId});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradesBloc, TradesState>(
      builder: (BuildContext context, TradesState state) {
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
        if (state is TradesLoadFailure) {
          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            child: EmptyScreen(message: state.message),
          );
        }
        if (state is TradesLoadSuccess) {
          return Column(
            children: <Widget>[
              _buildFolderSection(trades: state.trades)              
            ],
          );
        }
        return Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height),
          child: LoadingIndicatorWidget(),
        );
      }
    );
  }

  Widget _buildFolderSection({List<Trade> trades}) {
    print ("building folders");
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: trades.length,
      itemBuilder: (BuildContext context, int index) {
        // TODO - create portfolio stocks cards
        print (trades[index]);
        return Container (); // TradeCard(data: trades[index]);
      }
    );
  }
}