import 'package:flutter/material.dart';
import 'package:sma/helpers/url/url.dart';
import 'package:sma/models/profile/news/stock_news.dart';

class ProfileNewsScreen extends StatelessWidget {

  final List<StockNews> news;

  ProfileNewsScreen({
    @required this.news
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(left: 26, right: 26, top: 26),
      children: <Widget>[
        Text('Latest News', style: Theme.of(context).textTheme.headline5),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: news.length,
          itemBuilder: (BuildContext context, int i) => _buildNewsCard(context, news[i])
        )
      ],
    );
  }

  Widget _buildNewsCard(BuildContext context, StockNews singleNew) {
    return GestureDetector(
      onTap: () => launchUrl(singleNew.url),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            singleNew.source,
            style: TextStyle( 
              color: Theme.of(context).highlightColor,
              fontWeight: FontWeight.w600
            ),
          ),  
          SizedBox(height: 8),  
          Text(
            singleNew.headline, style: TextStyle(
              height: 1.5,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ), 
            maxLines: 2, 
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Text(
            singleNew.summary, style: TextStyle(
              color:  Theme.of(context).highlightColor,
              height: 1.8,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Divider(),
        ],
      ),
    );
  }
}