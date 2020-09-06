import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/models/trade/trade_group.dart';

import 'package:sma/shared/styles.dart';
import 'package:sma/helpers/text/text_helper.dart';
import 'package:sma/helpers/color/color_helper.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';
import 'package:sma/widgets/portfolio/trades_group.dart';

class StocksBox extends StatelessWidget {
  final TradeGroup tradeGroup;
  StocksBox ({@required this.tradeGroup});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(flex: 5, child: _buildCompanyData(context)),
        Expanded(flex: 8, child: _buildEquityData()),
        Expanded(flex: 8, child: _buildPriceData())
      ],
    );
  }
  /// This method is in charge of rendering the stock company data.
  /// This is the left side in the card.
  /// It renders the [ticker] and the company [name] from [tradeGroup].
  Widget _buildCompanyData(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(tradeGroup.ticker, style: kStockTickerSymbol),
        SizedBox(height: 4.0),
        Text(tradeGroup.companyName, style: Theme.of(context).textTheme.bodyText2)
      ],
    );
  }

/// This method is in charge of rendering the equity/number of shares.
  /// This is the middle of the card.
  /// It renders the [change] and the stock's [price] from [tradeGroup].
  Widget _buildEquityData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Container(
            child: Text(
              tradeGroup.totalNumberOfShares.toString() + ' shares',
              style: TextStyle (fontSize: 12),
              overflow: TextOverflow.visible,
              textAlign: TextAlign.end
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
           child: Text(formatCurrencyText (tradeGroup.totalEquity + tradeGroup.overall.change),
            overflow: TextOverflow.visible,
            textAlign: TextAlign.end,
            style: TextStyle (fontSize: 12)
          ),
        ),
      ],
    );
  }

  /// This method is in charge of rendering the stock company data.
  /// This is the right side in the card.
  /// It renders the [change] and the stock's [price] from [tradeGroup].
  Widget _buildPriceData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Container(
            child: Text(
              determineTextPercentageBasedOnChange(tradeGroup.overall.changePercentage),
              style: determineTextStyleBasedOnChange(tradeGroup.overall.changePercentage),
              overflow: TextOverflow.visible,
              textAlign: TextAlign.end
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
           child: Text(determineTextBasedOnChange(tradeGroup.overall.change),
            overflow: TextOverflow.visible,
            textAlign: TextAlign.end,
            style: determineTextStyleBasedOnChange(tradeGroup.overall.change)
          ),
        ),
      ],
    );
  }
}

class PortfolioFolderStocksCard extends StatelessWidget {
  final TradeGroup tradeGroup;
  PortfolioFolderStocksCard ({@required this.tradeGroup});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradesBloc, TradesState> (
      builder: (BuildContext context, TradesState state) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: MaterialButton(
            color: Theme.of (context).accentColor,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(flex: 8, child: _buildTradeGroupData()),
                ],
              ),
            ),

            shape: RoundedRectangleBorder(borderRadius: kStandardBorder),
            onPressed: () async {
              BlocProvider
                .of<TradesBloc>(context)
                .add(SelectedTrades(portfolioId: tradeGroup.portfolioId, ticker: tradeGroup.ticker));
              await Navigator.push(context, MaterialPageRoute(builder: (_) => TradeGroupFolder(tradeGroup: tradeGroup)));
            },
          ),
        );
      }
    );
  }

  Widget _buildTradeGroupData() {
    return BlocBuilder<TradesBloc, TradesState> (
      builder: (BuildContext context, TradesState state) {
        if (state is TradeGroupsLoadedEditing) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                child: Icon(Icons.highlight_off, color: Colors.red),
                onTap: () {
                  Alert(
                    context: context,
                    type: AlertType.warning,
                    title: "Delete Portfolio",
                    desc: "Are you sure you wish to delete all the transactions for ${tradeGroup.ticker} in ${tradeGroup.portfolioName}?",
                    buttons: [
                      DialogButton(
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          BlocProvider.of<TradesBloc>(context).add(DeletedTradeGroup(ticker: tradeGroup.ticker, portfolioId: tradeGroup.portfolioId));
                          Navigator.pop(context);
                        },
                        color: Colors.red,
                      ),
                      DialogButton(
                        child: Text(
                          "No",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.green
                      ),
                    ],
                  ).show();
                },
              ),
              Text(tradeGroup.ticker, style: Theme.of(context).textTheme.bodyText2),
              Icon(Icons.menu) // TODO - figure out how to move rows in a list
            ],
          );
        } else {
          return StocksBox (tradeGroup: tradeGroup);
        }
      }
    );
  }
}