class MarketActiveModel {
  final String ticker;
  final double changes;
  final double price;
  final double changesPercentage;
  final String companyName;

  MarketActiveModel({
    this.ticker,
    this.changes,
    this.price,
    this.changesPercentage,
    this.companyName
  });

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
