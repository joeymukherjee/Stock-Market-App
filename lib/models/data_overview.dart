import 'package:meta/meta.dart';
import 'package:sma/models/profile/stock_quote.dart';

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

  StockOverviewModel.fromStockQuote(StockQuote stockQuote) :
    this.symbol = stockQuote.symbol,
    this.name = stockQuote.name,
    this.price = stockQuote.price,
    this.change = stockQuote.change,
    this.changesPercentage = stockQuote.changesPercentage;
}
