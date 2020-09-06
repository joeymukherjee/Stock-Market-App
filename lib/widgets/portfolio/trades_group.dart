import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sma/shared/styles.dart';
import 'package:sma/helpers/text/text_helper.dart';
import 'package:sma/models/trade/trade.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';
import 'package:sma/models/trade/trade_group.dart';
import 'package:sma/widgets/widgets/loading_indicator.dart';
import 'package:sma/widgets/widgets/empty_screen.dart';
import 'package:sma/widgets/portfolio/transaction.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TradeCard extends StatelessWidget {
  final Trade trade;
  final String portfolioName;

  TradeCard ({@required this.portfolioName, @required this.trade});

  void clickedEdit(BuildContext context, TradesState state) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditTransaction(portfolioName: portfolioName, portfolioId: trade.portfolioId, trade: trade)));
    if (state is TradesSavedOkay) {
      BlocProvider.of<TradesBloc>(context).add(EditedTrades (portfolioId: trade.portfolioId, ticker: trade.ticker));
    }
  }

  String formatSplitString (Split split) {
    String fromShare = split.sharesFrom == 1.0 ? "share" : "shares";
    String toShare = split.sharesTo == 1.0 ? "share" : "shares";
    num numFrom = split.sharesFrom == split.sharesFrom.round() ? split.sharesFrom.round() : split.sharesFrom;
    num numTo = split.sharesTo == split.sharesTo.round() ? split.sharesTo.round() : split.sharesTo;
    return "Split $numFrom $fromShare to $numTo $toShare";
  }

  String formatDividendString (Dividend dividend) {
    String amount = formatCurrencyText(dividend.getTotalReturn());
    return "Received \$$amount as dividend";
  }

  String formatBuySell (Common common) {
    String amount = formatCurrencyText(common.getTotalReturn());
    num numShares = common.sharesTransacted == common.sharesTransacted.round() ? common.sharesTransacted.round() : common.sharesTransacted;
    if (common.type == TransactionType.sell) {
      return "Sold $numShares shares for \$$amount";
    } else {
      return "Bought $numShares shares for \$$amount";
    }
  }

  Text formatSubtitle (Trade trade) {
    String subtitle;
    if (trade.type == TransactionType.split) {
      subtitle = formatSplitString(trade);
    } else if (trade.type == TransactionType.dividend) {
      subtitle = formatDividendString(trade);
    } else {
      subtitle = formatBuySell(trade);
    }
    TextStyle style = TextStyle (fontWeight: FontWeight.w500, fontSize: 10);
    return Text (subtitle, style: style);
  }

  Icon formatIcon (Trade trade) {
    IconData icon;
    if (trade.type == TransactionType.split) {
      icon = Icons.call_split;
    } else if (trade.type == TransactionType.dividend) {
      icon = FontAwesomeIcons.checkCircle;
    } else if (trade.type == TransactionType.sell) {
      icon = FontAwesomeIcons.arrowAltCircleDown;
    } else icon = FontAwesomeIcons.arrowAltCircleUp;
    return Icon (icon, color: Colors.lightGreen);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradesBloc, TradesState> (
      builder: (BuildContext context, TradesState state) {
        return ListTile(
          leading: (state is TradesLoadedEditing) ?
              GestureDetector(
                child: Icon(Icons.edit),
                onTap: () { clickedEdit(context, state); },
              )
              : formatIcon (trade),
          title: Text(DateFormat.yMMMMd().format (trade.transactionDate), style: TextStyle (fontSize: 12)),
          subtitle: formatSubtitle (trade),
          trailing: (state is TradesLoadedEditing) ?
              GestureDetector(
                child: Icon(Icons.highlight_off, color: Colors.red),
                onTap: () {
                  Alert(
                    context: context,
                    type: AlertType.warning,
                    title: "Delete Trade",
                    desc: "Are you sure you wish to delete the trade on " + DateFormat.yMMMMd().format (trade.transactionDate) + "?",
                    buttons: [
                      DialogButton(
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          BlocProvider.of<TradesBloc>(context).add(DeletedTrade(id: trade.id, portfolioId: trade.portfolioId, ticker: trade.ticker));
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
              )
            : null,
        );
      }
    );
  }
}

class TradeGroupHeader extends StatelessWidget {
  final TradeGroup tradeGroup;

  TradeGroupHeader ({@required this.tradeGroup});

  void clickedAdd(BuildContext context, TradesState state) async {
    BlocProvider.of<TradesBloc>(context).add(AddedTransaction());
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransaction(portfolioName: tradeGroup.portfolioName, portfolioId: tradeGroup.portfolioId)));
    if (state is TradesSavedOkay) {
      BlocProvider.of<TradesBloc>(context).add(EditedTrades (portfolioId: tradeGroup.portfolioId, ticker: tradeGroup.ticker));
    }
  }

  void toggleEditing(BuildContext context, TradesState state) {
    if (state is TradesEmpty) {
      clickedAdd(context, state);
    }
    if (state is TradeGroupLoadedEditing) {
      clickedAdd(context, state);
    }
    if (state is TradesLoadedEditing) {
      clickedAdd(context, state);
    }
    if (state is TradesLoaded) {
      BlocProvider
        .of<TradesBloc>(context)
        .add(EditedTrades(portfolioId: tradeGroup.portfolioId, ticker: tradeGroup.ticker));
    } else {
      BlocProvider
        .of<TradesBloc>(context)
        .add(SelectedTrades(portfolioId: tradeGroup.portfolioId, ticker: tradeGroup.ticker));
    }
  }

  void clickedDoneOrBack (context, state, isEditing) {
    if (isEditing) {
      if (state is TradesEmpty) {
        Navigator.pop(context);
      } else {
        if (state is TradesLoadedEditing) {
          BlocProvider.of<TradesBloc>(context).add(SelectedTrades(portfolioId: tradeGroup.portfolioId, ticker: tradeGroup.ticker));
        } else {
          BlocProvider.of<TradesBloc>(context).add(EditedTrades(portfolioId: tradeGroup.portfolioId, ticker: tradeGroup.ticker));
        }
      }
    } else {
      if (state is TradesLoadedEditing) {
        BlocProvider.of<TradesBloc>(context).add(SelectedTrades(portfolioId: tradeGroup.portfolioId, ticker: tradeGroup.ticker));
      }
      if (state is TradesLoaded) {
        BlocProvider.of<TradesBloc>(context).add(PickedPortfolio(tradeGroup.portfolioId));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradesBloc, TradesState> (
      builder: (BuildContext context, TradesState state) {
       bool _isEditing = (state is TradesLoadedEditing) || (state is TradesEmpty);
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
                    child: _isEditing ? Icon(Icons.done) : Icon(Icons.arrow_back_ios),
                    onTap: () => clickedDoneOrBack(context, state, _isEditing)
                  ),
                  Expanded(child: Text(tradeGroup.ticker, style: kPortfolioHeaderTitle, textAlign: TextAlign.center)),
                  GestureDetector(
                    child: _isEditing ? Icon(FontAwesomeIcons.plus) : Icon(FontAwesomeIcons.edit),
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

class TradeGroupSection extends StatelessWidget {
  final TradeGroup tradeGroup;
  TradeGroupSection (this.tradeGroup);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradesBloc, TradesState>(
      builder: (BuildContext context, TradesState state) {
        if (state is TradesSavedOkay) {
          BlocProvider.of<TradesBloc>(context).add(EditedTrades(portfolioId: tradeGroup.portfolioId, ticker: tradeGroup.ticker));
        }
        if (state is TradesFailure) {
          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            child: EmptyScreen(message: state.message),
          );
        }
        if (state is TradeGroupLoaded) {
          return Column(
            children: <Widget>[
              _buildTradeGroupData(state.tradeGroup)
            ],
          );
        }
        if (state is TradeGroupLoadedEditing) {
          return Column(
            children: <Widget>[
              _buildTradeGroupData(state.tradeGroup)
            ],
          );
        }
        if (state is TradesLoaded) {
          return Column(
            children: <Widget>[
              _buildTrades(tradeGroup.portfolioName, state.trades)
            ],
          );
        }
        if (state is TradesLoadedEditing) {
          return Column(
            children: <Widget>[
              _buildTrades(tradeGroup.portfolioName, state.trades)
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
  Widget _buildTrades(String portfolioName, List<Trade> trades) {
    return  ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: trades.length,
      itemBuilder: (BuildContext context, int index) {
        return TradeCard (portfolioName: portfolioName, trade: trades[index]);
      }
    );
  }
  Widget _buildTradeGroupData(TradeGroup tradeGroup) {
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
        }
        if (state is TradesLoaded) {
          print ("TradesLoaded - but not doing anything");
        }
        return Container(child: Text ("Here but we shouldn't be!"));
      }
    );
  }
}

class TradeGroupFolder extends StatelessWidget {
  final TradeGroup tradeGroup;

  TradeGroupFolder ({@required this.tradeGroup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
        child: SafeArea(
          child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              TradeGroupHeader(tradeGroup: tradeGroup),
              TradeGroupSection(tradeGroup)
            ]
          )
        ),

        onRefresh: () async {
          // TODO - Reload folders section.
          /*
        BlocProvider
          .of<TradesBloc>(context)
          .add(PickedPortfolio(portfolioId));
          */
        },
      ),
    );
  }
}