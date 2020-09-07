import 'package:flutter/material.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/shared/styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sma/widgets/portfolio/transaction.dart';

class PortfolioHeadingSection extends StatelessWidget {
  final PortfolioFolderModel folder;

  PortfolioHeadingSection ({@required this.folder});

  void clickedAdd(BuildContext context, TradesState state) async {
    BlocProvider.of<TradesBloc>(context).add(AddedTransaction());
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransaction(portfolioName: folder.name, portfolioId: folder.id, defaultTicker: null)));
    if (state is TradesSavedOkay) {
      BlocProvider.of<TradesBloc>(context).add(PickedPortfolio(folder.id, folder.defaultSortOption));
    }
  }

  void toggleEditing(BuildContext context, TradesState state) {
    if (state is TradesEmpty) {               // when they are in a portfolio without trades
      clickedAdd(context, state);
    }
    if (state is TradeGroupsLoadedEditing) {  // when they are in a portfolio with trades
      clickedAdd(context, state);
    } else {
      BlocProvider
        .of<TradesBloc>(context)
        .add(EditedTradeGroup(folder.id, folder.defaultSortOption));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradesBloc, TradesState> (
      builder: (BuildContext context, TradesState state) {
        bool _isEditing = (state is TradeGroupsLoadedEditing) || (state is TradesEmpty);
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
                                    {
                                      BlocProvider.of<TradesBloc>(context).add(PickedPortfolio(folder.id, folder.defaultSortOption))
                                    }
                                  } : Navigator.pop(context)
                    }
                  ),
                  Expanded(child: Text(folder.name, style: kPortfolioHeaderTitle, textAlign: TextAlign.center)),
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