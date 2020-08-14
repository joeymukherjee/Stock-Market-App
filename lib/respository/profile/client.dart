import 'package:dio/dio.dart';

// import 'package:sma/helpers/financial_modeling_prep_http_helper.dart';
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

    // final Response<dynamic> stockProfile = await super.financialModelRequest('/api/v3/company/profile/$symbol');
    // final Response<dynamic> stockQuote = await super.financialModelRequest('/api/v3/quote/$symbol');
    final Response<dynamic> stockStats = await super.iexCloudProfileStats (symbol);
    final Response<dynamic> stockProfile = await super.iexCloudRequest('/stable/stock/$symbol/company');
    final Response<dynamic> stockQuote = await super.iexCloudRequest('/stable/stock/$symbol/quote');
    final Response<dynamic> stockChart = await _fetchChart(symbol: symbol);
    return ProfileModel(
      // stockQuote: StockQuote.fromJson(stockQuote.data[0]),
      // stockProfile: StockProfile.fromJson(stockProfile.data['profile']),
      // stockChart: StockChart.toList(stockChart.data['historical']),
      stockQuote: StockQuote.fromIEXCloud(stockQuote.data, stockStats.data),
      stockProfile: StockProfile.fromIEXCloud (stockProfile.data, stockQuote.data),
      stockChart: StockChart.toList(stockChart.data),
    );
  }

  static Future<Response> _fetchChart({String symbol}) async {
    return await FetchClient().iexCloudChartRequest(symbol);
  }
}