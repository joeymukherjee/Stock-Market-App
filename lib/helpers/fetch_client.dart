import 'package:dio/dio.dart';
// import 'package:sma/helpers/iex_cloud_http_helper.dart';
import 'package:sma/helpers/financial_modeling_prep_http_helper.dart';
import 'package:sma/models/profile/market_index.dart';
import 'package:sma/models/markets/market_active/market_active.dart';
import 'package:sma/models/profile/stock_chart.dart';
import 'package:sma/models/profile/stock_profile.dart';
import 'package:sma/models/profile/stock_quote.dart';

abstract class FetchClient {
  String getAttribution ();
  Future <List<MarketIndexModel>> getIndexes ();
  Future <List<StockChart>> getChart (String symbol, String duration);
  Future <Response> getProfileStats (String symbol);
  Future <StockQuote> getQuote (String symbol);
  Future <StockQuote> getQuoteFull (String symbol);
  Future <StockProfile> getCompanyProfile (String symbol);
  Future <List<MarketActiveModel>> getMarketActives ();
  Future <List<MarketActiveModel>> getMarketGainers ();
  Future <List<MarketActiveModel>> getMarketLosers ();
}

// final FetchClient globalFetchClient = IEXFetchClient();  // How do we make this selectable by user?  Do we want that?
final FetchClient globalFetchClient = FNPFetchClient ();