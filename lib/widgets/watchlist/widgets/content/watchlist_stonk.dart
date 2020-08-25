import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/profile/profile_bloc.dart';
import 'package:sma/helpers/color/color_helper.dart';

import 'package:sma/helpers/text/text_helper.dart';
import 'package:sma/models/data_overview.dart';

import 'package:sma/shared/colors.dart';
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
        color: kTileColor,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(flex: 8, child: _buildCompanyData()),
              Expanded(flex: 5, child: _buildPriceData())
            ],
          ),
        ),

        shape: RoundedRectangleBorder(borderRadius: kStandatBorder),
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
  Widget _buildCompanyData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(data.symbol, style: kStockTickerSymbol),
        SizedBox(height: 4.0),
        Text(data.name, style: kCompanyNameStyle)
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
          padding: EdgeInsets.only(bottom: 8),
          child: Container(
            width: data.changesPercentage > 99.99 ? null : 100.0, // TODO - based on size of font

            decoration: BoxDecoration(
              borderRadius: kSharpBorder,
              color: determineColorBasedOnChange(data.change)
            ),

            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(determineTextBasedOnChange(data.change), textAlign: TextAlign.end),
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
