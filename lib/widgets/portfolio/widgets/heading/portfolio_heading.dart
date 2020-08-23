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

  void toggleEditing (BuildContext context, TradesState state) {
    if (state is TradesEditing) {
      
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradesBloc, TradesState> (
      builder: (BuildContext context, TradesState state) {
        bool _isEditing = (state is TradesEditing) || (state is TradesEmpty);
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
                    child: _isEditing ? Icon(FontAwesomeIcons.plus) : Icon(Icons.done),
                    onTap: () => _isEditing ?
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransaction(portfolioName: portfolioName, portfolioId: portfolioId))) :
                      Navigator.pop(context)
                  ),
                  Expanded(child: Text('Portfolio', style: kPortfolioHeaderTitle, textAlign: TextAlign.center)),
                  GestureDetector(
                    child: _isEditing ? Icon(Icons.done) : Icon(FontAwesomeIcons.edit),
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