import 'package:dio/dio.dart';
import 'package:sma/models/profile/market_index.dart';
import 'package:sma/models/profile/stock_profile.dart';
import 'package:sma/models/profile/stock_quote.dart';

abstract class FetchClient {
  Future <List<MarketIndexModel>> getIndexes ();
  Future <Response> getChart (String symbol, String duration);
  Future <Response> getProfileStats (String symbol);
  Future <StockQuote> getQuote (String symbol);
  Future <StockQuote> getQuoteFull (String symbol);
  Future <StockProfile> getCompanyProfile (String symbol);
  Future <Response> getMarketActives ();
  Future <Response> getMarketGainers ();
  Future <Response> getMarketLosers ();
}