import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/watchlist/watchlist_bloc.dart';

import 'package:sma/models/data_overview.dart';
import 'package:sma/models/profile/market_index.dart';

import 'package:sma/widgets/watchlist/widgets/content/watchlist_index.dart';
import 'package:sma/widgets/watchlist/widgets/content/watchlist_stonk.dart';

import 'package:sma/widgets/widgets/empty_screen.dart';
import 'package:sma/widgets/widgets/loading_indicator.dart';

class WatchlistStonksSection extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (BuildContext context, WatchlistState state) {

        if (state is WatchlistInitial) {
          BlocProvider
          .of<WatchlistBloc>(context)
          .add(FetchWatchlistData());
        }

        if (state is WatchlistError) {
          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            child: EmptyScreen(message: state.message),
          );
        }

        if (state is WatchlistStockEmpty) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildIndexesSection(context, indexes: state.indexes),
              ),
              
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 10,
                  horizontal: 4
                ),
                child: EmptyScreen(message: 'Looks like you don\'t have any holdings in your watchlist.'),
              ),
            ],
          );
        }

        if (state is WatchlistLoaded) {
          return Column(
            children: <Widget>[
              _buildIndexesSection(context, indexes: state.indexes),
              _buildStocksSection(stocks: state.stocks)              
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

  Widget _buildIndexesSection(BuildContext context, {List<MarketIndexModel> indexes}) {
    return Container(
      constraints: BoxConstraints.expand(
        height:MediaQuery.textScaleFactorOf(context) * Theme.of(context).textTheme.bodyText1.fontSize * 6 + 10
      ),
      margin: EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        scrollDirection: Axis.horizontal,
        itemCount: indexes.length,
        itemBuilder: (BuildContext context, int index) {
          return WatchlistIndexWidget(index: indexes[index]);
        }
      ),
    );
  }
  
  Widget _buildStocksSection({List<StockOverviewModel> stocks}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: stocks.length,
      itemBuilder: (BuildContext context, int index) {
        return WatchlistStockCard(data: stocks[index]);
      }
    );
  }
}
