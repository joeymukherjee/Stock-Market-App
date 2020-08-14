class StockProfile {
  final num price;
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

  factory StockProfile.fromFinancialModeling(Map<String, dynamic> json) {
    return StockProfile(
      price: json['price'],
      // beta: json['beta'],
      volAvg: json['avgTotalVolume'],
      mktCap: json['marketcap'],
      changes: json['change'],
      changesPercentage: json['changePercent'],
      companyName: json['companyName'],
      exchange: json['primaryExchange'],
      industry: json['industry'],
      description: json['description'],
      ceo: json['ceo'],
      sector: json['sector'],
    );
  }

  factory StockProfile.fromIEXCloud(Map<String, dynamic> jsonCompany, Map<String, dynamic> jsonQuote) {
    //print ("StockProfile.fromIEX");
    //print (jsonCompany);
    return StockProfile(
      price: jsonQuote['latestPrice'],
      peRatio: jsonQuote['peRatio'],
      volAvg: jsonQuote['avgTotalVolume'],
      mktCap: jsonQuote['marketcap'],
      changes: jsonQuote['change'].toDouble (),
      changesPercentage: jsonQuote['changePercent'],
      companyName: jsonCompany['companyName'],
      exchange: jsonCompany['exchange'],
      industry: jsonCompany['industry'],
      description: jsonCompany['description'],
      ceo: jsonCompany['CEO'],
      sector: jsonCompany['sector'],
    );
  }
}
