class MarketActiveModel {
  final String ticker;
  final num changes;
  final num price;
  final num changesPercentage;
  final String companyName;

  MarketActiveModel({
    this.ticker,
    this.changes,
    this.price,
    this.changesPercentage,
    this.companyName
  });

// Changed for IEX Cloud
  factory MarketActiveModel.fromJson(Map<String, dynamic> json) {
    return MarketActiveModel(
      ticker: json['symbol'], // json['ticker'],
      changes: json['changes'],
      price: json['price'],
      changesPercentage: json['changePercent'], // json['changesPercentage'],
      companyName: json['companyName'],
    );
  }
}
