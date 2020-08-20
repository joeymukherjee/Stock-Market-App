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
}
