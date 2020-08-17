import 'package:meta/meta.dart';

class StockOverviewModel {
  final String symbol;
  final String name;
  final num price;
  final num changesPercentage;
  final num change;

  StockOverviewModel({
    @required this.symbol,
    @required this.name,
    @required this.price,
    @required this.changesPercentage,
    @required this.change
  });

// Changed for IEX Cloud
  factory StockOverviewModel.fromJson(Map<String, dynamic> json) {
    return StockOverviewModel(
      symbol: json['symbol'],
      name: json['companyName'],
      price: json['latestPrice'].toDouble (),
      changesPercentage: json['changePercent'].toDouble (),
      change: json['change'].toDouble (),
    );
  }
}
