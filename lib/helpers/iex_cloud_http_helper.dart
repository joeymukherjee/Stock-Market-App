import 'package:dio/dio.dart';
import 'package:sma/helpers/fetch_client.dart';
import 'package:sma/keys/api_keys.dart';
import 'package:sma/models/markets/market_active/market_active.dart';
import 'package:sma/models/profile/market_index.dart';
import 'package:sma/models/profile/stock_chart.dart';
import 'package:sma/models/profile/stock_quote.dart';
import 'package:sma/models/profile/stock_profile.dart';

class IEXFetchClient extends FetchClient {
  static final IEXFetchClient _singleton = IEXFetchClient._internal();

  factory IEXFetchClient() {
    return _singleton;
  }

  IEXFetchClient._internal();
  String getAttribution () { return "IEX Cloud"; }

  final String baseUrl = useIEXCloudSandbox ? kIEXCloudSandboxBaseUrl : kIEXCloudBaseUrl;
  final String iexCloudKey = useIEXCloudSandbox ? kIEXCloudSandboxKey : kIEXCloudKey;

  Future<Response> fetchData({Uri uri}) async {
    return await Dio().getUri(uri);
  }

  Future<Response> post({Uri uri, Map<String, dynamic> data}) async {
    return await Dio().postUri(uri, data: data);
  }

  // Makes an HTTP request to any endpoint from IEX Cloud API.
  Future<Response> iexCloudRequest(String endpoint) async {
    final Uri uri = Uri.https(baseUrl, endpoint, {
      'types': 'quote',
      'token': iexCloudKey
    });
    // print ("iex_cloud_http_helper - " + uri.toString());
    return await Dio().getUri(uri);
  }

  StockQuote fromIEXCloudQuote(Map<String, dynamic> jsonQuote, Map<String, dynamic> jsonStats) {
    if (jsonStats != null) {
      return StockQuote(
        symbol: jsonQuote['symbol'],
        name: jsonQuote['companyName'],
        price: jsonQuote['latestPrice'],
        changesPercentage: jsonQuote['changePercent'],
        change: jsonQuote['change'],
        dayLow: jsonQuote['low'],
        dayHigh: jsonQuote['high'],
        volume: jsonQuote['latestVolume'],
        avgVolume: jsonQuote['avgTotalVolume'],
        open: jsonQuote['open'],
        previousClose: jsonQuote['previousClose'],

        yearHigh: jsonStats['week52high'],
        yearLow: jsonStats['week52low'],
        marketCap: jsonStats['marketcap'],
        eps: jsonStats['ttmEPS'],
        beta: jsonStats['beta'],
        pe: jsonStats['peRatio'],
        sharesOutstanding: jsonStats['sharesOutstanding'],
      );
    } else {
      return StockQuote(
        symbol: jsonQuote['symbol'],
        name: jsonQuote['companyName'],
        price: jsonQuote['latestPrice'].toDouble (),
        changesPercentage: jsonQuote['changePercent'].toDouble (),
        change: jsonQuote['change'].toDouble (),
        dayLow: jsonQuote['low'],
        dayHigh: jsonQuote['high'],
        volume: jsonQuote['latestVolume'],
        avgVolume: jsonQuote['avgTotalVolume'],
        open: jsonQuote['open'],
        previousClose: jsonQuote['previousClose'],
      );
    }
  }

  StockProfile fromIEXCloudProfile(Map<String, dynamic> jsonCompany, Map<String, dynamic> jsonQuote) {
    return StockProfile(
      price: jsonQuote['latestPrice'],
      peRatio: jsonQuote['peRatio'],
      volAvg: jsonQuote['avgTotalVolume'],
      mktCap: jsonQuote['marketcap'],
      changes: jsonQuote['change'],
      changesPercentage: jsonQuote['changePercent'],
      companyName: jsonCompany['companyName'],
      exchange: jsonCompany['exchange'],
      industry: jsonCompany['industry'],
      description: jsonCompany['description'],
      ceo: jsonCompany['CEO'],
      sector: jsonCompany['sector'],
    );
  }

  List<MarketIndexModel> fromIEXCloudIndexes(Map <String, dynamic> json) {
    List<MarketIndexModel> retVal = List ();
    json.forEach((key, value) =>
      retVal.add (MarketIndexModel (
        symbol: value ['quote']['symbol'],
        change: value ['quote']['change'] == null ? 0.0 : value ['quote']['change'].toDouble (),
        price: value ['quote']['latestPrice'].toDouble (),
        name: value ['quote']['companyName'])
      )
    );
    return retVal;
  }

  List<MarketActiveModel> fromIEXCloudActives(List<dynamic> items) {
    if (items != null) {
      return items
      .map((item) => fromIEXCloudActivesSingle(item))
      .toList();
    } else {
      return <MarketActiveModel>[];
    }
  }

  MarketActiveModel fromIEXCloudActivesSingle(Map<String, dynamic> json) {
    return MarketActiveModel(
      ticker: json['symbol'],
      changes: json['change'] != null ? json['change'].toDouble () : 0.0,
      price: json['latestPrice'] != null ? json['latestPrice'].toDouble () : 0.0,
      changesPercentage: json['changePercent'] != null ? json['changePercent'].toDouble () : 0.0,
      companyName: json['companyName'],
    );
  }

  @override
  Future<List<MarketIndexModel>> getIndexes() async {
    final Uri uri = Uri.https(baseUrl, '/stable/stock/market/batch/', {
      'symbols' : 'DIA,SPY,QQQ,IWM,VXX',
      'types': 'quote',
      'token': iexCloudKey
    });
    // print ("iex_cloud_http_helper - " 0+ uri.toString());
    Response response = await Dio().getUri(uri);
    return fromIEXCloudIndexes(response.data);
  }

  @override
  Future <List<StockChart>> getChart(String symbol, String duration) async {
    Response response = await iexCloudRequest('/stable/stock/$symbol/chart/$duration/');
    return StockChart.toList (response.data);
  }

  @override
  Future<Response> getProfileStats(String symbol) {
    return iexCloudRequest('/stable/stock/$symbol/stats');
  }

  @override
  Future <StockQuote> getQuote(String symbol) async {
    Response jsonQuote = await iexCloudRequest('/stable/stock/$symbol/quote');
    return fromIEXCloudQuote(jsonQuote.data, null);
  }

  @override
  Future <StockQuote> getQuoteFull(String symbol) async {
    Response jsonQuote = await iexCloudRequest('/stable/stock/$symbol/quote');
    Response jsonStats = await iexCloudRequest('/stable/stock/$symbol/stats');
    return fromIEXCloudQuote(jsonQuote.data, jsonStats.data);
  }

  @override
  Future<StockProfile> getCompanyProfile(String symbol) async {
    Response jsonCompany = await iexCloudRequest('/stable/stock/$symbol/company');
    Response jsonQuote = await iexCloudRequest('/stable/stock/$symbol/company');
    return fromIEXCloudProfile(jsonCompany.data, jsonQuote.data);
  }

  @override
  Future<List<MarketActiveModel>> getMarketActives() async {
    Response json = await iexCloudRequest('/stable/stock/market/list/mostactive');
    return fromIEXCloudActives(json.data);
  }

  @override
  Future<List<MarketActiveModel>> getMarketGainers() async {
    Response json = await iexCloudRequest('/stable/stock/market/list/gainers');
    return fromIEXCloudActives(json.data);
  }

  @override
  Future<List<MarketActiveModel>> getMarketLosers() async {
    Response json = await iexCloudRequest('/stable/stock/market/list/losers');
    return fromIEXCloudActives(json.data);
  }
}