import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sma/helpers/color/color_helper.dart';
import 'package:sma/helpers/fetch_client.dart';
import 'package:sma/helpers/text/text_helper.dart';
import 'package:sma/models/profile/stock_chart.dart';
import 'package:sma/models/profile/stock_profile.dart';
import 'package:sma/models/profile/stock_quote.dart';

import 'package:sma/widgets/profile/widgets/profile/profile_graph.dart';
import 'package:sma/widgets/profile/widgets/profile/profile_summary.dart';

import 'package:sma/respository/profile/client.dart'; 

class ChartSwitcher extends StatefulWidget {
  final String ticker;
  final Color color;
  final List<StockChart> stockChart;

  ChartSwitcher ({Key key, @required this.ticker, @required this.color, @required this.stockChart}) : super (key:key);
  @override
  _ChartSwitcherState createState() => _ChartSwitcherState(stockChart);
}

class _ChartSwitcherState extends State<ChartSwitcher> with SingleTickerProviderStateMixin {
  List<StockChart> stockChart;
  _ChartSwitcherState (this.stockChart); // constructor
  void setChart (List<StockChart> newValue) {setState (() { stockChart = newValue; });}

  final List<Tab> cadences = <Tab>[
    Tab (text: '1d'),
    Tab (text: '5d'),
    Tab (text: '1m'),
    Tab (text: '3m'),
    Tab (text: '1y'),
    Tab (text: '5y')
  ];
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 4, length: cadences.length);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
     _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange () async {
    if (!_tabController.indexIsChanging) {
      final String duration = cadences [_tabController.index].text;
      try {
        final Response<dynamic> stockChart = await ProfileClient(globalFetchClient).fetchChart (symbol: widget.ticker, duration: duration);
        setChart (StockChart.toList(stockChart.data));
      } catch (err) {
        print ('Caught error $err');
      }
      build(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(
        children: [
          Container(
            height: 250,
            padding: EdgeInsets.only(top: 26),
            child: SimpleTimeSeriesChart(
              chart: stockChart,
              color: widget.color
            )
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabBar (
              tabs: cadences,
              controller: _tabController,
              labelColor: Theme.of(context).splashColor,
              unselectedLabelColor: Theme.of(context).highlightColor,
              labelStyle: TextStyle (fontSize: 8),
              isScrollable: true,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).highlightColor,
              ),
            ),
          ),
          Text (
            'Quotes provided by ' + globalFetchClient.getAttribution(),
            style: TextStyle(fontSize: 8),
            textAlign: TextAlign.right,
          )
        ],
      )
    ;
  }
}

class Profile extends StatelessWidget {

  final Color color;
  final StockQuote stockQuote;
  final StockProfile stockProfile;
  final List<StockChart> stockChart;

  Profile({
    @required this.color,
    @required this.stockProfile,
    @required this.stockQuote,
    @required this.stockChart,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(left: 26, right: 26, top: 26),
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(this.stockQuote.name ?? '-', style: Theme.of(context).textTheme.headline5),

            _buildPrice(context),
            ChartSwitcher(ticker: this.stockQuote.symbol, color: this.color, stockChart: this.stockChart),
            StatisticsWidget(
              quote: stockQuote,
              profile: stockProfile,
            )
          ],
        ),
      ],
    );
  }

  Widget _buildPrice(context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('\$${formatCurrencyText(stockQuote.price)}', style: Theme.of(context).textTheme.headline5),
          SizedBox(height: 8),
          Text('${determineTextBasedOnChange(stockQuote.change)}  (${determineTextPercentageBasedOnChange(stockQuote.changesPercentage)})', 
            style: determineTextStyleBasedOnChange(stockQuote.change)
          )
        ],
      ),
    );
  }
}