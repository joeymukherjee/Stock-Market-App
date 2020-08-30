import 'package:dio/dio.dart';
import 'package:sma/helpers/fetch_client.dart';
import 'package:sma/keys/api_keys.dart';
import 'package:sma/models/profile/market_index.dart';
import 'package:sma/models/markets/market_active/market_active.dart';
import 'package:sma/models/profile/stock_chart.dart';
import 'package:sma/models/profile/stock_quote.dart';
import 'package:sma/models/profile/stock_profile.dart';

class FNPFetchClient extends FetchClient {
  String getAttribution () { return "Financial Modeling Prep"; }

  Future<Response> fetchData({Uri uri}) async {
    return await Dio().getUri(uri);
  }

  Future<Response> post({Uri uri, Map<String, dynamic> data}) async {
    return await Dio().postUri(uri, data: data);
  }

  // Makes an HTTP request to any endpoint from Financial Modeling Prep API.
  Future<Response> financialModelRequest(String endpoint) async {
    final Uri uri = Uri.https('financialmodelingprep.com', endpoint, {
      'apikey': endpoint.contains('AAPL') ? 'demo'  : kFinancialModelingPrepApi
    });
    // print(uri);
    return await Dio().getUri(uri);
  }

 StockQuote fromFinancialModelingQuoteList(List <dynamic> jsonList) {
    Map<String, dynamic> json = jsonList [0];
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

  StockQuote fromFinancialModelingQuoteMap(Map <String, dynamic> json) {
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

  StockProfile fromFinancialModelingProfile(Map<String, dynamic> jsonOriginal) {
    var json = jsonOriginal['profile'];
    return StockProfile(
      price: json['price'],
      beta: double.parse (json['beta']),
      volAvg: double.parse(json['volAvg']),
      mktCap: double.parse(json['mktCap']),
      //changes: double.parse(json['changes']),
      //changesPercentage: double.parse (json['changesPercentage']),
      companyName: json['companyName'],
      exchange: json['exchange'],
      industry: json['industry'],
      description: json['description'],
      ceo: json['ceo'],
      sector: json['sector'],
    );
  }

  List<MarketIndexModel> fromFinancialModelingIndexes(List<dynamic> items) {
    return items
    .map((item) => fromFinancialModelingIndexesFromJson(item))
    .toList();
  }

  MarketIndexModel fromFinancialModelingIndexesFromJson(Map<String, dynamic> json) {
    return MarketIndexModel(
      symbol: json['symbol'],
      change: json['change'],
      price: json['price'],
      name: json['name'],
    );
  }

  List<MarketActiveModel> fromFinancialModelingActives(List<dynamic> items) {
    if (items != null) {
      return items
      .map((item) => fromFinancialModelingSingle(item))
      .toList();
    } else {
      return <MarketActiveModel>[];
    }
  }

  MarketActiveModel fromFinancialModelingSingle(Map<String, dynamic> json) {
    return MarketActiveModel(
      ticker: json['ticker'],
      changes: json['changes'].toDouble (),
      price: double.parse(json['price']),
      changesPercentage: double.parse(json['changesPercentage'].replaceAll(RegExp('[%()]'), '')) / 100.0,
      companyName: json['companyName'] == null ? '-' : json['companyName'],
    );
  }

  @override
  Future<List<MarketIndexModel>> getIndexes() async {
    String symbols = "^DJI,^GSPC,^IXIC,^RUT,^VIX";
    final Uri uri = Uri.https('financialmodelingprep.com', '/api/v3/quote/$symbols', {
      'apikey': kFinancialModelingPrepApi
    });
    Response response = await Dio().getUri(uri);
    // print (uri);
    // print (response.data);
    return fromFinancialModelingIndexes(response.data);
  }

  @override
  Future<List<StockChart>> getChart(String symbol, String duration) async {
    if (kFinancialModelingPrepApi == 'demo') {
      symbol = 'AAPL';
    }
    final DateTime toDate = DateTime.now();
    Duration interval;
    switch (duration) {
      case '1d' : interval = Duration(days: 1); break;
      case '5d' : interval = Duration(days: 5); break;
      case '1m' : interval = Duration(days: 30); break;
      case '3m' : interval = Duration(days: 90); break;
      case '1y' : interval = Duration(days: 365); break;
      case '5y' : interval = Duration(days: 365 * 5); break;
    }
    final DateTime fromDate = toDate.subtract(interval);
    final String authority = 'financialmodelingprep.com';
    Uri url;
    if (duration == '1d') {
      url = Uri.https(authority, '/api/v3/historical-chart/1min/$symbol', {
        'apikey': symbol == 'AAPL' ? 'demo' : kFinancialModelingPrepApi
      });
    } else {
      url = Uri.https(authority, '/api/v3/historical-price-full/$symbol', {
        'from': '${fromDate.year}-${fromDate.month}-${fromDate.day}',
        'to': '${toDate.year}-${toDate.month}-${toDate.day - 1}',
        'apikey': symbol == 'AAPL' ? 'demo' : kFinancialModelingPrepApi
      });
    }
    
    // print (url);
    Response response = await Dio().getUri(url);
    if (duration == '1d') {
      return StockChart.toList (response.data);
    } else {
      return StockChart.toList (response.data ['historical']);
    }
  }

  @override
  Future<StockQuote> getQuote(String symbol) async {
    if (kFinancialModelingPrepApi == 'demo') {
      symbol = 'AAPL';
    }
    Response response = await financialModelRequest('/api/v3/quote/$symbol');
    if (response.data is List) {
      return fromFinancialModelingQuoteList(response.data);
    } else {
      return fromFinancialModelingQuoteMap(response.data);
    }
  }

  @override
  Future<StockQuote> getQuoteFull(String symbol) async {
    if (kFinancialModelingPrepApi == 'demo') {
      symbol = 'AAPL';
    }
    Response response = await financialModelRequest('/api/v3/quote/$symbol');
    if (response.data is List) {
      return fromFinancialModelingQuoteList(response.data);
    } else {
      return fromFinancialModelingQuoteMap(response.data);
    }
  }

  @override
  Future<StockProfile> getCompanyProfile(String symbol) async {
    if (kFinancialModelingPrepApi == 'demo') {
      symbol = 'AAPL';
    }
    Response response = await financialModelRequest('/api/v3/company/profile/$symbol');
    return (fromFinancialModelingProfile(response.data));
  }

  @override
  Future<Response> getProfileStats(String symbol) {
    if (kFinancialModelingPrepApi == 'demo') {
      symbol = 'AAPL';
    }
    return financialModelRequest('/api/v3/company/profile/$symbol');
  }

  @override
  Future<List<MarketActiveModel>> getMarketActives() async {
    Response json = await financialModelRequest('/api/v3/stock/actives');
    return fromFinancialModelingActives(json.data['mostActiveStock']);
  }

  @override
  Future<List<MarketActiveModel>> getMarketGainers() async {
    Response json = await financialModelRequest('/api/v3/stock/gainers');
    return fromFinancialModelingActives(json.data['mostGainerStock']);
  }

  @override
  Future<List<MarketActiveModel>> getMarketLosers() async {
    Response json = await financialModelRequest('/api/v3/stock/losers');
    return fromFinancialModelingActives(json.data['mostLoserStock']);
  }
}
