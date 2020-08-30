import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sma/helpers/url/url.dart';
import 'package:sma/widgets/widgets/base_list.dart';

class Attributions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle _kHeadlineStyle = Theme.of(context).textTheme.headline6;
    TextStyle _kTextStyle = Theme.of(context).textTheme.caption;
    TextStyle _kSubtitleStyling = Theme.of(context).textTheme.subtitle1;
    return BaseList(
      children: <Widget>[
        Column(
          children: [
            Text('StonksJM!', style: _kHeadlineStyle),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Authors:', style: _kSubtitleStyling),
                Column (children: [Text ('Joey Mukherjee'), Text ('Joshua Garcia')],)
              ],
            ),
            Divider(),
            GestureDetector(
              onTap: () => launchUrl('https://github.com/joeymukherjee/Stock-Market-App.git'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  SizedBox(height: 8),
                  Text('You can find this app\'s source code by tapping here.', style: _kTextStyle),
                ],
              ),
            ),
            Divider(),
          ],
        ),
        Divider(),

        _buildContent(
          headlineStyle: _kHeadlineStyle,
          textStyle: _kTextStyle,
          title: 'Built with Flutter',
          text: 'None of this would have been posible without Flutter, its amazing community and packages.',
          url: 'https://flutter.dev/'
        ),
        Divider(),

        Text('APIs used in this app:', style: _kHeadlineStyle),
        SizedBox(height: 18),
        _buildApisContent(
          textStyle: _kTextStyle,
          subtitleStyle: _kSubtitleStyling,
          title: 'Financial Modeling Prep API',
          text: 'We proudly use this API for the portfolio, markets, and watchlist portion of the code.',
          url: 'https://financialmodelingprep.com/developer/docs/',
          icon: FontAwesomeIcons.shapes,
        ),

       /*
        Divider(),
        _buildApisContent(
          textStyle: _kTextStyle,
          subtitleStyle: _kSubtitleStyling,
          title: 'IEX Cloud API',
          text: 'The Portfolio & Markets can be powered by this API. Tap here to learn more.',
          url: 'https://iexcloud.io/s/ae6531cc',
          icon: FontAwesomeIcons.cloud,
        ),
        */

        Divider(),
        _buildApisContent(
          textStyle: _kTextStyle,
          subtitleStyle: _kSubtitleStyling,
          title: 'Alpha Vantage API',
          text: 'The Search section is powered by Alpha Vantage API. Tap here to learn more.',
          url: 'https://www.alphavantage.co/documentation/',
          icon: FontAwesomeIcons.search,
        ),

        Divider(),
        _buildApisContent(
          textStyle: _kTextStyle,
          subtitleStyle: _kSubtitleStyling,
          title: 'Powered by NewsAPI.org',
          text: 'The news section is powered by the News API. Tap here to learn more.',
          url: 'https://newsapi.org/',
          icon: FontAwesomeIcons.globeAmericas,
        ),

        Divider(),
        _buildContent(
          headlineStyle: _kHeadlineStyle,
          textStyle: _kTextStyle,
          title: 'This code originated from code done by Joshua García.',
          text: 'You can find his app\'s source code by tapping here.',
          url: 'https://github.com/JoshuaR503/Stock-Market-App'
        ),
/*
        Divider(),
        _buildApisContent(
          textStyle: _kTextStyle,
          subtitleStyle: _kSubtitleStyling,
          title: 'Finnhub Stock API',
          text: 'The news section in the Profile page is powered by the Finnhub Stock API. Tap here to learn more.',
          url: 'https://finnhub.io/',
          icon: FontAwesomeIcons.solidNewspaper,
        ),
*/
      ],
    );
  }

  Widget _buildContent({String title, String text, String url, TextStyle headlineStyle, TextStyle textStyle}) {
    return GestureDetector(
      onTap: () => launchUrl(url),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: headlineStyle),
          SizedBox(height: 8),
          Text(text, style: textStyle),
        ],
      ),
    );
  }

  Widget _buildApisContent({String title, String text, String url, IconData icon, TextStyle textStyle, TextStyle subtitleStyle}) {
    return Padding(
      padding: EdgeInsets.only(bottom:8, top:8),
      child: GestureDetector(
        onTap: () => launchUrl(url),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(icon),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: subtitleStyle),
                  SizedBox(height: 8),
                  Text(text, style: textStyle),
                ],
              )
            )
          ],
        )
      ),
    );
  }
}