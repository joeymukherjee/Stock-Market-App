class MarketIndexModel {
  final String symbol;
  final num change;
  final num price;
  final String name;

  MarketIndexModel({
    this.symbol, 
    this.change, 
    this.price, 
    this.name
  });

  static List<MarketIndexModel> fromMap (Map <String, dynamic> json) {  
    List<MarketIndexModel> retVal = List ();
    json.forEach((key, value) =>
      retVal.add (MarketIndexModel (
        symbol: value ['quote']['symbol'], 
        change: value ['quote']['change'],
        price: value ['quote']['latestPrice'],
        name: value ['quote']['companyName'])
      )
    );
    return retVal;
  }
  /*
// Only for Financial Modeling
  static List<MarketIndexModel> toList(List<dynamic> items) {
    return items
    .map((item) => MarketIndexModel.fromJson(item))
    .toList();
  }

  factory MarketIndexModel.fromJson(Map<String, dynamic> json) {
    return MarketIndexModel(
      symbol: json['symbol'],
      change: json['change'],
      price: json['price'],
      name: json['name'],
    );
  }*/
}
