import 'package:flutter/material.dart';
import 'package:sma/models/portfolio/folder.dart';

import 'package:sma/shared/colors.dart';
import 'package:sma/shared/styles.dart';

class PortfolioFolderCard extends StatelessWidget {

  final PortfolioFolderModel data;

  PortfolioFolderCard({
    @required this.data
  });

  static const _kCompanyNameStyle = const TextStyle(
    color: Color(0XFFc2c2c2),
    fontSize: 13,
    height: 1.5
  );

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
            ],
          ),
        ),

        shape: RoundedRectangleBorder(borderRadius: kStandatBorder),
        onPressed: () {

          // Trigger fetch event.
          /*
          BlocProvider
            .of<PortfolioFolderBloc>(context)
            .add(FetchProfileData(name: data.name));

          // Send to Profile.
          Navigator.push(context, MaterialPageRoute(builder: (_) => Profile(symbol: data.symbol))); */
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
        SizedBox(height: 4.0),
        Text(data.name, style: _kCompanyNameStyle,)
      ], 
    );
  }
}
