class StockProfile {
  final num price;
  final num beta;
  final num peRatio;
  final num volAvg;
  final num mktCap;
  final num changes;
  final num changesPercentage;
  final String companyName;
  final String exchange;
  final String industry;
  final String description;
  final String ceo;
  final String sector;

  StockProfile({
    this.price,
    this.beta,
    this.peRatio,
    this.volAvg,
    this.mktCap,
    this.changes,
    this.changesPercentage,
    this.companyName,
    this.exchange,
    this.industry,
    this.description,
    this.ceo,
    this.sector,
  });
}
