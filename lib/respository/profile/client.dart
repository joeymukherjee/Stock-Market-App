import 'package:dio/dio.dart';
import 'package:sma/helpers/iex_cloud_http_helper.dart';

import 'package:sma/models/profile/profile.dart';
import 'package:sma/models/profile/stock_chart.dart';

import 'package:sma/models/profile/stock_profile.dart';
import 'package:sma/models/profile/stock_quote.dart';

class ProfileClient extends FetchClient {
  Future<StockQuote> fetchProfileChanges({String symbol}) async {
    final Response<dynamic> stockStats = await super.iexCloudProfileStats (symbol);
    final Response<dynamic> stockQuote = await super.iexCloudRequest('/stable/stock/$symbol/quote');
    return StockQuote.fromIEXCloud(stockStats.data, stockQuote.data);
  }
  
  Future<ProfileModel> fetchStockData({String symbol}) async {
    final Response<dynamic> stockStats = await super.iexCloudProfileStats (symbol);
    final Response<dynamic> stockProfile = await super.iexCloudRequest('/stable/stock/$symbol/company');
    final Response<dynamic> stockQuote = await super.iexCloudRequest('/stable/stock/$symbol/quote');
    final Response<dynamic> stockChart = await fetchChart(symbol: symbol, duration: '1y');
    return ProfileModel(
      stockQuote: StockQuote.fromIEXCloud(stockQuote.data, stockStats.data),
      stockProfile: StockProfile.fromIEXCloud (stockProfile.data, stockQuote.data),
      stockChart: StockChart.toList(stockChart.data),
    );
  }

  Future<Response> fetchChart({String symbol, String duration}) async {
    return await FetchClient().iexCloudChartRequest(symbol, duration);
  }
}