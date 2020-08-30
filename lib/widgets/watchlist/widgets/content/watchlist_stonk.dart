import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/profile/profile_bloc.dart';
import 'package:sma/helpers/color/color_helper.dart';

import 'package:sma/helpers/text/text_helper.dart';
import 'package:sma/models/data_overview.dart';

import 'package:sma/shared/styles.dart';

import 'package:sma/widgets/profile/profile.dart';

class WatchlistStockCard extends StatelessWidget {

  final StockOverviewModel data;

  WatchlistStockCard({
    @required this.data
  });

  @override
  Widget build(BuildContext context) {
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
              Expanded(flex: 8, child: _buildCompanyData(context)),
              Expanded(flex: 5, child: _buildPriceData())
            ],
          ),
        ),

        shape: RoundedRectangleBorder(borderRadius: kStandardBorder),
        onPressed: () {

          // Trigger fetch event.
          BlocProvider
            .of<ProfileBloc>(context)
            .add(FetchProfileData(symbol: data.symbol));

          // Send to Profile.
          Navigator.push(context, MaterialPageRoute(builder: (_) => Profile(symbol: data.symbol)));
        },
      ),
    );
  }

  /// This method is in charge of rendering the stock company data.
  /// This is the left side in the card.
  /// It renders the  [symbol] and the company [name] from [data].
  Widget _buildCompanyData(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(data.symbol, style: kStockTickerSymbol),
        SizedBox(height: 4.0),
        Text(data.name, style: Theme.of(context).textTheme.bodyText2)
      ],
    );
  }

  /// This method is in charge of rendering the stock company data.
  /// This is the right side in the card.
  /// It renders the [change] and the stock's [price] from [data].
  Widget _buildPriceData() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            determineTextBasedOnChange(data.change),
            style: TextStyle (color: determineColorBasedOnChange(data.change)),
            textAlign: TextAlign.end
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(formatCurrencyText(data.price),
            overflow: TextOverflow.visible,
            textAlign: TextAlign.end,
            style: kStockPriceStyle
          ),
        ),
      ],
    );
  }
}
