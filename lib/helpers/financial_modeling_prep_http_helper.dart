import 'package:dio/dio.dart';
import 'package:sma/keys/api_keys.dart';

class FetchClient {
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
    
    return await Dio().getUri(uri);
  }

  Future<Response> financialModelIndexesRequest () async {
    final Uri uri = Uri.https('financialmodelingprep.com', '/stable/stock/market/batch/', {
      'symbols' : 'DIA,SPY,QQQ,IWM,VXX',
      'types': 'quote',
      'token': kIEXCloudKey
    });
    // print ("iex_cloud_http_helper - " + uri.toString());
    return await Dio().getUri(uri);
  }

  Future<Response> financialModelChartRequest (String symbol) async {
    final DateTime date = DateTime.now();
    final String authority = 'financialmodelingprep.com';
    final Uri uri = Uri.https(authority, '/api/v3/historical-price-full/$symbol', {
      'from': '${date.year - 1}-${date.month}-${date.day}',
      'to': '${date.year}-${date.month}-${date.day - 1}',
      'apikey': kFinancialModelingPrepApi
    });
    return await Dio().getUri(uri);
  }
}
