import 'package:dio/dio.dart';
import 'package:sma/helpers/fetch_client.dart';
import 'package:sma/keys/api_keys.dart';
import 'package:sma/models/profile/market_index.dart';
import 'package:sma/models/profile/stock_quote.dart';
import 'package:sma/models/profile/stock_profile.dart';

class FNPFetchClient extends FetchClient {
  Future<Response> fetchData({Uri uri}) async {
    return await Dio().getUri(uri);
  }

  Future<Response> post({Uri uri, Map<String, dynamic> data}) async {
    return await Dio().postUri(uri, data: data);
  }

  // Makes an HTTP request to any endpoint from Financial Modeling Prep API.
  Future<Response> financialModelRequest(String endpoint) async {
    final Uri uri = Uri.https('financialmodelingprep.com', endpoint, {
      'apikey': kFinancialModelingPrepApi
    });
    print(uri);
    return await Dio().getUri(uri);
  }

 StockQuote fromFinancialModelingQuote (Map<String, dynamic> json) {
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

  StockProfile fromFinancialModelingProfile (Map<String, dynamic> json) {
    return StockProfile(
      price: json['price'],
      beta: json['beta'],
      volAvg: json['volAvg'],
      mktCap: json['mktCap'],
      changes: json['changes'],
      changesPercentage: json['changesPercent'],
      companyName: json['companyName'],
      exchange: json['exchange'],
      industry: json['industry'],
      description: json['description'],
      ceo: json['ceo'],
      sector: json['sector'],
    );
  }

  List<MarketIndexModel> fromFinancialModelingIndexes (List<dynamic> items) {
    return items
    .map((item) => fromFinancialModelingIndexesFromJson (item))
    .toList();
  }

  MarketIndexModel fromFinancialModelingIndexesFromJson (Map<String, dynamic> json) {
    return MarketIndexModel(
      symbol: json['symbol'],
      change: json['change'],
      price: json['price'],
      name: json['name'],
    );
  }

  @override
  Future<List<MarketIndexModel>> getIndexes () async {
    String symbols = 'DIA,SPY,QQQ,IWM,VXX';
    if (kFinancialModelingPrepApi == 'demo') {
      symbols = 'AAPL,AAPL,AAPL,AAPL,AAPL';
    }
    final Uri uri = Uri.https('financialmodelingprep.com', '/api/v3/quote/$symbols', {
      'apikey': kFinancialModelingPrepApi
    });
    Response response = await Dio().getUri(uri);
    print (uri);
    print (response.data);
    return fromFinancialModelingIndexes (response.data);
  }

  @override
  Future<Response> getChart (String symbol, String duration) async {
    if (kFinancialModelingPrepApi == 'demo') {
      symbol = 'AAPL';
    }
    final DateTime date = DateTime.now();
    final String authority = 'financialmodelingprep.com';
    final Uri uri = Uri.https(authority, '/api/v3/historical-price-full/$symbol', {
      'from': '${date.year - 1}-${date.month}-${date.day}',
      'to': '${date.year}-${date.month}-${date.day - 1}',
      'apikey': kFinancialModelingPrepApi
    });
    return await Dio().getUri(uri);
  }

  @override
  Future<StockQuote> getQuote (String symbol) async {
    if (kFinancialModelingPrepApi == 'demo') {
      symbol = 'AAPL';
    }
    Response response = await financialModelRequest('/api/v3/quote/$symbol');
    return fromFinancialModelingQuote(response.data);
  }

  @override
  Future<StockQuote> getQuoteFull (String symbol) async {
    if (kFinancialModelingPrepApi == 'demo') {
      symbol = 'AAPL';
    }
    Response response = await financialModelRequest('/api/v3/quote/$symbol');
    return fromFinancialModelingQuote(response.data);
  }

  @override
  Future<StockProfile> getCompanyProfile (String symbol) async {
    if (kFinancialModelingPrepApi == 'demo') {
      symbol = 'AAPL';
    }
    Response response = await financialModelRequest('/api/v3/company/profile/$symbol');
    return (fromFinancialModelingProfile(response.data));
  }

  @override
  Future<Response> getProfileStats (String symbol) {
    if (kFinancialModelingPrepApi == 'demo') {
      symbol = 'AAPL';
    }
    return financialModelRequest('/api/v3/company/profile/$symbol');
  }

  @override
  Future<Response> getMarketActives () {
    return financialModelRequest('/api/v3/stock/actives');
  }

  @override
  Future<Response> getMarketGainers () {
    return financialModelRequest('/api/v3/stock/gainers');
  }

  @override
  Future<Response> getMarketLosers () {
    return financialModelRequest('/api/v3/stock/losers');
  }
}
