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

  factory StockQuote.fromFinancialModeling(Map<String, dynamic> json) {
    return StockQuote(
      symbol: json['symbol'],
      name: json['name'],
      price: json['price'],
      changesPercentage: json['changesPercentage'],
      change: json['change'],
      dayLow: json['dayLow'],
      dayHigh: json['dayHigh'],
      yearHigh: json['yearHigh'],
      yearLow: json['yearLow'],
      marketCap: json['marketCap'],
      volume: json['volume'],
      avgVolume: json['avgVolume'],
      open: json['open'],
      previousClose: json['previousClose'],
      eps: json['eps'],
      pe: json['pe'],
      sharesOutstanding: json['sharesOutstanding'],
    );
  }

  factory StockQuote.fromIEXCloud(Map<String, dynamic> jsonQuote, Map<String, dynamic> jsonStats) {
    return StockQuote(
      symbol: jsonQuote['symbol'],
      name: jsonQuote['companyName'],
      price: jsonQuote['latestPrice'],
      changesPercentage: jsonQuote['changePercent'],
      change: jsonQuote['change'],
      dayLow: jsonQuote['low'],
      dayHigh: jsonQuote['high'],
      yearHigh: jsonStats['week52high'],
      yearLow: jsonStats['week52low'],
      marketCap: jsonStats['marketcap'],
      volume: jsonQuote['latestVolume'],
      avgVolume: jsonQuote['avgTotalVolume'],
      open: jsonQuote['open'],
      previousClose: jsonQuote['previousClose'],
      eps: jsonStats['ttmEPS'],
      beta: jsonStats['beta'],
      pe: jsonStats['peRatio'],
      sharesOutstanding: jsonStats['sharesOutstanding'],
    );
  }
}
