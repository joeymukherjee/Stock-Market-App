class StockQuote {
  final String symbol;
  final String name;

  final num price;
  final num changesPercentage;
  final num change;
  final num dayLow;
  final num dayHigh;
  final num yearHigh;
  final num yearLow;
  final num marketCap;

  final num volume;
  final num avgVolume;

  final num open;
  final num previousClose;
  final num eps;
  final num pe;
  final num beta;
  
  final num sharesOutstanding;

  StockQuote({
    this.symbol,
    this.name,
    this.price,
    this.changesPercentage,
    this.change,
    this.dayLow,
    this.dayHigh,
    this.yearHigh,
    this.yearLow,
    this.marketCap,
    this.volume,
    this.avgVolume,
    this.open,
    this.previousClose,
    this.eps,
    this.pe,
    this.beta,
    this.sharesOutstanding,
  });
}
