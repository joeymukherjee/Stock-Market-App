import 'package:flutter/material.dart';

import 'package:sma/helpers/color/color_helper.dart';
import 'package:sma/helpers/text/text_helper.dart';

import 'package:sma/models/profile/market_index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/widgets/profile/profile.dart';
import 'package:sma/bloc/profile/profile_bloc.dart';
import 'package:sma/shared/colors.dart';
import 'package:sma/shared/styles.dart';

class WatchlistIndexWidget extends StatelessWidget {

  final MarketIndexModel index;

  WatchlistIndexWidget({
    @required this.index
  });

  static const _indexNameStyle = const TextStyle(
   fontWeight: FontWeight.bold,
   fontSize: 16
  );

  static const _indexPriceStyle = const TextStyle(
    fontSize: 14,
    color: kLightGray
  );

  static const _indexPriceChange = const TextStyle(
    fontSize: 12,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      
      padding: EdgeInsets.symmetric(horizontal: 4),
      onPressed: () {
        // Trigger fetch event.
        BlocProvider
          .of<ProfileBloc>(context)
          .add(FetchProfileData(symbol: index.symbol));
        // Send to Profile.
        Navigator.push(context, MaterialPageRoute(builder: (_) => Profile(symbol: index.symbol)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Text(index.name, style: _indexNameStyle, maxLines: 1),
            Text(formatCurrencyText(index.price), style: _indexPriceStyle),

            Container(
              decoration: BoxDecoration(
                borderRadius: kSharpBorder,
                color: determineColorBasedOnChange(index.change)
              ),
  
              width: MediaQuery.of(context).size.width / 3,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(determineTextBasedOnChange(index.change), style: _indexPriceChange,),
            ),
          ]
        ),
      ),
    );
  }
}