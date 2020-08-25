import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/models/trade/trade_group.dart';
import 'package:sma/shared/colors.dart';
import 'package:sma/shared/styles.dart';
import 'package:sma/helpers/text/text_helper.dart';
import 'package:sma/helpers/color/color_helper.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sma/widgets/widgets/loading_indicator.dart';
import 'package:sma/widgets/widgets/empty_screen.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';

class StocksBox extends StatelessWidget {
  final TradeGroup tradeGroup;
  StocksBox ({@required this.tradeGroup});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(flex: 8, child: _buildCompanyData()),
        Expanded(flex: 8, child: _buildPriceData())
      ],
    );
  }
  /// This method is in charge of rendering the stock company data.
  /// This is the left side in the card.
  /// It renders the [ticker] and the company [name] from [tradeGroup].
  Widget _buildCompanyData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(tradeGroup.ticker, style: kStockTickerSymbol),
        SizedBox(height: 4.0),
        Text(tradeGroup.companyName, style: kCompanyNameStyle)
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
            width: tradeGroup.changePercentage > 99.99 ? null : 100.0,
            child: Text(
              determineTextPercentageBasedOnChange(tradeGroup.changePercentage),
              style: determineTextStyleBasedOnChange(tradeGroup.changePercentage),
              textAlign: TextAlign.end
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(determineTextBasedOnChange(tradeGroup.totalReturn),
            overflow: TextOverflow.visible,
            textAlign: TextAlign.end,
            style: determineTextStyleBasedOnChange(tradeGroup.totalReturn)
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
            color: kTileColor,
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

            shape: RoundedRectangleBorder(borderRadius: kStandatBorder),
            onPressed: () {

              // Trigger fetch event.
              if (state is TradesEditing) {
              //  Navigator.push(context, MaterialPageRoute(builder: (_) => ModifyTradesSection ('Edit', TradesGroup())));
              } else {
                /*
                BlocProvider
                  .of<TradesBloc>(context)
                  .add(PickedTradeGroup(tradeGroup.key));
                Navigator.push(context, MaterialPageRoute(builder: (_) => TradesGroup()));
                */
              }
            },
          ),
        );
      }
    );
  }

  Widget _buildTradeGroupData() {
    return BlocBuilder<TradesBloc, TradesState> (
      builder: (BuildContext context, TradesState state) {
        if (state is TradeGroupLoadedEditing) {
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
              Text(tradeGroup.ticker, style: kFolderNameStyle),
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