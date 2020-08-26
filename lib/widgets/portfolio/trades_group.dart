import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sma/shared/styles.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';
import 'package:sma/models/trade/trade_group.dart';
import 'package:sma/widgets/widgets/loading_indicator.dart';
import 'package:sma/widgets/widgets/empty_screen.dart';
import 'package:sma/widgets/portfolio/add_transaction.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TradeGroupHeader extends StatelessWidget {
  final TradeGroup tradeGroup;

  TradeGroupHeader ({@required this.tradeGroup});

  void clickedAdd(BuildContext context, TradesState state) {
    BlocProvider.of<TradesBloc>(context).add(AddedTransaction());
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransaction(portfolioName: tradeGroup.portfolioName, portfolioId: tradeGroup.portfolioId)));
  }

  void toggleEditing(BuildContext context, TradesState state) {
    if (state is TradesEmpty) {
      clickedAdd(context, state);
    }
    if (state is TradeGroupLoadedEditing) {
        clickedAdd(context, state);
    } else {
      BlocProvider
        .of<TradesBloc>(context)
        .add(EditedTradeGroup(tradeGroup.portfolioId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradesBloc, TradesState> (
      builder: (BuildContext context, TradesState state) {
        //print ('PortfolioHeadingSection');
        //print(state);
        bool _isEditing = (state is TradeGroupLoadedEditing) || (state is TradesEmpty);
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
                    onTap: () => {
                      _isEditing ? {(state is TradesEmpty) ? Navigator.pop(context) :
                                    BlocProvider.of<TradesBloc>(context).add(PickedPortfolio(tradeGroup.portfolioId))
                                  } : Navigator.pop(context)
                    }
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

class TradesFolderSection extends StatelessWidget {
  final TradeGroup tradeGroup;
  TradesFolderSection (this.tradeGroup);

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
                // Navigator.push(context, MaterialPageRoute(builder: (_) => TradesGroup(tradeGroup)));
              }
            },
          ),
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
        if (state is TradesInitial) {
          BlocProvider
            .of<TradesBloc>(context)
            .add(TradesLoaded());
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

        return Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height),
          child: LoadingIndicatorWidget(),
        );
      },
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
        } else {
          return TradesFolderSection (tradeGroup);
        }
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