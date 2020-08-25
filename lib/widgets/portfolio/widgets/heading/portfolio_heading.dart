import 'package:flutter/material.dart';
import 'package:sma/shared/styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sma/widgets/portfolio/add_transaction.dart';

class PortfolioHeadingSection extends StatelessWidget {
  final int portfolioId;
  final String portfolioName;

  PortfolioHeadingSection ({@required this.portfolioName, @required this.portfolioId});

  void clickedAdd(BuildContext context, TradesState state) {
    BlocProvider.of<TradesBloc>(context).add(AddedTransaction());
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransaction(portfolioName: portfolioName, portfolioId: portfolioId)));
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
        .add(EditedTradeGroup(portfolioId));
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
                                    BlocProvider.of<TradesBloc>(context).add(PickedPortfolio(portfolioId))
                                  } : Navigator.pop(context)
                    }
                  ),
                  Expanded(child: Text(portfolioName, style: kPortfolioHeaderTitle, textAlign: TextAlign.center)),
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