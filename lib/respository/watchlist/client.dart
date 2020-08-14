import 'package:dio/dio.dart';
// import 'package:sma/helpers/financial_modeling_prep_http_helper.dart';
import 'package:sma/helpers/iex_cloud_http_helper.dart';
import 'package:sma/models/data_overview.dart';
import 'package:sma/models/profile/market_index.dart';

class WatchlistClient extends FetchClient {

  Future<List<MarketIndexModel>> fetchIndexes() async {
    final Response<dynamic> response = await super.iexCloudIndexesRequest();
    return MarketIndexModel.fromMap(response.data);
  }

  Future<StockOverviewModel> fetchStocks({String symbol}) async {
    final Response<dynamic> response = await super.iexCloudRequest('/stable/stock/$symbol/quote');
    return StockOverviewModel.fromJson(response.data);
  }
}