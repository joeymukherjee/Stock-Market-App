
import 'package:flutter/material.dart';
import 'package:sma/helpers/text/text_helper.dart';

import 'package:sma/models/profile/stock_profile.dart';
import 'package:sma/models/profile/stock_quote.dart';
import 'package:sma/shared/colors.dart';
import 'package:sma/widgets/profile/widgets/styles.dart';

class StatisticsWidget extends StatelessWidget {
  
  final StockQuote quote;
  final StockProfile profile;

  StatisticsWidget({
    @required this.quote,
    @required this.profile
  });

  static Text _renderText(dynamic text, bool isCurrency) {
    return text != null 
    ? isCurrency ? 
        Text(formatCurrencyText(text), style: TextStyle (fontSize: 12),)
      : Text(compactText(text), style: TextStyle (fontSize: 12),)
    : Text('-');
  }
  

  List<Widget> _leftColumn() {
    return [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Open', style: summaryStyle),
        trailing: _renderText(quote.open, true)
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Prev Close', style: summaryStyle),
        trailing: _renderText(quote.previousClose, true)
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Day High', style: summaryStyle),
        trailing: _renderText(quote.dayHigh, true)
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Day Low', style: summaryStyle),
        trailing: _renderText(quote.dayLow, true)
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('52 WK High', style: summaryStyle),
        trailing: _renderText(quote.yearHigh, true)
      ),

      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('52 WK Low', style: summaryStyle),
        trailing: _renderText(quote.yearLow, true)
      ),
    ];
  }

  List<Widget> _rightColumn() {
    return [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Outstanding Shares', style: summaryStyle),
        trailing: _renderText(quote.sharesOutstanding, false)
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Volume', style: summaryStyle),
        trailing: _renderText(quote.volume, false)
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Avg Vol', style: summaryStyle),
        trailing: _renderText(quote.avgVolume, false)
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('MKT Cap', style: summaryStyle),
        trailing: _renderText(quote.marketCap, false)
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('P/E Ratio', style: summaryStyle),
        trailing: _renderText(quote.pe, true)
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('EPS', style: summaryStyle),
        trailing: _renderText(quote.eps, true)
      ),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 16),

        Text('Summary',style: kProfileScreenSectionTitle),
        SizedBox(height: 8),

        Row(
          children: <Widget>[
            Expanded(
              child: Column(children: _leftColumn()),
            ),

            SizedBox(width: 40),

            Expanded(
              child: Column(children: _rightColumn()),
            )
          ],
        ),
        Divider(),

        

        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('CEO', style: subtitleStyle),
          trailing: Text(displayDefaultTextIfNull(profile.ceo)),
        ),
        Divider(),

        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Sector', style: subtitleStyle),
          trailing: Text(displayDefaultTextIfNull(profile.sector)),
        ),
        Divider(),

        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Exchange', style: subtitleStyle),
          trailing: Text('${profile.exchange}'),
        ),
        Divider(),

        Text('About ${profile.companyName ?? '-'} ',style: kProfileScreenSectionTitle),
        SizedBox(height: 8),

        Text(profile.description ?? '-',
          style: TextStyle(
            fontSize: 16,
            color: kLighterGray,
            height: 1.75
          ),
        ),
        Divider(),
        
        SizedBox(height: 30),
      ],
    );
  }
}