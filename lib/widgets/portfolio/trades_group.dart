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
import 'package:sma/widgets/portfolio/add_transaction.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradesBloc, TradesState> (
      builder: (BuildContext context, TradesState state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget> [
            (state is TradesLoadedEditing) ?
              GestureDetector(
                child: Icon(Icons.edit),
                onTap: () { clickedEdit(context, state); },
              )
              : GestureDetector(
                child: Icon(FontAwesomeIcons.eye),
                onTap: () {},
              ),
            Text (DateFormat.yMMMMd().format (trade.transactionDate)),
            Text (trade.getNumberOfShares().toString()),
            Text (formatCurrencyText (trade.getTotalReturn())),
            (state is TradesLoadedEditing) ?
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
              : Container(),
          ]
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

/*
UNUSED??
class xTradesFolderSection extends StatelessWidget {
  final TradeGroup tradeGroup;
  xTradesFolderSection (this.tradeGroup);

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
                  // Expanded(flex: 8, child: _buildTradeGroupData()),
                ],
              ),
            ),

            shape: RoundedRectangleBorder(borderRadius: kStandardBorder),
            onPressed: () {

              // Trigger fetch event.
              if (state is TradeEditing) {
              //  Navigator.push(context, MaterialPageRoute(builder: (_) => ModifyTradesSection ('Edit', TradesGroup())));
              } else {
                /*
                BlocProvider
                  .of<TradesBloc>(context)
                  .add(PickedTradeGroup(tradeGroup.key));
                */
                //Navigator.push(context, MaterialPageRoute(builder: (_) => TradesGroup(tradeGroup)));
              }
            },
          ),
        );
      }
    );
  }
}
*/

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
        /*
        if (state is TradeGroupLoaded) {
          return xTradesFolderSection (tradeGroup);
        }
        */
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
          // Reload folders section.
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