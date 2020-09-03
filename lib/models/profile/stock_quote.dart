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

  StockQuote.unknown (String ticker) :
    this.symbol = ticker,
    this.name = '',
    this.price = 0.0,
    this.changesPercentage = 0.0,
    this.change = 0.0,
    this.dayLow = 0.0,
    this.dayHigh = 0.0,
    this.yearHigh = 0.0,
    this.yearLow = 0.0,
    this.marketCap = 0.0,
    this.volume = 0.0,
    this.avgVolume = 0.0,
    this.open = 0.0,
    this.previousClose = 0.0,
    this.eps = 0.0,
    this.pe = 0.0,
    this.beta = 0.0,
    this.sharesOutstanding = 0.0;
}
